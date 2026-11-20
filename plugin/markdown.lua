-- render-markdown: styled headings, lists, checkboxes, tables and code blocks in
-- the buffer. The raw markdown shows on the line under the cursor.
require("render-markdown").setup {
  completions = { lsp = { enabled = true } },
  latex = { enabled = false }, -- needs a latex parser + converter; not used
  heading = { sign = false, width = "block", right_pad = 1 },
  code = { sign = false, width = "block", right_pad = 1 },
}
vim.keymap.set("n", "<leader>tm", "<Cmd>RenderMarkdown toggle<CR>", { desc = "Toggle markdown rendering" })
