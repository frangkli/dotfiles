# Post-deploy section

Write this section only for a surface that deploys. It answers two questions after every deploy: is the new revision the one serving traffic, and does it behave at least as well as the one before?

## Deploy proven by revision

- Name the source of truth for the live revision: the platform's deploy record for the merge commit (its CLI or API), a version or build-info endpoint that returns the commit SHA, or the release tag the error tracker reports. An HTTP 200 proves the host answers, not which release it runs.
- Give the exact command that reads the live revision and the expected match (`live sha == merge sha`).
- Report one verdict, in this order of strength: **DEPLOYED AND VERIFIED** (revision matches and the canary passed), **DEPLOYED (UNVERIFIED)** (revision matches, canary not run or inconclusive), **MERGED (UNVERIFIED)** (no proof the revision is live), **REVERTED**, **ROLLBACK PENDING**.

## Canary against a baseline

- **Baseline first.** Before the deploy (or from the previous revision), capture for each mapped key flow: console errors by message identity, failed and 4xx/5xx requests, load or response time, the flow's observable outcome, and the telemetry query that shows the flow's error rate and volume. Store it where Evidence says; never overwrite the baseline during the run.
- **Checks.** After the revision is proven live, repeat the same capture on a fixed cadence for a fixed window (for example every minute for ten minutes), using the same commands as the baseline.
- **Alert on change, not on absolutes,** and only when it persists across two or more consecutive checks: a new error identity, a new failing request path, a flow outcome that differs, or load time above twice the baseline.
- **Production is read-only.** Drive only flows that change nothing, unless the user approved a specific mutation. Never follow logout, delete, cancel or unsubscribe links.
- **Production acceptance.** For the changed feature, name the real outcome to observe (a record created, a message delivered, a metric moving) and the telemetry query that shows it; a status code alone is not acceptance.
