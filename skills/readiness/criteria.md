# Readiness criteria

Each row is a question the repo passes or fails with evidence. **L** is the level the criterion counts toward; **Scope** is `repo` (scored once) or `app` (scored once per app). "Checker" rows pass only after a bite test ([bite-tests.md](bite-tests.md)).

Speed targets below are defaults. When the repo's `GATES.md` or `AGENTS.md` sets its own, use those and say so.

Keep the IDs stable: the next run matches verdicts by ID.

## Validation

The recommended config for a failing VAL-1, VAL-2, VAL-6 or VAL-7 is per stack: [stacks/typescript.md](stacks/typescript.md).

| ID | L | Scope | Passes when |
|---|---|---|---|
| VAL-1 | 1 | app | A linter is configured, runs from a documented command, and bites |
| VAL-2 | 1 | app | A type check or compile check runs and bites (N/A for languages with no static checker). Record strictness settings in the evidence; strictness itself doesn't decide the verdict |
| VAL-3 | 2 | app | A formatter has a check mode that fails on unformatted code |
| VAL-4 | 2 | repo | A commit hook runs fast checks on staged files, and a commit through it in the scratch worktree shows it ran |
| VAL-5 | 4 | app | Lint and type check of one changed file finish in under ~10 s, measured |
| VAL-6 | 2 | app | For a React or JSX UI: accessibility lint rules run at error level, the app's own components are mapped to the elements they render, and a missing `alt` on a mapped image component bites |
| VAL-7 | 3 | app | For a UI built on shadcn/ui: a design-system linter rejects restyled components, raw colours and arbitrary values, and bites |

## Build and checks

| ID | L | Scope | Passes when |
|---|---|---|---|
| BLD-1 | 1 | app | The app builds or starts from a documented command in a fresh worktree |
| BLD-2 | 2 | repo | One command runs every check (lint, types, tests, build) and exits non-zero when any fails |
| BLD-3 | 2 | repo | `GATES.md` lists each check command with what it covers and how long it takes, and maps the recipe names (`setup`, `teardown`, `check`, `fix`, `test <path>`, `dev`) to their commands; every listed command exists, and each timing is within 2x of a measured run |
| BLD-4 | 2 | repo | A lockfile is committed, CI installs from it frozen so a stale lockfile fails the run (`uv sync --locked`: plain `uv sync` re-locks after a `pyproject.toml` change; `--locked` on each cargo command, such as `cargo build --locked`), and the runtime and toolchain versions are pinned in files the tools read |
| BLD-5 | 3 | repo | `AGENTS.md` or `GATES.md` says to run the cheapest covering check while iterating and the full check only at ship points, and no instruction tells agents to run the full check before every hand-off |
| BLD-6 | 4 | repo | Checks can run per package or per app, so a unit's check doesn't need the whole repo |

## Testing

| ID | L | Scope | Passes when |
|---|---|---|---|
| TST-1 | 1 | app | Tests exist, run locally from one command with only documented setup, and fail when a tested behaviour is broken |
| TST-2 | 3 | app | An end-to-end or integration path drives each surface of the app (browser, HTTP, CLI) and runs locally or in CI |
| TST-3 | 4 | app | A fast subset (`test <path>`: one file or one package) runs in under ~30 s and `GATES.md` names it |
| TST-4 | 4 | repo | Flaky tests are detected or tracked: retries are reported, a quarantine list exists, or CI history is checked |
| TST-5 | 3 | app | For a React or JSX UI: component tests render into a DOM environment (happy-dom) and find elements by role or label, so an unnamed control fails a test |
| TST-6 | 3 | app | For a React or JSX UI: every test suite in the app (browser, visual, end-to-end included) runs in the check command or in CI; each suite that runs in neither is named in the evidence |
| TST-7 | 4 | app | For a shared component library: a real-browser test project runs an axe scan over the components in CI (N/A for an app that isn't a shared library) |

## Agent docs

| ID | L | Scope | Passes when |
|---|---|---|---|
| DOC-1 | 1 | repo | A README says what the repo is and how to start it |
| DOC-2 | 2 | repo | A root `AGENTS.md` exists, under ~60 lines (FAIL above 100), and every command and path in it exists |
| DOC-3 | 2 | repo | `AGENTS.md` points to `GATES.md`, the `verify` skill and the docs an agent needs, instead of restating config, listing installed skills or holding attribution rules |
| DOC-4 | 2 | app | The app's own commands are findable from the root `AGENTS.md` or a short `AGENTS.md` in the app folder (nested files only where commands differ) |
| DOC-5 | 3 | repo | `REVIEW_RULES.md` exists at the repo root and `AGENTS.md` links it, each rule names a concrete failing case, no bot rules file (`.cursor/BUGBOT.md`, `.greptile/`) duplicates it, and every review bot the repo uses reads it (the bot's comments cite it, or the user confirms the dashboard setting) |
| DOC-6 | 3 | repo | Both harnesses reach the instructions and project skills: Claude reads `AGENTS.md` (directly, or through a `CLAUDE.md` link or import) and `.claude/skills` resolves to `.agents/skills` |
| DOC-7 | 3 | repo | `GLOSSARY.md` lists the project's domain terms, one line each, every term appears in the code or docs, and `AGENTS.md` links it |
| DOC-8 | 3 | app | For a React or JSX UI: `PRODUCT.md` exists, and `DESIGN.md` exists once the UI has a visual system in code |

## Dev environment

The recipe contract, the T3 Code actions and the cleanup rules are in [worktrees.md](worktrees.md); the Postgres layout is in [postgres.md](postgres.md).

| ID | L | Scope | Passes when |
|---|---|---|---|
| ENV-1 | 2 | repo | One idempotent `setup` command brings a fresh worktree to runnable (dependencies, services, env, database), holds a lock so two runs never interleave, and a second run changes nothing |
| ENV-2 | 2 | app | Every environment variable the app reads is declared in a template or secrets manifest; a grep of reads against it finds no undeclared name |
| ENV-3 | 2 | repo | Secrets are injected by a documented command; none are committed |
| ENV-4 | 3 | repo | Two worktrees run their full stacks at once without sharing a port, database or data directory, shown by running setup in two scratch worktrees |
| ENV-5 | 4 | repo | Setup on a fresh worktree takes under ~10 s (first install and image pull excluded), under ~2 s when already up, and teardown under ~5 s, measured |
| ENV-6 | 4 | repo | A new T3 Code worktree is runnable with no manual step: the committed `t3.json` setup action's command, run in a fresh `git worktree add` scratch worktree, brings it to runnable, and the owner confirms the action is imported in T3's project settings |
| ENV-7 | 4 | repo | Settling a T3 thread runs `teardown` (the `t3.json` action with `runOnSettle: true`). In a scratch worktree with `dev` running, teardown first stops the processes whose working directory is inside that worktree, then drops its per-worktree resources. `setup` in another worktree drops the leftovers of a removed worktree of this project and touches nothing else, printing each action |

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

N/A for an app that never runs as a process (a library). CLIs count only when they report usage or errors somewhere. OBS-1 applies from the app's first log line; the other rows are N/A until the app has users or runs in production, and the N/A evidence says which. Every row sits at level 4 or 5, so none blocks the level 3 target. Backends to recommend: [defaults.md](defaults.md).

| ID | L | Scope | Passes when |
|---|---|---|---|
| OBS-1 | 4 | app | Each request or job emits one structured wide event carrying the request id, trace id, release and user context, and a fake secret written to a log is redacted before it leaves the process |
| OBS-2 | 4 | app | Traces follow the OpenTelemetry semantic conventions, their trace ids appear in the logs, and they reach a backend that an agent can query from the box with a CLI or API, documented in the repo |
| OBS-3 | 4 | app | Errors reach an error tracker with source-mapped stacks, the release, and request and user context, deduplicated into issues |
| OBS-4 | 5 | app | For each mapped feature, the repo names the telemetry query that shows the feature working in production |
| OBS-5 | 5 | app | Alerts fire on a change from baseline for the app's key flows, not only on downtime |
| OBS-6 | 4 | app | Each production deploy records a release marker in the error tracker and the telemetry backend, from the first production deploy |
| OBS-7 | 5 | app | For an app with users: product analytics, session replay and feature flags run through one product tool |
| OBS-8 | 4 | app | For an app with AI features: each model call is traced with the OpenTelemetry GenAI conventions (model, tokens, latency, cost) to an LLM observability backend (N/A without AI features) |

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
| SEC-12 | 3 | repo | The package manager's supply-chain guards are on: for pnpm, `pnpm-workspace.yaml` sets `trustPolicy: no-downgrade`, only packages that need build scripts are in `allowBuilds`, and no file turns a default guard off ([stacks/typescript.md](stacks/typescript.md)) |
| SEC-13 | 3 | repo | Pull-request workflows run without secrets (no secret references in PR-triggered jobs, no `pull_request_target` job that checks out the PR head), and deploy credentials live in a GitHub environment restricted to the default branch |
