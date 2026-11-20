local group = vim.api.nvim_create_augroup("config", { clear = true })
local autocmd = function(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", { group = group }, opts))
end

autocmd("TextYankPost", {
  desc = "Briefly highlight yanked text",
  callback = function()
    vim.hl.on_yank()
  end,
})

autocmd("FileType", {
  desc = "Don't continue comments on <CR> or o/O",
  callback = function()
    vim.opt_local.formatoptions:remove { "r", "o" }
  end,
})

autocmd("BufReadPost", {
  desc = "Reopen files at the last cursor position",
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lines = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lines and vim.bo[ev.buf].filetype ~= "gitcommit" then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("VimResized", {
  desc = "Keep splits equal when the terminal is resized",
  command = "tabdo wincmd =",
})
