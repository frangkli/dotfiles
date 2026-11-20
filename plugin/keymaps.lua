-- Core keymaps. Plugin keymaps live next to each plugin's config in plugin/.
-- Press <Space> (or g, z, [, ], <C-w>, ...) and wait to see what's available.
local map = vim.keymap.set

map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Move between Neovim splits without the <C-w> prefix
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Keep the selection after indenting
map("x", "<", "<gv")
map("x", ">", ">gv")

-- `c` changes text without overwriting the last yank
map({ "n", "x" }, "c", '"_c')

-- Quickfix / location list
local function toggle_list(kind)
  local open = vim.iter(vim.fn.getwininfo()):any(function(w)
    return kind == "qf" and w.quickfix == 1 and w.loclist == 0 or kind == "loc" and w.loclist == 1
  end)
  if kind == "qf" then
    vim.cmd(open and "cclose" or "copen")
  else
    local ok, err = pcall(vim.cmd, open and "lclose" or "lopen")
    if not ok then
      vim.notify(err:gsub("^.-:", ""), vim.log.levels.WARN)
    end
  end
end
map("n", "<leader>q", function()
  toggle_list "qf"
end, { desc = "Toggle quickfix list" })
map("n", "<leader>l", function()
  toggle_list "loc"
end, { desc = "Toggle location list" })

-- Toggles
map("n", "<leader>tf", function()
  vim.g.autoformat = vim.g.autoformat == false
  vim.notify("Format on save " .. (vim.g.autoformat and "on" or "off"))
end, { desc = "Toggle format on save" })
map("n", "<leader>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })
map("n", "<leader>td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })
map("n", "<leader>tw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle line wrap" })

-- Built-in optional plugins, loaded on first use
map("n", "<leader>u", function()
  vim.cmd.packadd "nvim.undotree"
  vim.cmd "Undotree"
end, { desc = "Undo tree" })
