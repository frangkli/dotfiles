# Ledger

One JSON file per run, at `.context/improve/<slug>/ledger.json`. `.context/` is ignored by git. The ledger is what makes verdicts stick and what lets a run resume after compaction or an escalation.

```json
{
  "base": "<commit>",
  "scope": ["src/billing/**"],
  "guarded": { "path/outside/scope": "<sha256 at baseline>" },
  "decisions": ["user rulings, verbatim; binding on every round"],
  "rounds": [
    { "n": 1, "type": "review", "open": { "critical": 0, "major": 3, "minor": 2 }, "new": 5, "reopened": 0, "refiled_rejected": 0 }
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

**Ids.** `file:line:class`, where class is a short kebab-case label for the defect. When the line moves, match on `file` and `class` if exactly one open finding fits.

**Merging a review.**
- New finding: add it as open.
- Fixed finding reported again: reopen it; the fix didn't hold.
- Rejected finding re-filed without new evidence: count it in `refiled_rejected`, keep it rejected.
- Rejected finding re-filed with new evidence: reopen it.
- Deferred finding: reopen only if now critical or major.

**Merging a fix round.** Every finding sent to the fixer gets a verdict: fixed (with its pin), rejected (with the reason) or deferred (minor or info only). A finding with no verdict stays open.
