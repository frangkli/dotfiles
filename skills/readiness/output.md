# Readiness output

Two files in `docs/research/`, named for the audit date:

- `<YYYY-MM-DD>-readiness.html`, for the user, written with `visual-doc`.
- `<YYYY-MM-DD>-readiness.json`, for the next run, which grounds on it.

## Order of the HTML file

Write the content per the `writing` skill's technical mode ([technical.md](../writing/technical.md)), with this order in place of its report contract.

1. **Verdict.** The level, the pass rate at each level (`L1 5/5 · L2 11/14 · L3 6/17 …`), the commit audited, and the change since the last audit in one line.
2. **Gaps**, ordered by how much they slow agents (below). Each gap stands alone: the criterion ID and question, the scope (with `2/3 apps` for app-scoped rows), the evidence that it fails, what it costs agents in practice, and the recommended fix with its effort.
3. **Changes since the last audit:** every criterion whose verdict changed, with the evidence for the change.
4. **Evidence table:** every criterion, its verdict per scope, and its evidence. Bite tests show all three runs.
5. **Decisions:** one line per gap, the recommended option first, plus anything else only the user can decide. Nothing else follows.

## Ordering gaps by how much they slow agents

Rank by the first rule that applies, then by how many apps the gap touches:

1. **Blocks verification.** An agent can't tell whether its change works: no runnable check, setup that fails in a fresh worktree, no way to drive the app.
2. **Ships wrong work.** A check that passes on a broken change: checkers that don't bite, tests that don't fail on broken behaviour, CI that skips what local runs.
3. **Costs time on every task.** Slow checks with no fast subset, manual setup steps, missing docs that agents rediscover each run.
4. **Costs time sometimes.** Gaps hit only on deploys, releases, incidents or dependency updates.

## JSON sidecar

```json
{
  "date": "YYYY-MM-DD",
  "commit": "<sha audited>",
  "level": 2,
  "apps": [{"name": "web", "path": "apps/web", "surface": "browser"}],
  "levels": {"1": {"pass": 5, "applicable": 5}, "2": {"pass": 11, "applicable": 14}},
  "criteria": [
    {"id": "VAL-1", "scope": "web", "verdict": "PASS", "evidence": "pnpm lint exit 1 on unused var in src/x.ts:3; exit 0 after revert"}
  ]
}
```

One `criteria` entry per criterion per scope: `scope` is `repo` or the app name. `verdict` is `PASS`, `FAIL` or `N/A`; an `N/A` entry's evidence is its reason.
