# CI speed and reliability

1. **Measure with nothing changed.** Take the last 20 pull-request runs (`gh run list --event pull_request --limit 20 --json databaseId,workflowName,attempt,conclusion,createdAt,updatedAt,headSha`, then `gh run view <id> --json jobs` per run). Record per workflow and per job: median and p90 duration, queue time, and reruns (`attempt` above 1). The noise band of a job is the gap between its 25th and 75th percentile durations. A test that failed and then passed on the same `headSha` is a flaky candidate. Time each `GATES.md` command locally and compare with the listed time.
2. **Hypothesis.** Name a mechanism and its number, for example "cache the pnpm store: install takes 2m10s of a 6m job". The first reply states the hypothesis cap (default 5).
3. **One change per commit.** Run the changed workflow at least 5 times on the branch (`gh workflow run`, or `gh run rerun`).
4. **Keep or revert.** Keep the change only when the median gain is larger than the job's noise band and every check stays green. Otherwise revert it.
5. **Stop** at the target (SEC-9's ~10 min median, or the owner's number), when two hypotheses in a row give nothing, or at the cap.

CI keeps running the same check command as local, with every check it ran before. Flaky tests go to `debug` for their cause or to `test-audit` to judge whether they earn their place; a quarantine needs an expiry date and a tracking ticket. Run `gha-security-review` on any workflow edit before the PR. The PR body gives the before and after median and p90, the run counts, and the noise band.
