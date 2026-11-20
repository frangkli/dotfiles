-- Prose: wrap long lines at word boundaries and move by screen line.
-- (List, checkbox and link editing come from markdown-plus: plugin/markdown.lua)
vim.opt_local.wrap = true
vim.keymap.set({ "n", "x" }, "j", "v:count ? 'j' : 'gj'", { buffer = true, expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count ? 'k' : 'gk'", { buffer = true, expr = true })

-- \mk: turn the URL or bare domain under the cursor into a link, no prompts.
--   astro.build  ->  [astro.build](https://astro.build)
-- (markdown-plus's \ma only recognizes URLs that already start with https://)
vim.keymap.set("n", "<localleader>mk", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local s, e = col + 1, col + 1
  if line:sub(s, s):match "^%s?$" then
    return
  end
  while s > 1 and not line:sub(s - 1, s - 1):match "%s" do
    s = s - 1
  end
  while e < #line and not line:sub(e + 1, e + 1):match "%s" do
    e = e + 1
  end
  -- keep sentence punctuation and wrapping brackets outside the link
  local lead, text, trail = line:sub(s, e):match "^([%(%[<\"']*)(.-)([%.,;:!%?%)%]>\"']*)$"
  if text == "" then
    return
  end
  local url = text:match "^%a[%w+.-]*://" and text or "https://" .. text
  vim.api.nvim_buf_set_text(0, row - 1, s - 1, row - 1, e, { ("%s[%s](%s)%s"):format(lead, text, url, trail) })
end, { buffer = true, desc = "Link the URL/domain under cursor" })
