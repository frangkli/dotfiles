-- render-markdown: styled headings, lists, checkboxes, tables and code blocks in
-- the buffer. The raw markdown shows on the line under the cursor.
require("render-markdown").setup {
  completions = { lsp = { enabled = true } },
  latex = { enabled = false }, -- needs a latex parser + converter; not used
  heading = { sign = false, width = "block", right_pad = 1 },
  code = { sign = false, width = "block", right_pad = 1 },
}
vim.keymap.set("n", "<leader>tm", "<Cmd>RenderMarkdown toggle<CR>", { desc = "Toggle markdown rendering" })

-- markdown-plus: editing helpers. Keys live under the local leader `\`
-- (press `\` in a markdown file and wait to see them). The ones you'll use most:
--   <CR> / o        continue a list (bullets, `- [ ]`, numbers); <CR> on an empty item ends it
--   <Tab> / <S-Tab> indent / outdent a list item (insert mode); numbers update automatically
--   \mx             toggle a checkbox (<C-t> in insert mode)
--   \ml             insert a link, or turn the selection into one (asks for the URL)
--   \ma             turn the bare URL under the cursor into a link
--   \mb \mi         bold / italic (word or selection)
--   gx              open the link under the cursor
require("markdown-plus").setup {}
