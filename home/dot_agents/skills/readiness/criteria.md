# Readiness criteria

Each row is a question the repo passes or fails with evidence. **L** is the level the criterion counts toward; **Scope** is `repo` (scored once) or `app` (scored once per app). "Checker" rows pass only after a bite test ([bite-tests.md](bite-tests.md)).

Speed targets below are defaults. When the repo's `GATES.md` or `AGENTS.md` sets its own, use those and say so.

Keep the IDs stable: the next run matches verdicts by ID.

## Validation

The recommended config for a failing VAL-1 or VAL-2 is per stack: [stacks/typescript.md](stacks/typescript.md).

| ID | L | Scope | Passes when |
|---|---|---|---|
| VAL-1 | 1 | app | A linter is configured, runs from a documented command, and bites |
| VAL-2 | 1 | app | A type check or compile check runs and bites (N/A for languages with no static checker). Record strictness settings in the evidence; strictness itself doesn't decide the verdict |
| VAL-3 | 2 | app | A formatter has a check mode that fails on unformatted code |
| VAL-4 | 2 | repo | A commit hook runs fast checks on staged files, and a commit through it in the scratch worktree shows it ran |
| VAL-5 | 4 | app | Lint and type check of one changed file finish in under ~10 s, measured |

## Build and checks

| ID | L | Scope | Passes when |
|---|---|---|---|
| BLD-1 | 1 | app | The app builds or starts from a documented command in a fresh worktree |
| BLD-2 | 2 | repo | One command runs every check (lint, types, tests, build) and exits non-zero when any fails |
| BLD-3 | 2 | repo | `GATES.md` lists each check command with what it covers and how long it takes; every listed command exists, and each timing is within 2x of a measured run |
| BLD-4 | 2 | repo | A lockfile is committed and the runtime and toolchain versions are pinned in files the tools read |
| BLD-5 | 3 | repo | `AGENTS.md` or `GATES.md` says to run the cheapest covering check while iterating and the full check only at ship points, and no instruction tells agents to run the full check before every hand-off |
| BLD-6 | 4 | repo | Checks can run per package or per app, so a unit's check doesn't need the whole repo |

## Testing

| ID | L | Scope | Passes when |
|---|---|---|---|
| TST-1 | 1 | app | Tests exist, run locally from one command with only documented setup, and fail when a tested behaviour is broken |
| TST-2 | 3 | app | An end-to-end or integration path drives each surface of the app (browser, HTTP, CLI) and runs locally or in CI |
| TST-3 | 4 | app | A fast subset (one file or one package) runs in under ~30 s and `GATES.md` names it |
| TST-4 | 4 | repo | Flaky tests are detected or tracked: retries are reported, a quarantine list exists, or CI history is checked |

## Agent docs

| ID | L | Scope | Passes when |
|---|---|---|---|
| DOC-1 | 1 | repo | A README says what the repo is and how to start it |
| DOC-2 | 2 | repo | A root `AGENTS.md` exists, under ~60 lines (FAIL above 100), and every command and path in it exists |
| DOC-3 | 2 | repo | `AGENTS.md` points to `GATES.md`, the `verify` skill and the docs an agent needs, instead of restating config, listing installed skills or holding attribution rules |
| DOC-4 | 2 | app | The app's own commands are findable from the root `AGENTS.md` or a short `AGENTS.md` in the app folder (nested files only where commands differ) |
| DOC-5 | 3 | repo | `REVIEW_RULES.md` exists at the repo root and `AGENTS.md` links it, each rule names a concrete failing case, no bot rules file (`.cursor/BUGBOT.md`, `.greptile/`) duplicates it, and every review bot the repo uses reads it (the bot's comments cite it, or the user confirms the dashboard setting) |
| DOC-6 | 3 | repo | Both harnesses reach the instructions and project skills: Claude reads `AGENTS.md` (directly, or through a `CLAUDE.md` link or import) and `.claude/skills` resolves to `.agents/skills` |

## Dev environment

| ID | L | Scope | Passes when |
|---|---|---|---|
| ENV-1 | 2 | repo | One idempotent command brings a fresh worktree to runnable (dependencies, services, env, database), and a second run changes nothing |
| ENV-2 | 2 | app | Every environment variable the app reads is declared in a template or secrets manifest; a grep of reads against it finds no undeclared name |
| ENV-3 | 2 | repo | Secrets are injected by a documented command; none are committed |
| ENV-4 | 3 | repo | Two worktrees run their full stacks at once without sharing a port, database or data directory, shown by running setup in two scratch worktrees |
| ENV-5 | 4 | repo | Setup on a fresh worktree takes under ~10 s (first install and image pull excluded), under ~2 s when already up, and teardown under ~5 s, measured |
| ENV-6 | 4 | repo | Setup runs on its own when a worktree is created, through the hooks the repo's agent tools offer |

## Verification

| ID | L | Scope | Passes when |
|---|---|---|---|
| VER-1 | 3 | app | A project `verify` skill under `.agents/skills/verify/` covers the app's surface with Launch, Doctor, Drive, Evidence and Cleanup, plus a feature map |
| VER-2 | 3 | app | Its Doctor passes and one mapped feature drives end to end in this audit, with evidence that survives Cleanup |
| VER-3 | 4 | app | For an app that deploys: the `verify` skill proves a deploy by revision (the live build reports the merge commit) and compares a post-deploy canary against a baseline |
| VER-4 | 5 | app | Production acceptance runs after every deploy without a person starting it, and a failure is reported where the team will see it |

## Code health

| ID | L | Scope | Passes when |
|---|---|---|---|
| HLT-1 | 2 | repo | Generated files are identified (header, attributes file or documented paths) and a documented command regenerates them |
| HLT-2 | 3 | repo | The check command fails when generated output is stale or edited by hand |
| HLT-3 | 3 | repo | Unused code, exports and dependencies are detected by a checker in the check command, and it bites |
| HLT-4 | 4 | repo | In a repo with several packages: import-boundary and cycle rules are enforced and bite (N/A for a single package) |
| HLT-5 | 5 | repo | Recurring review findings become checks: at least one lint rule, review rule or test added in the last 90 days traces to a past mistake |

## Observability

N/A for an app that never runs as a process (a library). CLIs count only when they report usage or errors somewhere.

| ID | L | Scope | Passes when |
|---|---|---|---|
| OBS-1 | 3 | app | Logs are structured and carry a request or correlation id |
| OBS-2 | 3 | app | Traces or metrics reach a backend that an agent can query from the box with a CLI or API, documented in the repo |
| OBS-3 | 4 | app | Errors reach an error tracker tagged with the release or commit |
| OBS-4 | 4 | app | For each mapped feature, the repo names the telemetry query that shows the feature working in production |
| OBS-5 | 5 | app | Alerts fire on a change from baseline for the app's key flows, not only on downtime |

## Security and CI

| ID | L | Scope | Passes when |
|---|---|---|---|
| SEC-1 | 2 | repo | CI runs on every pull request |
| SEC-2 | 2 | repo | The default branch requires CI to pass before merge (FAIL with the reason when the plan doesn't offer it) |
| SEC-3 | 3 | repo | CI runs the same check command as local, with no check logic that exists only in CI |
| SEC-4 | 3 | repo | Secret scanning runs on commit or in CI and bites |
| SEC-5 | 3 | repo | The workflow audit (`gha-security-review`, or the equivalent for the CI system) reports no high-severity finding |
| SEC-6 | 3 | repo | Third-party actions are pinned to commit SHAs and workflows default to minimal token permissions, widened per job |
| SEC-7 | 3 | repo | Dependency and action updates are automated, grouped, with a release-age cooldown |
| SEC-8 | 3 | app | For a published package: each change carries release-note input, and publishing runs from CI with short-lived credentials (N/A when nothing publishes) |
| SEC-9 | 4 | repo | The median pull-request CI run over the last 20 finishes in under ~10 min |
| SEC-10 | 4 | app | For an app that deploys: merging deploys it automatically, and the deploy records the commit it shipped |
| SEC-11 | 5 | repo | Agents can open, babysit and land a change end to end: every gate is machine-checkable, and the merge rule is written down |
