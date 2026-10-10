# dotfiles

My dotfiles, plus the Terraform for the box they mostly run on these days: a Linux VM I leave running for coding agents.

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply frangkli
```

It asks for your name and email the first time, so you don't have to fork it just to fix my git config. Macs get everything except the agent stuff.

## What's in here

- `home/`: everything chezmoi puts in `~`. Bash, git, jj, tmux and the agent config.
- `infra/`: the box. One GCP VM, set up with OpenTofu and cloud-init. It's a snapshot, so it may lag behind what I actually run.

## The box

Coding agents run on it all day, a dozen threads at a time. I check in from my laptop or phone.

- Agents get a plain shell. Claude Code and Codex load your shell config into every command, so aliases leak in. `.bashrc` bails out early for them.
- One `chezmoi apply` sets up everything. Boring tools come from apt or Homebrew, fast-moving ones from [mise](https://mise.jdx.dev), and both lists live in this repo.
- Every worktree gets its own URL through [Portless](https://github.com/vercel-labs/portless), like `https://fix-login.app.localhost`, so a dozen dev servers never fight over port 3000.
## Old stuff

Older setups are on other branches if you're curious:

- [`macos-nvim`](https://github.com/frangkli/dotfiles/tree/macos-nvim): Just Neovim, built on kickstart-modular.nvim with bits of NvChad. 2026.
- [`windows-arch`](https://github.com/frangkli/dotfiles/tree/windows-arch): Arch Linux under WSL on a Windows 11 laptop, with zsh, Neovim and lf. 2022–2023.
- [`macos-2014`](https://github.com/frangkli/dotfiles/tree/macos-2014): A 2014 MacBook Air running yabai, plus dwm and st from [suckless.org](https://suckless.org) under XQuartz. Everything in the terminal, from mail to music, heavily inspired by Luke Smith. 2019–2020.
