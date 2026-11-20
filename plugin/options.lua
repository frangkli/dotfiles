local o = vim.o

-- Display
o.number = true
o.relativenumber = true
o.cursorline = true
o.cursorlineopt = "number" -- highlight only the current line number
o.signcolumn = "yes" -- always show, so text never shifts
o.laststatus = 3 -- one statusline for the whole editor
o.showmode = false -- the statusline shows the mode
o.scrolloff = 8
o.sidescrolloff = 8
o.wrap = false -- markdown/text turn it back on (after/ftplugin)
o.linebreak = true -- when wrapping, break between words
o.breakindent = true
o.list = true
o.listchars = "tab:» ,trail:·,nbsp:␣"
o.fillchars = "eob: ,fold: ,foldopen:\u{f47c},foldclose:\u{f460},foldsep: "
o.winborder = "rounded" -- borders on hover, diagnostics and other floats
o.pumborder = "rounded"
o.title = true -- terminal / tab title shows the current file
o.titlestring = "%t%( %M%) — nvim"
o.shortmess = o.shortmess .. "I" -- no intro screen

-- Editing
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.ignorecase = true
o.smartcase = true
o.inccommand = "split" -- live preview of :s substitutions
o.confirm = true -- ask instead of failing on :q with unsaved changes
o.undofile = true -- persistent undo, stored in stdpath("state")/undo
o.updatetime = 250
o.timeoutlen = 400
o.splitbelow = true
o.splitright = true
o.splitkeep = "screen"
o.virtualedit = "block"

-- Folding: treesitter sets foldexpr per buffer; everything starts open
o.foldlevel = 99
o.foldlevelstart = 99
o.foldtext = ""

-- Share the macOS clipboard (set after startup, it's slow to initialize)
vim.schedule(function()
  o.clipboard = "unnamedplus"
end)

-- No plugins here are written in Python/Node/Perl/Ruby: skip those hosts
for _, p in ipairs { "python3", "node", "perl", "ruby" } do
  vim.g["loaded_" .. p .. "_provider"] = 0
end

-- Diagnostics
vim.diagnostic.config {
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 2, source = "if_many" },
  float = { source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚",
      [vim.diagnostic.severity.WARN] = "󰀪",
      [vim.diagnostic.severity.INFO] = "󰋽",
      [vim.diagnostic.severity.HINT] = "󰌶",
    },
  },
}
