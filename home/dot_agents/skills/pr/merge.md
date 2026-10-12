# Merge

Only when the task or its plan explicitly authorized merging this PR, for example "merge when green".

1. **Green on the head.** The babysit stop rule says green, Greptile included when it runs, with no ask item open and every approval the repo requires present (`reviewDecision`).
2. **The verdict still holds.** The ledger holds the patch id recorded at green. If you have rebased since, compute it again the same way. The same patch id means the code verdict stands, but CI must still be green on the new head. A different one means the change itself moved: review it again and wait for CI.
3. **The base hasn't moved under it.** `git fetch origin && git merge-tree --write-tree origin/<base> HEAD` exits 0. If `origin/<base>` gained commits touching files the PR changes or the CI configuration, rebase and go back to babysitting.
4. **Merge:** `gh pr merge <n> --rebase --match-head-commit <head sha>`. Rebase merges put the commits on the base as written. If the repo doesn't allow rebase merges, use the method it does allow and say so. Merge under the repo's rules as they stand, never with `--admin`.
5. **On a non-zero exit,** read `gh pr view <n> --json state,mergedAt,mergeCommit` before anything else: a merge that timed out may have succeeded.
6. **After:** delete `backup/<branch>`. Deploying and verifying the deploy follow the project's `verify` skill. The report keeps merged, deployed and verified apart.
