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

autocmd({ "FocusGained", "BufEnter", "TermClose", "TermLeave" }, {
  desc = "Reload files changed outside Neovim (git, formatters, agents)",
  callback = function()
    if vim.o.buftype ~= "nofile" and vim.fn.getcmdwintype() == "" then
      vim.cmd "checktime"
    end
  end,
})
autocmd("FileChangedShellPost", {
  desc = "Say when a file was reloaded",
  callback = function(ev)
    vim.notify("Reloaded " .. vim.fn.fnamemodify(ev.file, ":~:."), vim.log.levels.INFO)
  end,
})

-- After a big jump (search, gd, <C-o>, flash, ...) briefly highlight the
-- cursor's line and column so it's easy to spot where you landed.
local flash_timer = assert(vim.uv.new_timer())
local last_line = 0
autocmd("CursorMoved", {
  desc = "Briefly highlight the cursor position after a big jump",
  callback = function()
    local line = vim.fn.line "."
    local jumped = math.abs(line - last_line) >= 10
    last_line = line
    if not jumped or vim.bo.buftype ~= "" then
      return
    end
    local win = vim.api.nvim_get_current_win()
    vim.wo[win].cursorcolumn = true
    vim.wo[win].cursorlineopt = "both"
    flash_timer:stop()
    flash_timer:start(400, 0, vim.schedule_wrap(function()
      if vim.api.nvim_win_is_valid(win) then
        vim.wo[win].cursorcolumn = false
        vim.wo[win].cursorlineopt = "number"
      end
    end))
  end,
})
