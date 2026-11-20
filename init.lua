-- Neovim 0.12+ config. Plugins are managed by the built-in vim.pack.
-- Files in plugin/ are sourced automatically after this file, in alphabetical order.

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Experimental 0.12 message + cmdline UI: no more "Press ENTER" prompts.
require("vim._core.ui2").enable {}

-- Build steps that must run after a plugin is installed or updated.
-- Registered before vim.pack.add() so they also fire on first install.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack-hooks", { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      if not ev.data.active then
        vim.cmd.packadd "nvim-treesitter"
      end
      vim.cmd "TSUpdate"
    end
  end,
})

local gh = function(repo)
  return "https://github.com/" .. repo
end

vim.pack.add({
  -- UI
  gh "rebelot/kanagawa.nvim",
  gh "nvim-mini/mini.nvim", -- files, git, statusline, clue, ai, surround, pairs, sessions, icons, ...

  -- Navigation & search
  gh "ibhagwan/fzf-lua",
  gh "folke/flash.nvim",
  gh "MagicDuck/grug-far.nvim",

  -- LSP, completion, formatting
  gh "neovim/nvim-lspconfig",
  gh "mason-org/mason.nvim",
  gh "mason-org/mason-lspconfig.nvim",
  gh "b0o/SchemaStore.nvim",
  gh "folke/lazydev.nvim",
  { src = gh "saghen/blink.cmp", version = vim.version.range "1.*" },
  gh "stevearc/conform.nvim",

  -- Treesitter
  { src = gh "nvim-treesitter/nvim-treesitter", version = "main" },
  gh "nvim-treesitter/nvim-treesitter-context",
  gh "windwp/nvim-ts-autotag",

  -- Git & markdown
  gh "lewis6991/gitsigns.nvim",
  gh "MeanderingProgrammer/render-markdown.nvim",
}, { confirm = false })

-- :PackUpdate shows a review buffer (:w to apply, :q to cancel).
-- :PackClean removes plugins on disk that are no longer listed above.
vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update plugins" })
vim.api.nvim_create_user_command("PackClean", function()
  local unused = vim
    .iter(vim.pack.get())
    :filter(function(p)
      return not p.active
    end)
    :map(function(p)
      return p.spec.name
    end)
    :totable()
  if #unused == 0 then
    return vim.notify "No unused plugins"
  end
  vim.pack.del(unused)
  vim.notify("Removed: " .. table.concat(unused, ", "))
end, { desc = "Remove plugins no longer in vim.pack.add()" })
