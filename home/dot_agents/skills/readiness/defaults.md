# Preferred defaults

Offer these as the recommended option when they fit the repo's stack and nothing it already uses does the job. They are defaults, not requirements: a repo that passes a criterion with other tools keeps its tools.

## Checks

- One `check` command per repo. When the repo mixes languages, a root `justfile` calls each stack's own runner.
- Every linter, type checker and compiler starts at its strictest setting and is loosened per rule, each with a reason in the config. Examples: oxlint type-aware with type checking and warnings denied, TypeScript `strict`; ruff with all rules plus ty; clippy pedantic with `-D warnings` plus cargo-deny.
- Per-stack config to offer and merge: TypeScript (tsconfig flags, Oxlint, Effect language service) in [stacks/typescript.md](stacks/typescript.md).
- Unused code and dependencies: knip for TypeScript. Spelling: typos. Workflows: zizmor and actionlint. Secrets: gitleaks or betterleaks.
- UI projects add accessibility lint and import-boundary rules; published packages add publint and attw.
- Hooks: Vite+ hooks when the repo uses Vite+, otherwise lefthook (prek in Python-only repos). Fast staged checks and a secret scan on commit; CI is the real gate.
- Pins: `devEngines` and `.node-version`, `rust-toolchain.toml`, `.python-version`; a release-age cooldown for new dependency versions (pnpm `minimumReleaseAge`, uv `exclude-newer`).

## Dev environment

- One idempotent `just up` and a `just down`, triggered when a worktree is created.
- Backing services from prebuilt images, one container per project, one database per worktree cloned from a template database; app servers run natively.
- A per-worktree slug names the database, a block of ports and any per-worktree resources; a generated, git-ignored `.env.local` holds them.
- HTTP apps get a stable per-worktree hostname (Portless) instead of fixed ports.
- Secrets declared in a checked-in `fnox.toml` and injected with `fnox exec -- <command>`.

## CI and release

- GitHub Actions on Blacksmith runners, sized by job (small for `check`, larger for end-to-end and visual regression); cancel superseded runs.
- Actions pinned to SHAs, `permissions: {}` at the top of each workflow, widened per job.
- Dependabot or Renovate for dependencies and actions, grouped, with a cooldown.
- A database branch per pull request with an expiry, when the project's database supports branching.
- Releases: changesets for release-note input, publishing through trusted publishing (OIDC) in CI, started by a manual workflow dispatch.

## Verification and docs

- A `verify` skill made with `verify-create`; browser surfaces driven with agent-browser.
- Review rules and Known non-issues in `REVIEW_RULES.md` at the repo root, linked from `AGENTS.md`, with each review bot pointed at it from its dashboard and no bot rules files in the repo (see [agent-docs.md](agent-docs.md)).
