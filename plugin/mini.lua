-- mini.nvim: one plugin, many small modules. Only the ones below are enabled.
local map = vim.keymap.set

-- Icons (also used by fzf-lua, blink and the statusline)
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

-- Statusline: mode, git branch + diff, diagnostics, LSP, file, position.
-- Customize by passing `content = { active = function() ... end }`. See :h MiniStatusline
require("mini.statusline").setup()

-- Better text objects: a/i + ) ] } ' " ` q (quote) b (bracket) f (function call) a (argument) t (tag)
-- (Selecting a whole function/block by syntax: visual mode `an` / `in`, built into 0.12)
require("mini.ai").setup { n_lines = 500 }

-- Surround: gsa (add), gsd (delete), gsr (replace). `s` itself is used by flash.
require("mini.surround").setup {
  mappings = {
    add = "gsa",
    delete = "gsd",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
    replace = "gsr",
    suffix_last = "l",
    suffix_next = "n",
  },
}

-- Auto-close brackets and quotes. To turn off: delete this line.
require("mini.pairs").setup { modes = { insert = true, command = false, terminal = false } }

-- Highlight TODO/FIXME/HACK/NOTE and hex colors like #c4746e
local hipatterns = require "mini.hipatterns"
hipatterns.setup {
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
}

-- Git: :Git <anything> runs in the repo root; commit messages open in a buffer
require("mini.git").setup()

-- Close a buffer without closing its window
require("mini.bufremove").setup()
map("n", "<leader>bd", function()
  MiniBufremove.delete()
end, { desc = "Delete buffer" })
map("n", "<leader>bo", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= vim.api.nvim_get_current_buf() and vim.bo[buf].buflisted then
      MiniBufremove.delete(buf)
    end
  end
end, { desc = "Delete other buffers" })

-- File explorer: columns view; edit names like text, then `=` to apply
require("mini.files").setup { windows = { preview = true, width_preview = 50 } }
map("n", "<leader>e", function()
  local path = vim.api.nvim_buf_get_name(0)
  MiniFiles.open(vim.uv.fs_stat(path) and path or nil)
  MiniFiles.reveal_cwd()
end, { desc = "File explorer (current file)" })
map("n", "<leader>E", function()
  MiniFiles.open()
end, { desc = "File explorer (project root)" })

-- Sessions: one per project directory, stored in stdpath("data")/session
require("mini.sessions").setup { autowrite = true }
local session_name = function()
  return vim.fn.getcwd():gsub("[/\\:]", "%%") .. ".vim"
end
map("n", "<leader>ss", function()
  MiniSessions.write(session_name())
end, { desc = "Save session" })
map("n", "<leader>sl", function()
  MiniSessions.read(session_name())
end, { desc = "Load session for this directory" })
map("n", "<leader>sf", function()
  MiniSessions.select "read"
end, { desc = "Find session" })
map("n", "<leader>sd", function()
  MiniSessions.select "delete"
end, { desc = "Delete a session" })

-- Key hints: press a prefix key and wait to see what follows it
local clue = require "mini.clue"
clue.setup {
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
    { mode = { "n", "x" }, keys = "<LocalLeader>" },
    { mode = { "n", "x" }, keys = "g" },
    { mode = { "n", "x" }, keys = "z" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = { "n", "x" }, keys = "'" },
    { mode = { "n", "x" }, keys = "`" },
    { mode = { "n", "x" }, keys = '"' },
    { mode = { "i", "c" }, keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
    { mode = "i", keys = "<C-x>" },
  },
  clues = {
    { mode = "n", keys = "<Leader>b", desc = "+Buffers" },
    { mode = "n", keys = "<Leader>c", desc = "+Code" },
    { mode = "n", keys = "<Leader>f", desc = "+Find" },
    { mode = "n", keys = "<Leader>g", desc = "+Git" },
    { mode = "x", keys = "<Leader>g", desc = "+Git" },
    { mode = "n", keys = "<Leader>s", desc = "+Sessions" },
    { mode = "n", keys = "<Leader>t", desc = "+Toggles" },
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.square_brackets(),
    clue.gen_clues.windows { submode_resize = true },
    clue.gen_clues.z(),
  },
  window = { delay = 300, config = { width = "auto" } },
}
