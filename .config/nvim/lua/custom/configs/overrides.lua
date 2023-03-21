local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "c",
    "markdown",
    "markdown_inline",
  },
  indent = {
    enable = true,
    disable = {
      "python"
    },
  },
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "astro-language-server",
    "prettier",
    "prisma-language-server",
    "svelte-language-server",
    "tailwindcss-language-server",
    "unocss-language-server",

    -- system stuff
    "asm-lsp",
    "bash-language-server",
    "shellcheck",
    "clang-format",
    "clangd",
    "codelldb",
    "cpplint",
    "rust-analyzer",
    "rustfmt",

    -- python stuff
    "autopep8",
    "pylint",
    "pyright",
    "python-language-server",

    -- system stuff
    "elixir-ls",
    "texlab"
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

return M
