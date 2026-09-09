return {
  {
    "mason-org/mason.nvim",
    opts = {
      PATH = "append",
      ui = { border = "rounded" },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "bashls",
        "clangd",
        "cssls",
        "html",
        "lua_ls",
        "pyright",
        "texlab",
        "ts_ls",
      },
      automatic_enable = false,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "bash-language-server",
        "black",
        "clang-format",
        "clangd",
        "css-lsp",
        "debugpy",
        "html-lsp",
        "lua-language-server",
        "prettier",
        "pyright",
        "shfmt",
        "stylua",
        "texlab",
        "typescript-language-server",
      },
      auto_update = false,
      run_on_start = true,
      start_delay = 1000,
      debounce_hours = 24,
    },
  },
}
