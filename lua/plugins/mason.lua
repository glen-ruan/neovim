return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "bashls", "clangd", "cmake", "cssls", "html", "lua_ls", "pyright", "texlab", "ts_ls",
      },
      automatic_enable = false,
    },
  },
}
