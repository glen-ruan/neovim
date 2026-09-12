return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
    opts = {
      PATH = "append",
      ui = { border = "rounded" },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    cmd = { "MasonToolsInstall", "MasonToolsInstallSync", "MasonToolsUpdate", "MasonToolsUpdateSync" },
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
        "tex-fmt",
        "texlab",
        "typescript-language-server",
      },
      auto_update = false,
      run_on_start = false,
    },
  },
}
