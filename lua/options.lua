local opt = vim.opt
local o = vim.o
local g = vim.g

-------------------------------------------------------------------------------
-- UI & Appearance
-------------------------------------------------------------------------------
o.laststatus = 3
o.termguicolors = true
o.splitkeep = "screen"
o.showmode = false

-------------------------------------------------------------------------------
-- Cursor & Lines
-------------------------------------------------------------------------------
o.cursorline = true
o.cursorlineopt = "number"
o.relativenumber = true
o.numberwidth = 2
o.ruler = false
o.signcolumn = "yes"
o.showcmd = true
o.scrolloff = 10

-------------------------------------------------------------------------------
-- Indentation
-------------------------------------------------------------------------------
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.smartindent = true

-------------------------------------------------------------------------------
-- Input & Interaction
-------------------------------------------------------------------------------
o.mouse = "a"
o.timeoutlen = 400

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"

-- preview substitutions live, as you type
vim.o.inccommand = "split"

-------------------------------------------------------------------------------
-- Search
-------------------------------------------------------------------------------
o.hlsearch = true
o.incsearch = true

-- case-insensitive searching UNLESS \C or one or more capital letters in the search term
o.ignorecase = true
o.smartcase = true

-------------------------------------------------------------------------------
-- File Handling & System
-------------------------------------------------------------------------------
o.swapfile = false
o.backup = false

-- save undo history
o.undodir = os.getenv "HOME" .. "/.config/nvim/undodir"
o.undofile = true

-- interval for writing swap file to disk, also used by gitsigns
o.updatetime = 250

-- pane behavior
o.splitbelow = true
o.splitright = true

-- disable nvim intro
opt.shortmess:append "sI"

-- disable netrw
-- g.loaded_netrw = 1
-- g.loaded_netrwPlugin = 1

-------------------------------------------------------------------------------
-- Plugin & Provider Settings
-------------------------------------------------------------------------------
-- disable some default providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- add binaries installed by mason.nvim to path
local is_windows = vim.fn.has "win32" ~= 0
local sep = is_windows and "\\" or "/"
local delim = is_windows and ";" or ":"
vim.env.PATH = table.concat({ vim.fn.stdpath "data", "mason", "bin" }, sep) .. delim .. vim.env.PATH

-------------------------------------------------------------------------------
-- Autocommands
-------------------------------------------------------------------------------
-- disable auto commenting
vim.cmd [[autocmd FileType * set formatoptions-=ro]]
