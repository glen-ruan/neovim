local M = {}

function M.setup()
  require("nvim_config.core.settings").setup()
  require("nvim_config.core.options")
  require("nvim_config.core.keymaps")
  require("nvim_config.core.autocmds")

  require("nvim_config.features.version").setup()
  require("nvim_config.features.changelog").setup()
  require("nvim_config.features.lsp").setup()

  local platform = require("nvim_config.core.platform")
  if platform.is_windows then
    require("nvim_config.integrations.embedded.iar")
    require("nvim_config.integrations.embedded.keil")
  end

  require("nvim_config.plugins")
end

return M
