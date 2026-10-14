# dotfiles

My dotfiles and agent setup, plus the Terraform for the Linux box they mostly run on these days.

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply frangkli
```

It asks for your name and email up front, so you don't need to fork it to fix my git config. Macs skip the agent stuff.

- `home/`: configs, scripts, services, and the skills and hooks my agents use.
- `infra/`: the box, a GCP VM set up with OpenTofu and cloud-init.

## Why

Agents get full access on an always-on VM so they can do as much as possible, and the guardrails live in the environment instead: no cloud identity, nothing outside my tailnet, daily disk snapshots. Maintained tools come before custom glue, and every pick had to beat the alternatives, including the ones I already used.

I don't run agents in a terminal, and I don't want one on my phone. I love the Codex app but wanted more models, more control and a better remote setup, so I use [T3 Code](https://github.com/pingdotgg/t3code): threads switch between Claude Code and Codex mid-conversation, reply with charts and diagrams, share a browser with me, and start other threads.

## The box

I usually have a dozen threads going at once, each in its own worktree.

- Agents get plain bash cuz I'm not the one using it: `.bashrc` returns early before aliases, so no surprises.
- `chezmoi apply` installs everything from apt, Homebrew and [mise](https://mise.jdx.dev); `devbox-update --apply` upgrades it.
- Every worktree gets its own HTTPS URL through [Portless](https://github.com/vercel-labs/portless), and agents test UI on that same URL.
- Every worktree gets its own Postgres database, cloned from a template on XFS over 30× faster than a copy.
- TypeScript tests run on [PGlite](https://pglite.dev) in-process, with no server to start.

## Skills

Process scales with the task, from nothing for a small fix to research through tickets for a new product:

- `council` asks five framings, has them review each other blind, and keeps the disagreements.
- `arena` judges competing builds against a rubric written before any of them started.
- `prevent-repeats` finds mistakes agents keep repeating and adds a check that fails on a real past one.
- `verify-create` generates a `verify` skill per project that drives the app the way a user would.
- `readiness` scores how well agents can work in a repo and fixes the gaps.
- `wait-what` makes the agent stop and re-pitch when its last message didn't land.

## Around the agents

- A docs hub serves every worktree's plans live, so agents reply with a link instead of starting a server.
- Agent commands are searchable in [atuin](https://atuin.sh), and sessions are kept for `retro` and `tune-up` to learn from.
- [AgentsView](https://github.com/wesm/agentsview) tracks sessions, cost and tool errors.
- A short global `AGENTS.md` keeps threads off each other's processes and dev servers.
- Secrets come from Infisical through [fnox](https://github.com/jdx/fnox) at run time, so no config file holds a key.
- `codex-trust-hooks` re-approves this repo's Codex hooks after every update.
- `claude-api` lets a thread at its Claude limit carry on with an API key.

## Old stuff

Older setups are on other branches if you're curious:

- [`macos-nvim`](https://github.com/frangkli/dotfiles/tree/macos-nvim): Just Neovim, built on kickstart-modular.nvim with bits of NvChad. 2026.
- [`windows-arch`](https://github.com/frangkli/dotfiles/tree/windows-arch): Arch Linux under WSL on a Windows 11 laptop, with zsh, Neovim and lf. 2022–2023.
- [`macos-2014`](https://github.com/frangkli/dotfiles/tree/macos-2014): A 2014 MacBook Air running yabai, plus dwm and st from [suckless.org](https://suckless.org) under XQuartz. Everything in the terminal, from mail to music, heavily inspired by Luke Smith. 2019–2020.
