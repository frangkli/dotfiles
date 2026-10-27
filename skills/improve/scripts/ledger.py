"""Ledger operations for an improve state folder.

  ledger.py id <path> <title>                      print a finding's id
  ledger.py init <state> <base> <scope>...         start a ledger
  ledger.py candidates <state> <round> [shards]    merge round-<n>/*.json into round-<n>/candidates.json,
                                                   and with shards > 1 split it by path into candidates-<k>.json
  ledger.py apply <state> <round> <head>           apply verified-<n>.json or every verified-<n>-<k>.json, and record the round
  ledger.py verdict <state> <id> <status> <reason> record a fixer's rejection or deferral
  ledger.py outcome <state> <done|escalated|halted>
  ledger.py known <state> [max_chars]              open and settled findings, for ocr's background file
"""
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

SETTLED = {"fixed", "refuted", "deferred"}
STATUS = {"confirmed": "open", "unverifiable": "open", "refuted": "refuted", "fixed": "fixed"}
ROOT = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True).stdout.strip()


def norm_path(path):
    if ROOT and os.path.isabs(path) and path.startswith(ROOT + "/"):
        path = path[len(ROOT) + 1:]
    return path[2:] if path.startswith("./") else path


def finding_id(path, title):
    words = re.sub(r"[^a-z0-9]+", " ", title.lower()).strip()
    return hashlib.sha256(f"{norm_path(path)}\n{words}".encode()).hexdigest()[:8]


def read(state):
    p = state / "ledger.json"
    ledger = json.loads(p.read_text()) if p.exists() else {}
    for key, empty in (("decisions", []), ("rounds", []), ("findings", {})):
        ledger.setdefault(key, empty)
    return ledger


def write(state, ledger):
    (state / "ledger.json").write_text(json.dumps(ledger, indent=2))


def init(state, base, scope):
    state.mkdir(parents=True, exist_ok=True)
    ledger = read(state)
    ledger.update(base=base, scope=scope, outcome=None)
    write(state, ledger)


def candidates(state, n, shards=1):
    findings = read(state)["findings"]
    files = lane_files(state, n)
    if not files:
        sys.exit(f"no lane results in round-{n}/")
    merged, dropped = {}, []
    for f in files:
        result = json.loads(f.read_text())
        if not isinstance(result, dict) or "findings" not in result:
            print(f"  skipped {f.name}: not a lane result")
            continue
        for c in result["findings"]:
            if not c.get("path") or not c.get("title"):
                print(f"  skipped a finding in {f.name} with no path or title")
                continue
            c["path"] = norm_path(c["path"])
            cid = finding_id(c["path"], c["title"])
            known = findings.get(cid)
            if known and known["status"] in SETTLED and not c.get("worse"):
                dropped.append(f"{c['title']} ({cid}): {known['status']}")
                continue
            entry = merged.setdefault(cid, {**c, "id": cid, "lanes": []})
            entry["lanes"].append(result.get("lane", f.stem))
    (state / f"round-{n}" / "candidates.json").write_text(json.dumps(list(merged.values()), indent=2))
    print(f"{len(merged)} candidates, {len(dropped)} dropped as settled")
    for old in (state / f"round-{n}").glob("candidates-*.json"):
        old.unlink()
    if shards > 1:
        # Keep each path in one shard, so one verifier sees every claim about a file; fill the smallest shard first.
        by_path = {}
        for c in merged.values():
            by_path.setdefault(c["path"], []).append(c)
        parts = [[] for _ in range(shards)]
        for group in sorted(by_path.values(), key=len, reverse=True):
            min(parts, key=len).extend(group)
        parts = [part for part in parts if part]
        for k, part in enumerate(parts, 1):
            (state / f"round-{n}" / f"candidates-{k}.json").write_text(json.dumps(part, indent=2))
        print(f"split into {len(parts)} shards of", ", ".join(str(len(part)) for part in parts))
    for d in dropped:
        print("  dropped", d)


def lane_files(state, n):
    return [f for f in sorted((state / f"round-{n}").glob("*.json")) if not f.name.startswith("candidates")]


def apply(state, n, head):
    ledger = read(state)
    findings, counts = ledger["findings"], {}
    whole = state / f"verified-{n}.json"
    shards = len(list((state / f"round-{n}").glob("candidates-*.json")))
    files = [whole] if whole.exists() else [state / f"verified-{n}-{k}.json" for k in range(1, shards + 1)]
    missing = [f.name for f in files if not f.exists()] or ([] if files else [whole.name])
    if missing:
        sys.exit("missing " + ", ".join(missing))
    for v in (v for f in files for v in json.loads(f.read_text())):
        counts[v["verdict"]] = counts.get(v["verdict"], 0) + 1
        entry = findings.setdefault(v["id"], {"rounds_seen": []})
        entry.update({k: v[k] for k in v if k not in ("id", "verdict")})
        entry["status"] = STATUS[v["verdict"]]
        if v["verdict"] == "unverifiable":
            entry["reason"] = v.get("reason", "unverifiable")
        if n not in entry["rounds_seen"]:
            entry["rounds_seen"].append(n)
    lanes = [f.stem for f in lane_files(state, n)]
    ledger["rounds"] = [r for r in ledger["rounds"] if r["n"] != n] + [{"n": n, "head": head, "lanes": lanes, "verdicts": counts}]
    write(state, ledger)
    open_ = [f for f in findings.values() if f["status"] == "open" and f.get("severity") in ("critical", "major")]
    print(json.dumps({**counts, "open_critical_or_major": len(open_)}))


def verdict(state, fid, status, reason):
    if status not in ("deferred", "rejected"):
        sys.exit("status must be deferred or rejected")
    ledger = read(state)
    ledger["findings"][fid].update(status="deferred" if status == "deferred" else "open", fixer=status, reason=reason)
    write(state, ledger)


def outcome(state, value):
    ledger = read(state)
    ledger["outcome"] = value
    ledger["head"] = subprocess.run(["git", "rev-parse", "HEAD"], capture_output=True, text=True, check=True).stdout.strip()
    write(state, ledger)


def known(state, max_chars=2000):
    findings = read(state)["findings"]
    ordered = sorted(findings.items(), key=lambda kv: kv[1].get("status") != "open")
    lines = [f"{i} {f.get('status')} {f.get('path', '')}: {f.get('title', '')}" for i, f in ordered]
    out, used = [], 0
    for i, line in enumerate(lines):
        rest = f"+{len(lines) - i} more findings, in the ledger"
        if used + len(line) + 1 > max_chars - len(rest) - 1:
            out.append(rest)
            break
        out.append(line)
        used += len(line) + 1
    print("\n".join(out))


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    cmd, args = sys.argv[1], sys.argv[2:]
    if cmd == "id":
        print(finding_id(args[0], args[1]))
    elif cmd == "init":
        init(Path(args[0]), args[1], args[2:])
    elif cmd == "candidates":
        candidates(Path(args[0]), int(args[1]), int(args[2]) if len(args) > 2 else 1)
    elif cmd == "apply":
        apply(Path(args[0]), int(args[1]), args[2])
    elif cmd == "verdict":
        verdict(Path(args[0]), args[1], args[2], " ".join(args[3:]))
    elif cmd == "outcome":
        outcome(Path(args[0]), args[1])
    elif cmd == "known":
        known(Path(args[0]), int(args[1]) if len(args) > 1 else 2000)
    else:
        sys.exit(__doc__)
