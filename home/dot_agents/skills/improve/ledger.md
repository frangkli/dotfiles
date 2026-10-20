# Ledger

One JSON file per run, at `.context/improve/<slug>/ledger.json`, where `<slug>` is the branch name, or the given paths joined with `-`, with each `/` as `-`. `.context/` is ignored by git. The ledger is what makes verdicts stick and what lets a run resume after compaction or a usage limit.

```json
{
  "base": "<commit>",
  "contract": "the caller's contract, verbatim, or null",
  "lens": false,
  "scope": ["src/billing/**"],
  "guarded": { "path/outside/scope": "<sha256 at baseline>" },
  "decisions": ["user rulings, verbatim; binding on every round"],
  "outcome": "converged | escalated | halted, written when the run stops",
  "rounds": [
    { "n": 1, "type": "review", "head": "<snapshot reviewed>", "open": { "critical": 0, "major": 3, "minor": 2 }, "new": 5, "reopened": 0, "refiled_rejected": 0 }
  ],
  "findings": {
    "src/billing/charge.ts:42:missing-idempotency": {
      "severity": "major",
      "title": "Retried charge can bill twice",
      "evidence": "two concurrent calls with the same key both insert",
      "status": "open | fixed | rejected | deferred",
      "verified": true,
      "pin": "test name that fails without the fix",
      "reason": "why rejected or deferred",
      "seen_in_rounds": [1],
      "fixed_in_rounds": []
    }
  }
}
```

**Snapshots.** Fixes stay uncommitted until the run finishes, so each review records the tree it saw as a commit no branch points to, made without touching the index:

```bash
sh -c 'idx=$(mktemp -u) && cp "$(git rev-parse --git-path index)" "$idx" && export GIT_INDEX_FILE="$idx" && git add -A && git commit-tree "$(git write-tree)" -p HEAD -m "improve snapshot"; s=$?; rm -f "$idx"; exit $s'
```

Every review round's head is a snapshot, full rounds included: a delta round reviews `git diff <last review round's head> <new snapshot> -- <scope>`, a full round reviews `<base>` to the new snapshot (for a paths target, the paths as they stand in it), and `ocr` takes the same pair as `--from` and `--to`. A failed snapshot halts the run. A review round with no `head`, from a ledger older than this rule, makes the next review a full round.

**Unfinished.** A ledger with no `outcome`, or `halted`, whose last snapshot's parent is still HEAD, belongs to a run that was cut off. Any other ledger is finished: new commits or a rebase mean the change moved, so it gets a fresh run.

**Ids.** `file:line:class`, where class is a short kebab-case label for the defect. When the line moves, match on `file` and `class` if exactly one open finding fits.

**Merging a review.**
- New finding: add it as open.
- Fixed finding reported again: reopen it; the fix didn't hold.
- Rejected finding re-filed without new evidence: count it in `refiled_rejected`, keep it rejected.
- Rejected finding re-filed with new evidence: reopen it.
- Deferred finding: reopen only if now critical or major.

**Merging a fix round.** Every finding sent to the fixer gets a verdict: fixed (with its pin), rejected (with the reason) or deferred (minor or info only). A finding with no verdict stays open.
