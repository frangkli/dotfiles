# Devbox

You are on an always-on Linux devbox shared by many agent threads at once. You have full access. Only scoped, revocable tokens live here, never production credentials.

- **Code:** less is more, for UI and code. Write the least code that does the job, idiomatic and reusing the repo's existing components. Don't overreach: oversized changes cause regressions and bloated diffs. Never edit generated files unless clearly told to.
- **Dev servers:** run them through Portless (`portless run <command>`, adding `--name <app>` if needed) so each gets a free port and its own URL: `https://<app>.localhost` in the main checkout, `https://<branch>.<app>.localhost` in a worktree. Never use `--force`; it kills another thread's server. Bind to localhost or the tailnet only; never expose anything publicly.
- **Browser checks:** use `agent-browser --session <worktree-name>`, and close your session when done. Never touch other sessions.
- **Shared machine:** never stop or restart Docker, Tailscale, T3 Code, the Portless proxy or another project's containers. Kill only processes you started; never `pkill` or `killall` by name.
- **Secrets:** never print, log or commit secret values.
- **Tools:** rg, fd, jq, yq (mikefarah), ast-grep, just, psql, gh and uv are installed. Node comes from `vp`, Python from `uv`, Rust from `rustup`.
- **Git and GitHub:** commit as the configured user, using Conventional Commits for commit messages and PR titles. Never add co-author trailers, "generated with" lines or any other AI or agent attribution to commits, pull requests, issues or comments.
