# Merge, deploy, accept in production

Steps 10–11. Run the pre-merge checks in every case. Merge only when the plan's decision is merge when green; when it is wait, report the pre-merge checks and stop at the green PR.

## 10. Merge

1. **Independent verdict on the exact head.** A fresh subagent that wrote none of the code checks the head SHA: required checks green on that SHA, `improve` done on that SHA, and the done-predicate's checks that can run before production passing (the `verify` skill against a local or preview environment where one exists). It returns PASS or FAIL with what it ran. Record the head SHA, the trunk SHA, and the patch-id: `git diff <trunk>...HEAD | git patch-id --stable`.
2. **After any later rebase,** recompute the patch-id. Same patch: the verdict stands; re-run CI and mergeability. Different patch: get a new verdict. The one exception is a patch where only tests, docs or lint configuration moved and the checks show no behaviour change.
3. **Right before merging,** fetch trunk and confirm both:
   - `git merge-tree --write-tree origin/<trunk> HEAD` exits 0;
   - `git diff --name-only <trunk-at-verdict> origin/<trunk>` shares no path with the PR's changed files, nor with the files that decide which CI runs.
   If either fails, rebase and return to item 2.
4. **Merge** with the repo's merge method, pinned to the verified head (on GitHub, `gh pr merge --match-head-commit <sha>`), with every required check enforced. If the merge command fails or times out, read the PR's state before retrying: it may have merged.

Done when the PR is merged at the verified head SHA.

## 11. Deploy and accept

Where the repo deploys on merge, deployment follows the merge; otherwise run the rollout the plan approved.

- **Baseline first.** Before the deploy lands, capture the telemetry the change should move and the current behaviour on each affected surface.
- **Prove the revision.** A deploy record or version endpoint showing the merge SHA, or a later trunk SHA that contains it. A health check proves the service answers, not which revision is live.
- **Configuration and activation.** Apply and confirm every flag, environment variable, migration and backfill the plan lists.
- **Publication.** For every artifact the repo releases that the change touched (packages, CLIs, images, docs), confirm the published version contains the change.
- **Production acceptance.** Run the repo's `verify` skill on every surface the plan names, bounded: test accounts, a small number of calls, low spend, and cleanup of what the tests created. Check the feature's outcome (what the user actually gets) and the telemetry the plan named against the baseline. Without a `verify` skill, drive each surface by its documentation and log the gap.
- **Regressions this change caused** go through the same cycle: build, review, `pr`, merge, verify. When users are affected and the fix isn't immediate, follow the plan's recovery steps first.
- **Unrelated problems** you find go into the report's remaining work, outside this change.

Done when deployed, configured and published are each proven with evidence or marked n/a, and every surface's acceptance test has passed, or the report says which didn't and why.
