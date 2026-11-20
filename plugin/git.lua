-- gitsigns: change markers, hunk staging, blame, inline diff.
-- mini.git (plugin/mini.lua) provides :Git; fzf-lua (plugin/fzf.lua) the git pickers.
local gs = require "gitsigns"
gs.setup {
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "▁" },
    topdelete = { text = "▔" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },
  signs_staged = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "▁" },
    topdelete = { text = "▔" },
    changedelete = { text = "▎" },
  },
  current_line_blame_opts = { delay = 300 },
  on_attach = function(buf)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    map("n", "]h", function()
      if vim.wo.diff then
        return vim.cmd.normal { "]c", bang = true }
      end
      gs.nav_hunk "next"
    end, "Next git hunk")
    map("n", "[h", function()
      if vim.wo.diff then
        return vim.cmd.normal { "[c", bang = true }
      end
      gs.nav_hunk "prev"
    end, "Previous git hunk")

    map("n", "<leader>gh", gs.stage_hunk, "Stage / unstage hunk")
    map("x", "<leader>gh", function()
      gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
    end, "Stage lines")
    map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
    map("x", "<leader>gr", function()
      gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
    end, "Reset lines")
    map("n", "<leader>gA", gs.stage_buffer, "Stage file")
    map("n", "<leader>gR", gs.reset_buffer, "Reset file")
    map("n", "<leader>gp", gs.preview_hunk_inline, "Preview hunk")
    map("n", "<leader>gk", function()
      gs.blame_line { full = true }
    end, "Blame line")
    map("n", "<leader>gK", gs.blame, "Blame file")
    map("n", "<leader>gd", gs.diffthis, "Diff file vs index")
    map("n", "<leader>gD", function()
      gs.diffthis "~"
    end, "Diff file vs last commit")
    map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle inline blame")
    map({ "o", "x" }, "ih", gs.select_hunk, "Inside git hunk")
  end,
}

-- Commit / push via mini.git (commit message opens in a buffer; :wq to commit)
vim.keymap.set("n", "<leader>gc", "<Cmd>Git commit<CR>", { desc = "Commit" })
vim.keymap.set("n", "<leader>ga", "<Cmd>Git commit --amend<CR>", { desc = "Amend last commit" })
vim.keymap.set("n", "<leader>gP", "<Cmd>Git push<CR>", { desc = "Push" })
vim.keymap.set("n", "<leader>gF", "<Cmd>Git pull<CR>", { desc = "Pull" })
