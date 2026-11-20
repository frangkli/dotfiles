# nvim

Minimal Neovim 0.12 config. Plugins are managed by the built-in `vim.pack`
(pinned in `nvim-pack-lock.json`). No AI completion.

## Layout

```
init.lua                 leader keys, plugin list (vim.pack.add), :PackUpdate / :PackClean
plugin/options.lua       editor options, diagnostics display
plugin/keymaps.lua       core keymaps and <leader>t toggles
plugin/autocmds.lua      yank highlight, cursor restore, ...
plugin/<topic>.lua       one file per plugin area (lsp, completion, format, fzf, git, mini, ...)
after/ftplugin/*.lua     per-filetype tweaks (markdown wraps lines)
```

Everything in `plugin/` is loaded automatically. To drop a feature, delete its file
(or lines) and its entry in `init.lua`, then run `:PackClean`.

## Plugins (17)

| Plugin | Does |
| --- | --- |
| kanagawa | Theme (`kanagawa-dragon`; also `-wave`, `-lotus`) |
| mini.nvim | Statusline, file explorer, `:Git`, key hints, text objects, surround, pairs, sessions, icons, TODO/color highlights |
| fzf-lua | Fuzzy finder: files, grep, buffers, LSP, git, keymaps, help |
| flash | Jump anywhere on screen with labels |
| grug-far | Project-wide search & replace with preview |
| nvim-lspconfig + mason + mason-lspconfig | Language server configs + installer |
| SchemaStore | JSON/YAML schemas (package.json, tsconfig, workflows, ...) |
| lazydev | Neovim API completion when editing this config |
| blink.cmp | Completion menu (LSP + paths) |
| conform | Format on save (oxfmt / biome / stylua, else LSP) |
| nvim-treesitter (+context, ts-autotag) | Parsers, sticky function header, auto-close tags |
| gitsigns | Git change markers, hunks, blame |
| render-markdown | Styled markdown in the buffer |

Language servers: vtsls, astro, svelte, tailwindcss, oxlint/biome, jsonls, yamlls,
lua_ls, gopls, rust_analyzer, pyrefly, marksman, harper_ls (see `plugin/lsp.lua`).

## Keys

Leader is `<Space>`. Press any prefix and wait for a popup of what follows;
`<Space>fk` searches every keymap.

| Keys | Action |
| --- | --- |
| `<Space><Space>` / `<Space>,` / `<Space>/` | Find files / buffers / grep |
| `<Space>f…` | Find: `o` recent, `w` word, `r` resume, `d` diagnostics, `s`/`S` symbols, `k` keymaps, `h` help, `n` config files |
| `<Space>e` / `<Space>E` | File explorer at current file / project root (`=` applies edits) |
| `s` / `S` | Flash jump / select syntax node |
| `<Space>r` / `<Space>R` | Search & replace in project / this file |
| `K` | Hover: type info and docs |
| `gd` `gD` `grr` `gri` `grt` `gO` | Definition, declaration, references, implementations, type definition, symbols |
| `grn` / `gra` | Rename / code action |
| `[d` `]d` / `<C-w>d` | Prev/next diagnostic / show diagnostic |
| `<Space>cf` | Format |
| `<Space>g…` | Git: `s` status, `c` commit, `a` amend, `b` branches, `l`/`L` log, `h` stage hunk, `r` reset hunk, `p` preview, `k` blame line, `K` blame file, `d` diff, `P` push, `F` pull |
| `]h` `[h` / `ih` | Next/prev git hunk / hunk text object |
| `gsa` `gsd` `gsr` | Surround add / delete / replace |
| `,l` (markdown) | Make link: on a URL like `astro.build`, or on selected text (uses a URL from the clipboard, else asks) |
| `<Space>t…` | Toggles: `f` format on save, `h` inlay hints, `d` diagnostics, `w` wrap, `b` inline blame, `m` markdown rendering |
| `<Space>s…` | Sessions: `s` save, `l` load (this dir), `f` find, `d` delete |
| `<Space>bd` / `<Space>bo` | Delete buffer / other buffers |
| `<Space>q` / `<Space>l` | Toggle quickfix / location list |
| `<Space>u` | Undo tree |
| `<C-h/j/k/l>` | Move between splits |
| Insert: `<CR>` `<C-j>` `<C-k>` `<C-space>` | Accept / next / prev / open completion |

## Maintenance

- `:PackUpdate`: review plugin updates, `:w` to apply. Commit `nvim-pack-lock.json`.
- `:PackClean`: remove plugins no longer listed in `init.lua`.
- `:Mason`: language servers and formatters. `:checkhealth` for problems.

Requires: Neovim ≥ 0.12, git, `tree-sitter` CLI, a C compiler, ripgrep, fd, fzf ≥ 0.53,
a Nerd Font in the terminal.
