-- flash: press `s`, type a character or two, then the label shown at the target.
--   S       select a syntax node (function, block, ...) by label
--   r       (after an operator, e.g. `yr`) act on a distant spot and come back
--   /, ?    labels also appear during normal search; <C-s> toggles that
--   f F t T jump across lines; repeat with f / ; ,
require("flash").setup { modes = { search = { enabled = true } } }
local map = vim.keymap.set
map({ "n", "x", "o" }, "s", function()
  require("flash").jump()
end, { desc = "Flash jump" })
map({ "n", "x", "o" }, "S", function()
  require("flash").treesitter()
end, { desc = "Flash select node" })
map("o", "r", function()
  require("flash").remote()
end, { desc = "Flash remote" })
map({ "o", "x" }, "R", function()
  require("flash").treesitter_search()
end, { desc = "Flash search node" })
map("c", "<C-s>", function()
  require("flash").toggle()
end, { desc = "Toggle flash in search" })

-- grug-far: project-wide search and replace with a live preview (ripgrep)
require("grug-far").setup { headerMaxWidth = 80 }
map("n", "<leader>r", function()
  require("grug-far").open()
end, { desc = "Search & replace (project)" })
map("x", "<leader>r", function()
  require("grug-far").with_visual_selection()
end, { desc = "Search & replace selection" })
map("n", "<leader>R", function()
  require("grug-far").open { prefills = { paths = vim.fn.expand "%" } }
end, { desc = "Search & replace (this file)" })
