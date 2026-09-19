local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local ok, lazy = pcall(require, "lazy")
if not ok and not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
if not ok then
  vim.opt.rtp:prepend(lazypath)
  lazy = require("lazy")
end

local platform = require("nvim_config.core.platform")

lazy.setup({
  spec = require("nvim_config.plugins.specs"),
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "onedark", "habamax" } },
  checker = {
    -- Use :Lazy check / :Lazy update explicitly; avoid background network checks.
    enabled = false,
    notify = false,
  },
  rocks = { enabled = false },
  performance = {
    -- Windows may clear %TEMP% while Neovim is running, which can break
    -- vim.loader and Noice. Keep the cache enabled on Linux only.
    cache = { enabled = not platform.is_windows },
    rtp = {
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
