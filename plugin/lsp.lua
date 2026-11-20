-- Language servers. nvim-lspconfig supplies each server's defaults (lsp/<name>.lua);
-- Mason installs the binaries; Neovim runs them via vim.lsp.enable().
-- Per-server overrides go below (or in after/lsp/<name>.lua).
--
-- Built-in keys when a server is attached: K hover, grn rename, gra code action,
-- grx codelens, [d ]d diagnostics, <C-w>d diagnostic float, <C-s> signature help (insert).

local servers = {
  -- Web
  "vtsls", -- TypeScript / JavaScript / React (TSX, JSX)
  "astro",
  "svelte",
  "tailwindcss", -- only starts in projects that use Tailwind
  "oxlint", -- only starts in projects with an oxlint config
  "biome", -- only starts in projects with a biome.json (and no oxlint config)
  "jsonls",
  "yamlls",
  -- Other languages
  "lua_ls",
  "gopls",
  "rust_analyzer",
  "pyrefly",
  -- Prose
  "marksman", -- markdown links and headings
  "harper_ls", -- grammar / spelling, runs locally
}
local tools = { "stylua", "oxfmt" } -- formatters run by conform (plugin/format.lua)

require("mason").setup()
require("mason-lspconfig").setup { ensure_installed = servers, automatic_enable = false }

-- Install formatters that aren't language servers
local registry = require "mason-registry"
registry.refresh(function()
  for _, name in ipairs(tools) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and not pkg:is_installed() then
      pkg:install()
    end
  end
end)

-- Lua: full Neovim API completion while editing this config
require("lazydev").setup {
  library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
}

-- Server overrides --------------------------------------------------------

vim.lsp.config("vtsls", {
  settings = {
    typescript = {
      inlayHints = { -- shown only when toggled on with <leader>th
        parameterNames = { enabled = "literals" },
        variableTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
      },
    },
  },
})

-- Linters: run oxlint OR biome, never both, and only in projects set up for them.
--   explicit oxlint config      -> oxlint
--   biome.json                  -> biome
--   neither (e.g. vite-plus)    -> oxlint, if its own detection finds a project root
-- (A server whose root_dir never calls on_dir doesn't start.)
local oxlint_files = { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" }
local biome_files = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }
local function only_with_root(default_root_dir)
  return function(buf, on_dir)
    default_root_dir(buf, function(dir)
      if dir then
        on_dir(dir)
      end
    end)
  end
end
local oxlint_root = only_with_root(vim.lsp.config.oxlint.root_dir)
local biome_root = only_with_root(vim.lsp.config.biome.root_dir)
vim.lsp.config("oxlint", {
  root_dir = function(buf, on_dir)
    if vim.fs.root(buf, oxlint_files) or not vim.fs.root(buf, biome_files) then
      oxlint_root(buf, on_dir)
    end
  end,
})
vim.lsp.config("biome", {
  root_dir = function(buf, on_dir)
    if vim.fs.root(buf, biome_files) and not vim.fs.root(buf, oxlint_files) then
      biome_root(buf, on_dir)
    end
  end,
})

-- Tailwind: only in projects with a tailwind config or `tailwindcss` in package.json
-- (lspconfig's default also starts it in any git repo, for Tailwind v4)
vim.lsp.config("tailwindcss", {
  root_dir = function(buf, on_dir)
    local root = vim.fs.root(buf, function(name, path)
      if name:match "^tailwind%.config%." then
        return true
      end
      if name ~= "package.json" then
        return false
      end
      local ok, text = pcall(vim.fn.readblob, path .. "/" .. name)
      return ok and text:find('"tailwindcss"', 1, true) ~= nil
    end)
    if root then
      on_dir(root)
    end
  end,
})

vim.lsp.config("jsonls", {
  settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } },
})
vim.lsp.config("yamlls", {
  settings = { yaml = { schemaStore = { enable = false, url = "" }, schemas = require("schemastore").yaml.schemas() } },
})

-- Grammar checking only in prose, not in every code comment
vim.lsp.config("harper_ls", { filetypes = { "markdown", "text", "gitcommit" } })

vim.lsp.enable(servers)

-- On attach: picker-based navigation + highlight other uses of the symbol ------

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(ev)
    local fzf = require "fzf-lua"
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("gd", fzf.lsp_definitions, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("grr", fzf.lsp_references, "References")
    map("gri", fzf.lsp_implementations, "Implementations")
    map("grt", fzf.lsp_typedefs, "Type definition")
    map("gO", fzf.lsp_document_symbols, "Symbols in file")

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/documentHighlight", ev.buf) then
      local hl = vim.api.nvim_create_augroup("lsp-highlight-" .. ev.buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = hl,
        buffer = ev.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
        group = hl,
        buffer = ev.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
