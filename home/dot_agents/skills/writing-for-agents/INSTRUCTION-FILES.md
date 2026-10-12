# Instruction files

The `AGENTS.md` / `CLAUDE.md` branch of [`writing-for-agents`](SKILL.md). These files are always loaded, so every line pays context load on every turn.

- Keep the root `AGENTS.md` under about 60 lines. Past 100, disclose: move material into docs it points at.
- Make `CLAUDE.md` a symlink to `AGENTS.md`, or a one-line pointer (`@AGENTS.md`) followed by the few Claude-only lines. One source of truth, read by every harness.
- Add a nested `AGENTS.md` only where a subtree's commands or rules differ from the root. It holds just the difference and stays shorter than the root; the closest file wins.
- Give file-scoped test, lint, and type-check commands, in a table when there are several. A full build appears only where no narrower command exists. Confirm every command and path exists before writing it down.
- Point at the repo's existing docs (setup, architecture, release, security) by repo-relative path, and leave their content there.
- The harness already lists installed skills and plugins, and the linter and formatter configs already state their rules: both stay out of the file.
