-- conform: format on save (toggle with <leader>tf), or <leader>cf on demand.
-- JS/TS/etc: oxfmt if the project has an oxfmt config, else biome if it has
-- a biome.json, else the language server's own formatting.
local web = { "oxfmt", "biome", stop_after_first = true }

require("conform").setup {
  formatters_by_ft = {
    javascript = web,
    javascriptreact = web,
    typescript = web,
    typescriptreact = web,
    json = web,
    jsonc = web,
    css = web,
    astro = web,
    svelte = web,
    lua = { "stylua" },
    ["_"] = { "trim_whitespace", lsp_format = "prefer" }, -- everything else
  },
  formatters = {
    oxfmt = { require_cwd = true },
    biome = { require_cwd = true },
  },
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = function()
    if vim.g.autoformat == false then
      return
    end
    return { timeout_ms = 1000 }
  end,
}

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" -- `gq` uses conform too

vim.keymap.set({ "n", "x" }, "<leader>cf", function()
  require("conform").format()
end, { desc = "Format" })
