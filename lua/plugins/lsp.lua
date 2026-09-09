return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "nvimdev/lspsaga.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
      { "folke/trouble.nvim", cmd = "Trouble" },
      { "j-hui/fidget.nvim", opts = {} },
      "saghen/blink.cmp",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local servers = {
        clangd = {
          cmd = { "clangd", "--background-index", "--clang-tidy" },
          filetypes = { "c", "cpp", "objc", "objcpp" },
          root_markers = { ".clangd", "compile_commands.json", "CMakeLists.txt", ".git" },
        },
        cmake = {
          cmd = { "cmake-language-server" },
          filetypes = { "cmake" },
          root_markers = { "CMakePresets.json", "CMakeLists.txt", ".git" },
          init_options = { buildDirectory = "build" },
        },
        pyright = {
          cmd = { "pyright-langserver", "--stdio" },
          root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
        },
        lua_ls = {
          cmd = { "lua-language-server" },
          filetypes = { "lua" },
          root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        },
        bashls = {
          cmd = { "bash-language-server", "start" },
          filetypes = { "bash", "sh", "zsh" },
          root_markers = { ".git" },
        },
        html = {
          cmd = { "vscode-html-language-server", "--stdio" },
          filetypes = { "html" },
        },
        cssls = {
          cmd = { "vscode-css-language-server", "--stdio" },
          filetypes = { "css", "scss", "less" },
        },
        ts_ls = {
          cmd = { "typescript-language-server", "--stdio" },
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
          root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
        },
        texlab = {
          cmd = { "texlab" },
          filetypes = { "tex", "plaintex", "bib" },
        },
      }

      for name, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config(name, config)
        if config.cmd and vim.fn.executable(config.cmd[1]) == 1 then
          vim.lsp.enable(name)
        end
      end

      vim.api.nvim_create_user_command("LspAvailability", function()
        local lines = {}
        for name, config in pairs(servers) do
          local command = config.cmd and config.cmd[1]
          local path = command and vim.fn.exepath(command) or ""
          table.insert(lines, string.format("%-10s %s", name, path ~= "" and path or "missing"))
        end
        vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LSP availability" })
      end, { desc = "显示语言服务器可用状态" })

      require("lspsaga").setup({
        ui = { border = "rounded" },
        symbol_in_winbar = { enable = true },
        lightbulb = { enable = false, virtual_text = false },
      })

      require("trouble").setup({
        win = { position = "bottom", size = 10 },
        keys = {
          q = "close",
          r = "refresh",
          ["<cr>"] = "jump",
          ["<tab>"] = "jump",
        },
      })
    end,
  },
}
