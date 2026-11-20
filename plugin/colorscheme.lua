-- Kanagawa: "dragon" (dark, muted), "wave" (dark, bluer) or "lotus" (light).
-- Switch on the fly with :colorscheme kanagawa-wave
require("kanagawa").setup {
  compile = false,
  dimInactive = false,
  colors = {
    theme = { all = { ui = { bg_gutter = "none" } } }, -- gutter blends with the editor
  },
  overrides = function(colors)
    local theme = colors.theme
    return {
      -- Borderless-looking floats that still have a visible edge
      NormalFloat = { bg = "none" },
      FloatBorder = { bg = "none", fg = theme.ui.nontext },
      FloatTitle = { bg = "none" },
      -- Popup menu blends with the UI
      Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
      PmenuSel = { fg = "none", bg = theme.ui.bg_p2 },
      PmenuSbar = { bg = theme.ui.bg_m1 },
      PmenuThumb = { bg = theme.ui.bg_p2 },
    }
  end,
}

vim.cmd.colorscheme "kanagawa-dragon"
