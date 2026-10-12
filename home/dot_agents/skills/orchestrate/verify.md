# Verifying a candidate

A worker's report is a claim. The verdict comes from what you run yourself on the candidate SHA.

1. **Check the candidate.** The worktree is clean, and its HEAD equals the reported SHA. Read `git log --oneline <base>..<sha>`. Compare `git diff --name-only <base>...<sha>` with SCOPE: a file outside it means the verdict is `failed` (scope).
2. **Re-run the CHECK** in the unit's worktree at that SHA. It passes only when the command exits 0 **and** the expected text appears in its output; a non-zero exit fails even if the text appears. For a CHECK that asserts something is absent, first show it can detect a known case (for example, run it on the base, where the thing still exists), because a wrong path or pattern also prints nothing.
3. **Run the surface.** If the unit changes behaviour on an app surface, run the project's `verify` skill on it.
4. **Read the diff** against ACCEPTANCE. Units touching auth, data, money, migrations, concurrency or public contracts also get `adversarial-review`. Add the other vendor's model only for high-risk diffs.
5. **Record the verdict** in `units.md`, with the commands and their results as evidence.

## Verdict ladder

| Verdict | Means | Integrate? |
|---|---|---|
| `live-verified` | CHECK passes and the `verify` skill drove the real surface | Yes |
| `unit-verified` | CHECK and the focused tests pass on this SHA | Yes |
| `type-check-only` | Only static checks could run | Only for units without behaviour (types, docs, config) |
| `blocked` | Verification couldn't run (environment, missing service). Not a pass | No. Fix the environment, then verify again |
| `failed` | A check failed, or the diff left SCOPE | No. Run a fix round |

A green CI run is one input to a verdict; the verdict itself comes from this procedure. A new head SHA voids the verdict, so verify again after any fix, rebase or amend.

## units.md

```markdown
Predicate: all 5 units integrated at unit-verified or better; full readiness check green on the integrated head
Budget: 2h (spawning stops at ~1h25m)
Integration branch: <branch> @ <sha>

| unit | ticket | depends on | branch | worktree | base | candidate | verdict | evidence |
|---|---|---|---|---|---|---|---|---|
| u1 | T-12 | | wt/u1 | ../repo-wt/u1 | a1b2c3d | e4f5a6b | unit-verified | `CHECK` exit 0, "OK: 3 rows"; focused tests 14/14 |
```

Add a row for each fix round or respawn; earlier rows stay. Mark abandoned units `abandoned: <reason>`.
