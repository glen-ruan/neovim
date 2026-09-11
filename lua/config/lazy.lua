local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins.theme" },
    { import = "plugins.ui" },
    { import = "plugins.snacks" },
    { import = "plugins.noice" },
    { import = "plugins.neo-scroll" },
    { import = "plugins.blink-cmp" },
    { import = "plugins.misc" },
    { import = "plugins.neo-tree" },
    { import = "plugins.lsp" },
    { import = "plugins.bufferline" },
    { import = "plugins.mason" },
    { import = "plugins.quarto" },
    { import = "plugins.aerial" },
    { import = "plugins.colorizer" },
    { import = "plugins.formatter" },
    { import = "plugins.inline-diagno" },
    { import = "plugins.markdown" },
    { import = "plugins.renamer" },
    { import = "plugins.dap" },
    { import = "plugins.diffview" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    -- 使用 :Lazy check / :Lazy update 手动检查，避免后台网络和扫描。
    enabled = false,
    notify = false,
  },
  rocks = { enabled = false },
  performance = {
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
