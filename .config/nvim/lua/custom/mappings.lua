---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<F2>"] = { ":read ~/.local/share/cp.cpp<CR>kdd38j", "read CP template", opts = { nowait = true } },
    ["<leader>c"] = { ":w! | !compiler '<c-r>%'<CR>", "run compiler script", opts = { nowait = true } },
  },
  v = {
    ["<"] = { "<gv", "better tabbing", opts = { nowait = true } },
    [">"] = { ">gv", "better tabbing", opts = { nowait = true } },
  }
}

-- more keybinds!

return M
