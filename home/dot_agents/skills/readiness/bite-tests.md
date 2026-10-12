# Bite tests

A checker that never fails is decoration. For each checker a criterion relies on, in the scratch worktree:

1. Run it on the clean tree. It must pass (or record the existing failures, so the violation's failure is distinguishable).
2. Add one violation it should catch. Run it again. It must fail, and the output must name your violation.
3. Revert the violation. Run it once more. It must pass.

Record all three runs: command, exit code, and the output line that names the violation. If step 2 passes, the checker isn't wired the way the repo thinks: the criterion fails, and the gap says what was missed.

Run the checker through the repo's own entry point (the check command, the hook, the CI job's command), not by calling the tool directly, so the test also proves the wiring.

## Violations by checker class

Pick one that the repo's configuration should catch; read its config first so the violation is in scope.

| Checker | Violation |
|---|---|
| Linter | A rule the config enables: an unused variable, an unused import, a forbidden pattern the repo bans |
| Type check | Assign a string to a number-typed variable in a file the check covers |
| Formatter | Break indentation in one line of a covered file |
| Tests | Make a tested function return a constant; at least one test must go red |
| Commit hook | Commit a file with a lint violation in the scratch worktree; the commit must be rejected. Then commit a clean change; it must go through |
| Secret scan | Add a fake credential in a recognised format (an AWS-style example key or a private-key header) to a new file |
| Dead code | Add an exported function nothing imports, or a dependency nothing uses |
| Generated output | Hand-edit one generated file; the check must fail on staleness |
| Import boundaries | Import a package's internal file from outside it |
| CI parity | Read the CI job's steps and compare them with the local check command, step by step; a step only CI runs is a FAIL for SEC-3 |

Never commit or push a violation outside the scratch worktree. Delete the scratch worktree and any commits made in it when the audit ends.
