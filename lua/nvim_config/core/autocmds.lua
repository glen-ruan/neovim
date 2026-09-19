-- Stop comments from continuing automatically on new lines.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("NvimConfigFormatOptions", { clear = true }),
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Reapply custom highlights after the colorscheme changes.
local C = require("nvim_config.core.colors")
local function apply_custom_highlights()
  -- Keep completion and floating windows transparent.
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE", blend = 0 })
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = C.pink, fg = C.surface0, bold = true })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = C.ice_white, bg = "NONE" })

  vim.api.nvim_set_hl(0, "CurSearch", {
    bg = C.mint_cream,
    fg = C.surface0,
    bold = true,
  }) -- Current search match.

  -- Visual selection styling.
  -- vim.api.nvim_set_hl(0, "Visual", {
  --   bg = C.pink,
  --   fg = C.surface0,
  --   bold = true,
  -- })
end

-- Apply highlights now and after future colorscheme changes.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("NvimConfigHighlights", { clear = true }),
  callback = apply_custom_highlights,
})

apply_custom_highlights()
