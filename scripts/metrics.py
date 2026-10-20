#!/usr/bin/env python3
"""Token usage per Claude Code session for a beadflow project, with the beads
each session landed.

Sources, all under ~/.claude/projects:
  <project>/<session>.jsonl                   coordinator sessions
  <project>/<session>/subagents/agent-*.jsonl subagents of that session
  <project>--claude-worktrees-*/<session>.jsonl  implementer sessions that ran
                                              in a worktree of the project

A session is linked to a bead when a commit with a `Bead:` line lands inside
the session's time window. A coordinator session that landed several beads
lists all of them; its tokens are not split between them.

Usage: scripts/metrics.py [--repo PATH] [--since YYYY-MM-DD]
"""
import argparse
import json
import re
import subprocess
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

PROJECTS = Path.home() / ".claude" / "projects"
FIELDS = ("input_tokens", "cache_creation_input_tokens",
          "cache_read_input_tokens", "output_tokens")


def parse_ts(s):
    return datetime.fromisoformat(s.replace("Z", "+00:00"))


def read_usage(path):
    """Return ({model: token totals}, first ts, last ts) for one transcript.

    A response can span several lines that share a requestId; the last line
    holds the final usage, so earlier ones are overwritten.
    """
    by_request, stamps = {}, []
    for line in path.open():
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        if d.get("timestamp"):
            stamps.append(parse_ts(d["timestamp"]))
        msg = d.get("message")
        if d.get("type") != "assistant" or not isinstance(msg, dict) or not msg.get("usage"):
            continue
        key = d.get("requestId") or d.get("uuid")
        if msg.get("model") == "<synthetic>":
            continue
        by_request[key] = (msg.get("model", "unknown"), msg["usage"])
    totals = defaultdict(lambda: dict.fromkeys(FIELDS, 0))
    for model, usage in by_request.values():
        for f in FIELDS:
            totals[model][f] += usage.get(f) or 0
    return totals, (min(stamps) if stamps else None), (max(stamps) if stamps else None)


def bead_commits(repo, since):
    """Commits whose message has a `Bead: <id>` line anywhere in the body.

    Matched with a regex instead of `git interpreter-trailers` because build
    commits put the Bead line above the Co-Authored-By paragraph, which git
    doesn't treat as part of the trailer block.
    """
    out = subprocess.run(
        ["git", "-C", str(repo), "log", "--all", f"--since={since}",
         "--format=%cI%x01%B%x00"],
        capture_output=True, text=True, check=True).stdout
    commits = []
    for record in out.split("\x00"):
        when, _, body = record.strip().partition("\x01")
        beads = re.findall(r"^Bead:\s*(\S+)", body, re.M)
        if when and beads:
            commits.append((parse_ts(when), beads))
    return commits


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=".")
    ap.add_argument("--since", default="1970-01-01")
    args = ap.parse_args()

    repo = Path(subprocess.run(
        ["git", "-C", args.repo, "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, check=True).stdout.strip())
    prefix = re.sub(r"[/.]", "-", str(repo))
    commits = bead_commits(repo, args.since)
    since = datetime.fromisoformat(args.since).replace(tzinfo=timezone.utc)

    transcripts = []  # (kind, session, path)
    for proj in PROJECTS.glob(prefix + "*"):
        kind = "main" if proj.name == prefix else "worktree"
        for p in proj.glob("*.jsonl"):
            transcripts.append((kind, p.stem, p))
        for p in proj.glob("*/subagents/agent-*.jsonl"):
            transcripts.append(("subagent", p.parent.parent.name, p))

    rows, by_model = [], defaultdict(lambda: dict.fromkeys(FIELDS, 0))
    for kind, session, path in transcripts:
        totals, first, last = read_usage(path)
        if not totals or last < since:
            continue
        beads = sorted({b for when, bs in commits if first <= when <= last for b in bs})
        rows.append((first, kind, session[:8], totals, beads))
        for model, t in totals.items():
            for f in FIELDS:
                by_model[model][f] += t[f]

    hdr = f"{'started (UTC)':16} {'kind':9} {'session':8} {'model':18} {'new in':>9} {'cache wr':>10} {'cache rd':>11} {'out':>8}  beads"
    print(hdr)
    for first, kind, session, totals, beads in sorted(rows, key=lambda r: r[0]):
        for model, t in sorted(totals.items()):
            print(f"{first:%Y-%m-%d %H:%M} {kind:9} {session:8} {model:18} "
                  f"{t['input_tokens']:>9,} {t['cache_creation_input_tokens']:>10,} "
                  f"{t['cache_read_input_tokens']:>11,} {t['output_tokens']:>8,}  {' '.join(beads)}")
    print("\ntotal by model")
    for model, t in sorted(by_model.items()):
        print(f"{'':16} {'':9} {'':8} {model:18} {t['input_tokens']:>9,} "
              f"{t['cache_creation_input_tokens']:>10,} {t['cache_read_input_tokens']:>11,} "
              f"{t['output_tokens']:>8,}")


if __name__ == "__main__":
    main()
