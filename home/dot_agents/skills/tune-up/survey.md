# Survey

Read-only. Collect one deciding number per kind for the target, rank the kinds, and stop. Write nothing; under ~10 minutes.

| Kind | Number | Source |
|---|---|---|
| `setup` | Age and level of the last readiness report | newest `docs/research/*-readiness.json` |
| `ci` | Median PR run duration and rerun rate over the last 20 runs | `gh run list --event pull_request --limit 20 --json databaseId,workflowName,attempt,conclusion,createdAt,updatedAt` |
| `deps` | Outdated packages by major, minor and patch; open bot PRs and how many fail | `pnpm outdated --format json` (or the stack's tool); `gh pr list --author app/dependabot` or `app/renovate` with `gh pr checks` |
| `tests` | Test count and suite time | `GATES.md`, and one measured run of the suite |
| `refactor`, `hardening` | Full check time; the 10 files changed most in 90 days | `GATES.md`; `git log --since=90.days --format= --name-only` counted per file |
| `history` | Sessions, tool failures and retries for this project over 14 days | `agentsview session list --json --since 14d --project <name>` |
| any | Date of the last run of that kind | the newest report or PR of that kind |

A source that is missing (no CI, no reports, AgentsView down) gets "no data" and the reason.

Reply with the table filled in, the kinds ranked by how far each number is from its target (readiness level 3, SEC-9's ~10 min CI median, zero failing bot PRs), and one or two recommended next runs as `/tune-up <kind>` commands.
