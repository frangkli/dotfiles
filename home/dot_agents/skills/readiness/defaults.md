# Preferred defaults

Offer these as the recommended option when they fit the repo's stack and nothing it already uses does the job. They are defaults, not requirements: a repo that passes a criterion with other tools keeps its tools.

## Checks

- One `check` command per repo. When the repo mixes languages, a root `justfile` calls each stack's own runner.
- Every linter, type checker and compiler starts at its strictest setting and is loosened per rule, each with a reason in the config. Examples: oxlint type-aware with type checking and warnings denied, TypeScript `strict`; ruff with all rules plus ty; clippy pedantic with `-D warnings` plus cargo-deny.
- Per-stack config to offer and merge: TypeScript (tsconfig flags, Oxlint, Effect language service, React UI, pnpm) in [stacks/typescript.md](stacks/typescript.md).
- Unused code and dependencies: knip for TypeScript. Spelling: typos. Workflows: zizmor and actionlint. Secrets: gitleaks or betterleaks.
- UI projects add accessibility lint and import-boundary rules; published packages add publint and attw.
- Hooks: Vite+ hooks when the repo uses Vite+, otherwise lefthook (prek in Python-only repos). Fast staged checks and a secret scan on commit; CI is the real gate.
- Pins: `devEngines` and `.node-version`, `rust-toolchain.toml`, `.python-version`; a release-age cooldown for new dependency versions (pnpm's built-in `minimumReleaseAge`, uv `exclude-newer`).

## Dev environment

- The recipes `setup`, `teardown`, `check`, `fix`, `test <path>` and `dev`, in the repo's native runner, with a committed `t3.json` whose actions run `setup` on worktree creation and `teardown` on settle: [worktrees.md](worktrees.md).
- Backing services from prebuilt images, one container per project, one database per worktree cloned from a template database; app servers run natively. Postgres: [postgres.md](postgres.md).
- A per-worktree slug names the database, a block of ports and any per-worktree resources; a generated, git-ignored `.env.local` holds them.
- HTTP apps get a stable per-worktree hostname (Portless) instead of fixed ports.
- Secrets declared in a checked-in `fnox.toml` and injected with `fnox exec -- <command>`.

## CI and release

- GitHub Actions on Blacksmith runners, sized by job; cancel superseded runs.
- Actions pinned to SHAs, `permissions: {}` at the top of each workflow, widened per job.
- Pull-request workflows hold no secrets; deploy credentials live in a GitHub environment restricted to the default branch, and only jobs on that branch use it.
- Dependabot or Renovate for dependencies and actions, grouped, with a cooldown.
- A database branch per pull request with an expiry, when the project's database supports branching.
- Releases: changesets for release-note input, publishing through trusted publishing (OIDC) in CI, started by a manual workflow dispatch.

## Observability

For OBS-1 to OBS-8. Wide events from the first log line; the rest once the app has users or runs in production.

- Logs: one structured wide event per request or job, secrets redacted in the logger, shipped to Axiom.
- Traces: OpenTelemetry with the semantic conventions, trace ids in every log event, exported to Axiom. Effect projects use Effect's OpenTelemetry integration.
- Errors: Sentry, with source maps uploaded per release, request and user context, and its default grouping.
- Release markers: the deploy job creates a release in Sentry and an annotation in Axiom.
- Product analytics, session replay and feature flags: PostHog.
- Alerts on key flows from the Sentry, Axiom or PostHog data above.
- AI features only: OpenTelemetry GenAI conventions on every model call, sent to Langfuse.

## Verification and docs

- A `verify` skill made with `verify-create`; browser surfaces driven with agent-browser, with an axe scan and a console check per page.
- Review rules and Known non-issues in `REVIEW_RULES.md` at the repo root, linked from `AGENTS.md`, with each review bot pointed at it from its dashboard and no bot rules files in the repo (see [agent-docs.md](agent-docs.md)).
- `GLOSSARY.md` at the repo root: each domain term on one line with its meaning in this project, drawn from the code and docs, linked from `AGENTS.md`.
- React or JSX UIs: readiness flags a missing `PRODUCT.md` and `DESIGN.md` and writes neither. The owner runs `/impeccable init`, which interviews them and writes `PRODUCT.md`; `DESIGN.md` comes from impeccable's document step or its first build.
