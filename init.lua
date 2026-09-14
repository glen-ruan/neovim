-- init.lua

-- bootstrap
require("config.platform")
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.iar_clangd")
require("config.keil_clangd")
require("nvim_distribution.version").setup()
require("config.lazy")
