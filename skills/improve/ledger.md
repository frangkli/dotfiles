# State folder and ledger

One folder per ticket, outside the worktree: the run's `state/<ticket>/` when an orchestrator passes one, otherwise `$(git rev-parse --path-format=absolute --git-common-dir)/improve/<slug>/`, where `<slug>` is the branch name, or the given paths joined with `-`, with each `/` as `-`. Every worktree of the repo sees it, so a run cut off by a usage limit continues where it stopped.

| File | Written by | Read by |
|---|---|---|
| `round-<n>/packet.md` | the packet script, once per round, or as `packet-risky.md` and `packet-rest.md` when the change splits into groups | each lane of its group, the verifier |
| `ledger.json` | `ledger.py` | every reviewer, `ocr` and Codex included |
| `round-<n>/<lane>.json` | each lane, when it returns | `ledger.py candidates`; a resumed run reruns only lanes whose file is missing |
| `round-<n>/raw/` | `ocr` and Codex, before their output is converted to a lane file | the agent converting it |
| `round-<n>/candidates.json` | `ledger.py candidates` | the verifier |
| `verified-<n>.json` | the verifier | `ledger.py apply`, the fixer |
| `next.md` | the run, after each step | a resumed or replacement agent |
| `scratch/<name>/` | a shared reference or scratch build, as a `git worktree` | every lane that needs it; removed when the run finishes |

## Ledger

```json
{
  "base": "<commit>",
  "contract": "the caller's contract, verbatim, or null",
  "lens": false,
  "scope": ["src/billing/**"],
  "guarded": { "path/outside/scope": "<sha256 at baseline>" },
  "decisions": ["user rulings, verbatim; binding on every round"],
  "outcome": "done | escalated | halted, written when the run stops",
  "rounds": [
    { "n": 1, "head": "<commit reviewed>", "lanes": ["correctness-security", "test-integrity"], "confirmed": { "critical": 0, "major": 3, "minor": 2 }, "refuted": 4 }
  ],
  "findings": {
    "3f9a1c2e": {
      "title": "Retried charge can bill twice",
      "severity": "major",
      "path": "src/billing/charge.ts",
      "lines": "40-52",
      "status": "open | fixed | refuted | deferred",
      "trigger": "a failing test, or the exact input",
      "evidence": "two concurrent calls with the same key both insert",
      "remedy": "check the idempotency key inside the insert transaction",
      "pin": "test name that fails without the fix",
      "reason": "why refuted or deferred",
      "rounds_seen": [1]
    }
  }
}
```

**Commands.** `python3 ~/.agents/skills/improve/scripts/ledger.py` with `init`, `candidates`, `apply`, `verdict`, `outcome`, `known` and `id`; run it with no arguments for usage. It writes `base`, `scope`, `rounds`, `findings` and `outcome`; you add the contract, `guarded` and `decisions`.

**Ids.** A finding's id is a short hash of its repo-relative path and normalised title, with no line number, so it survives code moving (`ledger.py id <path> "<title>"`). A report always shows the title, with the id beside it.

**Wording rules.** Every reviewer prompt, `ocr`'s and Codex's included, carries these three, so the same defect always hashes to the same id:
1. Repeat a still-open finding word for word, title included.
2. Raise a refuted or deferred finding again only if the code got worse, marked `"worse": true` with what changed.
3. Never restate an earlier finding in new words.

**Merging.** `candidates` merges a round's lane files into one list, credits every lane that raised the same id, and drops candidates whose id is already fixed, refuted or deferred unless marked worse. The verifier folds rewordings and same-round duplicates into one id. `apply` records its verdicts (`confirmed` and `unverifiable` stay open, `refuted`, `fixed`) and the round's head and lanes; it fails if `verified-<n>.json` is missing, so a dead verifier halts the run instead of passing it. Only the verifier marks a finding fixed: a fixer's "fixed" stays open until the next round's verifier confirms it holds. `verdict` records a fixer's rejection (still open) or deferral.

**Known list.** `ocr` can't take the whole ledger, so its background file gets `ledger.py known <state> <chars>`: one line per finding, open ones first, cut to the characters left under ocr's limit of about 2,000.

## Save points and resume

Each review round's head is a commit: the `wip:` save point at baseline, then the fixer's `fixup!` commits. A confirming round reviews `git diff <last reviewed head> HEAD -- <scope>`. Save points stay local until the run folds them at the end.

A run is **unfinished** when its ledger has no `outcome`, or `halted`, and every commit after its last reviewed head (its base, before round 1) is one of its own `wip:` or `fixup!` save points. Continue it from `next.md`. A lane with raw output but no lane file was cut off: rerun it. Uncommitted in-scope edits found on resume are a cut-off fixer's partial work, and the resumed fixer starts from them. Any other ledger is finished: new commits or a rebase mean the change moved, so it gets a fresh run, which keeps the settled verdicts and, when the change only grew, reviews only what was added ([SKILL.md](SKILL.md) step 1).
