-- Treesitter: syntax highlighting, indentation and folding from real parsers.
-- Parsers below are installed up front; any other language with an available
-- parser is installed automatically the first time you open such a file.
local ts = require "nvim-treesitter"

ts.install {
  "astro",
  "bash",
  "css",
  "diff",
  "gitcommit",
  "git_rebase",
  "go",
  "gomod",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "svelte",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

local available -- cached list of languages nvim-treesitter can install
local function attach(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
    return
  end
  vim.wo[0][0].foldmethod = "expr"
  vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
  -- Treesitter indent is experimental; Vim's own CSS indent handles comments better
  local builtin_indent = { css = true, scss = true, less = true }
  if not builtin_indent[lang] and vim.treesitter.query.get(lang, "indents") then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then
      return
    end
    if vim.treesitter.language.add(lang) then
      return attach(ev.buf, lang)
    end
    available = available or ts.get_available()
    if vim.list_contains(available, lang) then
      ts.install(lang):await(function()
        vim.schedule(function()
          attach(ev.buf, lang)
        end)
      end)
    end
  end,
})

-- Sticky header: keeps the enclosing function/class visible at the top while scrolling
require("treesitter-context").setup { max_lines = 3, multiline_threshold = 1 }

-- Auto-close and auto-rename HTML/JSX/Astro/Svelte tags
require("nvim-ts-autotag").setup()
