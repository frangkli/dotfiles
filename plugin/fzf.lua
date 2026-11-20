-- fzf-lua: fuzzy finder for files, grep, buffers, LSP, git, and more.
-- Inside a picker: <F1> shows its keys; <Tab> multi-select; <M-q> sends to quickfix;
-- <C-v>/<C-s>/<C-t> open in vsplit/split/tab. In git status: <Left> stage, <Right> unstage.
local fzf = require "fzf-lua"
fzf.setup {
  "border-fused",
  winopts = { height = 0.85, width = 0.85, preview = { layout = "flex", flip_columns = 140 } },
  files = { formatter = "path.filename_first", cwd_prompt = false },
  grep = { formatter = "path.filename_first" },
  oldfiles = { include_current_session = true, cwd_only = true },
  lsp = { jump1 = true }, -- jump straight there when there's only one result
}
fzf.register_ui_select() -- use fzf-lua for vim.ui.select (code actions, etc.)

local map = vim.keymap.set
-- Most-used
map("n", "<leader><space>", fzf.files, { desc = "Find files" })
map("n", "<leader>,", fzf.buffers, { desc = "Open buffers" })
map("n", "<leader>/", fzf.live_grep, { desc = "Grep project" })

-- <leader>f: find
map("n", "<leader>ff", fzf.files, { desc = "Files" })
map("n", "<leader>fo", fzf.oldfiles, { desc = "Recent files (this project)" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>fg", fzf.live_grep, { desc = "Grep" })
map("n", "<leader>fw", fzf.grep_cword, { desc = "Grep word under cursor" })
map("x", "<leader>fw", fzf.grep_visual, { desc = "Grep selection" })
map("n", "<leader>f/", fzf.lgrep_curbuf, { desc = "Grep current buffer" })
map("n", "<leader>fr", fzf.resume, { desc = "Resume last picker" })
map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Diagnostics (file)" })
map("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Diagnostics (project)" })
map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Symbols (file)" })
map("n", "<leader>fS", fzf.lsp_live_workspace_symbols, { desc = "Symbols (project)" })
map("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps" })
map("n", "<leader>fh", fzf.helptags, { desc = "Help" })
map("n", "<leader>fc", fzf.commands, { desc = "Commands" })
map("n", "<leader>f:", fzf.command_history, { desc = "Command history" })
map("n", "<leader>fq", fzf.quickfix, { desc = "Quickfix list" })
map("n", "<leader>fn", function()
  fzf.files { cwd = vim.fn.stdpath "config" }
end, { desc = "Neovim config files" })
map("n", "<leader>fp", fzf.builtin, { desc = "All pickers" })

-- <leader>g: git pickers (gitsigns and mini.git add the rest in plugin/git.lua)
map("n", "<leader>gs", fzf.git_status, { desc = "Status (changed files)" })
map("n", "<leader>gb", fzf.git_branches, { desc = "Branches (switch)" })
map("n", "<leader>gl", fzf.git_commits, { desc = "Log" })
map("n", "<leader>gL", fzf.git_bcommits, { desc = "Log (this file)" })
map("n", "<leader>gS", fzf.git_stash, { desc = "Stashes" })
