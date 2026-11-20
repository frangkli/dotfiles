-- Prose: wrap long lines at word boundaries and move by screen line
vim.opt_local.wrap = true
vim.keymap.set({ "n", "x" }, "j", "v:count ? 'j' : 'gj'", { buffer = true, expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count ? 'k' : 'gk'", { buffer = true, expr = true })

-- Lists ---------------------------------------------------------------------
-- <CR> at the end of a list item (and `o` on one) starts the next item:
--   - foo     ->  -
--   - [x] foo ->  - [ ]
--   3. foo    ->  4.
-- <CR> on an empty item removes its marker (ends the list).
local function next_item(line)
  local indent, bullet, rest = line:match "^(%s*)([-*+])%s+%[[ xX]%]%s*(.*)$"
  if indent then
    return indent .. bullet .. " [ ] ", rest
  end
  indent, bullet, rest = line:match "^(%s*)([-*+])%s+(.*)$"
  if indent then
    return indent .. bullet .. " ", rest
  end
  local num, delim
  indent, num, delim, rest = line:match "^(%s*)(%d+)([.)])%s+(.*)$"
  if indent then
    return indent .. (tonumber(num) + 1) .. delim .. " ", rest
  end
end

-- Replaces the current line with `text` and puts the cursor at its end.
-- Called through <Cmd> so it runs in order with the surrounding keys.
function _G.MarkdownSetLine(text)
  vim.api.nvim_set_current_line(text)
  vim.api.nvim_win_set_cursor(0, { vim.fn.line ".", #text })
end
local function set_line_keys(text)
  return vim.keycode(("<Cmd>lua MarkdownSetLine(%q)<CR>"):format(text))
end

vim.keymap.set("i", "<CR>", function()
  local line = vim.api.nvim_get_current_line()
  local at_end = vim.api.nvim_win_get_cursor(0)[2] >= #line
  local marker, rest = next_item(line)
  if marker and at_end then
    if rest == "" then -- empty item: end the list
      return set_line_keys ""
    end
    return vim.keycode "<CR>" .. set_line_keys(marker)
  end
  return MiniPairs and MiniPairs.cr() or vim.keycode "<CR>"
end, { buffer = true, expr = true, replace_keycodes = false, desc = "Newline, continuing lists" })

vim.keymap.set("n", "o", function()
  local marker = next_item(vim.api.nvim_get_current_line())
  return marker and ("o" .. set_line_keys(marker)) or "o"
end, { buffer = true, expr = true, replace_keycodes = false, desc = "Open line, continuing lists" })

-- Links ---------------------------------------------------------------------
--   \l  (normal) on a URL like astro.build   ->  [astro.build](https://astro.build)
--   \l  (visual) on some text                ->  [text](<url>)
--       uses the clipboard if it holds a URL, otherwise asks for one
local function to_url(s)
  return (s:match "^%a[%w+.-]*:" and s) or "https://" .. s
end

vim.keymap.set("n", "<localleader>l", function()
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
  local link = ("%s[%s](%s)%s"):format(lead, text, to_url(text), trail)
  vim.api.nvim_buf_set_text(0, row - 1, s - 1, row - 1, e, { link })
end, { buffer = true, desc = "Make link from URL under cursor" })

vim.keymap.set("x", "<localleader>l", function()
  local p1, p2 = vim.fn.getpos "v", vim.fn.getpos "."
  if p1[2] ~= p2[2] or vim.fn.mode() ~= "v" then
    return vim.notify("Select text on a single line (charwise visual)", vim.log.levels.WARN)
  end
  if p1[3] > p2[3] then
    p1, p2 = p2, p1
  end
  local text = table.concat(vim.fn.getregion(p1, p2, { type = "v" }), "")
  local row, start_col = p1[2] - 1, p1[3] - 1
  vim.api.nvim_feedkeys(vim.keycode "<Esc>", "nx", false)

  local function apply(url)
    if not url or url == "" then
      return
    end
    vim.api.nvim_buf_set_text(0, row, start_col, row, start_col + #text, { ("[%s](%s)"):format(text, to_url(url)) })
  end
  local clip = vim.fn.getreg("+"):gsub("%s+$", "")
  if clip:match "^https?://%S+$" then
    apply(clip)
  else
    vim.ui.input({ prompt = "URL: " }, apply)
  end
end, { buffer = true, desc = "Make link from selection" })
