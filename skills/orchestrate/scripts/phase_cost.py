"""Tokens and list-price dollars a project spent in one phase, from AgentsView.

phase_cost.py <project> <start> [<end>] [--cwd <prefix>]...    RFC3339 times; <end> defaults to now

Sums every usage row timestamped inside the window, across the project's sessions
active since <start>. With --cwd, only sessions whose working directory starts with
one of the prefixes count: pass the run's worktrees, so other threads in the same
project during the window stay out. A session's usage includes its subagents, and each T3 worker
thread is its own session. The session-level cost reads 0, so only rows are summed.
"""

import json
import subprocess
import sys
from datetime import datetime, timezone

FIELDS = ["input_tokens", "output_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"]


def av(*args):
    out = subprocess.run(["agentsview", *args, "--json"], check=True, capture_output=True, text=True)
    return json.loads(out.stdout)


def when(text):
    return datetime.fromisoformat(text.replace("Z", "+00:00"))


def main():
    args, cwds = sys.argv[1:], []
    while "--cwd" in args:
        i = args.index("--cwd")
        if i + 1 == len(args):
            sys.exit(__doc__.strip())
        cwds.append(args.pop(i + 1).rstrip("/"))
        args.pop(i)
    if len(args) not in (2, 3):
        sys.exit(__doc__.strip())
    project, start = args[0], when(args[1])
    end = when(args[2]) if len(args) == 3 else datetime.now(timezone.utc)

    ids, cursor = [], None
    while True:
        page = av("session", "list", "--project", project, "--active-since", start.isoformat(),
                  "--include-one-shot", "--limit", "500", *(["--cursor", cursor] if cursor else []))
        ids += [s["id"] for s in page["sessions"]
                if not cwds or any((s.get("cwd") or "") == c or (s.get("cwd") or "").startswith(c + "/") for c in cwds)]
        cursor = page.get("next_cursor") or page.get("cursor")
        if not cursor:
            break
    if not cwds and page.get("total", 0) > len(ids):
        sys.exit(f"AgentsView lists {page['total']} sessions but returned {len(ids)}; narrow the window.")

    total = dict.fromkeys(FIELDS, 0)
    micro, sessions = 0, 0
    for sid in ids:
        rows = [r for r in av("session", "usage", sid).get("breakdown", []) if start <= when(r["timestamp"]) < end]
        if rows:
            sessions += 1
        for r in rows:
            for f in FIELDS:
                total[f] += r.get(f) or 0
            micro += (r.get("cost") or {}).get("microdollars") or 0

    print(json.dumps({
        "project": project, "start": start.isoformat(), "end": end.isoformat(), "sessions": sessions,
        **total, "total_tokens": sum(total.values()), "list_price_usd": round(micro / 1e6, 2),
    }, indent=2))


if __name__ == "__main__":
    main()
