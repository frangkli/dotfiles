-- blink.cmp: completion menu from language servers and file paths. No AI, no ghost text.
-- <CR> accept, <C-j>/<C-k> (or <C-n>/<C-p>) move, <C-e> close,
-- <C-space> open menu / toggle docs, <C-b>/<C-f> scroll docs.
require("blink.cmp").setup {
  keymap = {
    preset = "enter",
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = false },
    menu = { draw = { treesitter = { "lsp" } } },
  },
  signature = { enabled = true }, -- function signature while typing arguments
  sources = {
    default = { "lsp", "path" },
    per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
    providers = {
      lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
    },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
}
