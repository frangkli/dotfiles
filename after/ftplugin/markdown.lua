-- Prose: wrap long lines at word boundaries and move by screen line.
-- (List, checkbox and link editing come from markdown-plus: plugin/markdown.lua)
vim.opt_local.wrap = true
vim.keymap.set({ "n", "x" }, "j", "v:count ? 'j' : 'gj'", { buffer = true, expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count ? 'k' : 'gk'", { buffer = true, expr = true })
