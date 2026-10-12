# Devbox

You are on an always-on Linux devbox shared by many agent threads at once. You have full access. Logins here are revocable, but some reach production services.

- **Code:** less is more, for UI and code. Write the least code that does the job, idiomatic and reusing the repo's existing components. Don't overreach: oversized changes cause regressions and bloated diffs. Never edit generated files unless clearly told to.
  - **Scope:** deliver what was asked at the scope intended. Mention adjacent fixes, refactors and docs instead of doing them; if the request looks wrong, say so and still do it as asked.
  - **Tests:** never weaken, skip or delete a test, special-case test inputs or hard-code expected outputs to get green. If a test looks wrong, leave it and say why.
  - **Errors:** no broad catches, swallowed errors or success-shaped fallbacks (a `catch` returning empty, defaults on required data). Validate once at trust boundaries; trust internal code.
  - **Internal APIs:** when you change one, update every caller and delete the old path in the same change. No compatibility shims unless something outside the repo depends on it.
  - **Scratch:** delete scripts and temp files you created once they have served their purpose.
- **Dev servers:** run them through Portless (`portless run <command>`, adding `--name <app>` if needed) so each gets a free port and its own URL: `https://<app>.localhost` in the main checkout, `https://<branch>.<app>.localhost` in a worktree. Never use `--force`; it kills another thread's server. Bind to localhost or the tailnet only; never expose anything publicly.
- **Browser checks:** use `agent-browser --session <worktree-name>`, and close your session when done. Never touch other sessions.
- **Shared machine:** never stop or restart Docker, Tailscale, T3 Code, the Portless proxy or another project's containers. Kill only processes you started; never `pkill` or `killall` by name.
- **Secrets:** never print, log or commit secret values.
- **Global tools:**
  - rg, fd, jq (JSON), yq (YAML, TOML, XML, HCL, INI, CSV), ast-grep, just, psql, gh and uv are installed. Node comes from `vp`, Python from `uv`, Rust from `rustup`.
  - Library docs: `ctx7 library <name> "<question>"`, then `ctx7 docs <id> "<question>"`.
- **Project services:** CLIs are installed and logged in; use one only when the project uses that service.
  - Cloudflare: `cf`, or wrangler if the project has a wrangler config. `cf` cancels destructive commands without `--force`, prints "Aborted." and still exits 0.
  - Sentry: `sentry`.
  - PostHog: `posthog-cli`. Run `posthog-cli api --agent-help` first, and `--dry-run` before any change.
  - Neon: the `neon` CLI to link a project, pull env and manage branches; the Neon MCP for SQL and schema on Neon-hosted databases.
- **Git and GitHub:** commit as the configured user, using Conventional Commits for commit messages and PR titles. Never add co-author trailers, "generated with" lines or any other AI or agent attribution to commits, pull requests, issues or comments.
