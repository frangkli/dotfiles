local autocmd = vim.api.nvim_create_autocmd

vim.opt.relativenumber = true
vim.g.mapleader = ","

autocmd("TermOpen", {
  pattern = "*",
  command = "setlocal nonumber norelativenumber"
})
