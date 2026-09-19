return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "nvimdev/lspsaga.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
      { "folke/trouble.nvim", cmd = "Trouble" },
      { "j-hui/fidget.nvim", opts = {} },
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local platform = require("nvim_config.core.platform")
      local lsp_features = require("nvim_config.features.lsp")

      -- Highlight only the active parameter text, not the entire signature float.
      vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", { bold = true, underline = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
        callback = function(args)
          vim.keymap.set("n", "K", lsp_features.hover, { buffer = args.buf, desc = "LSP: show symbol documentation" })

          -- Keep an explicit code-action entry alongside Neovim's native mappings.
          vim.keymap.set({ "n", "v" }, "<leader>ca", function()
            vim.lsp.buf.code_action()
          end, { buffer = args.buf, desc = "LSP: code action" })

          vim.keymap.set("i", "<C-s>", lsp_features.signature_help, {
            buffer = args.buf,
            desc = "LSP: show function signature",
          })
        end,
      })

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
          root_markers = { "uv.lock", "pyproject.toml", ".venv", "setup.py", "requirements.txt", ".git" },
          settings = {
            python = {
              analysis = {
                diagnosticSeverityOverrides = {
                  reportMissingImports = "error",
                  reportMissingModuleSource = "error",
                },
              },
            },
          },
          before_init = function(_, config)
            local python = platform.project_python(config.root_dir)
            if python then
          -- The client already references this settings table; mutate it in
          -- place so Pyright receives the updated interpreter configuration.
              config.settings.python = config.settings.python or {}
              config.settings.python.pythonPath = python
            else
              vim.schedule(function()
            vim.notify("No project .venv is available; Pyright is not bound to a Python environment", vim.log.levels.WARN)
              end)
            end
          end,
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

      local function enable_available_servers()
        for name, config in pairs(servers) do
          if config.cmd and vim.fn.executable(config.cmd[1]) == 1 then
            vim.lsp.enable(name)
          end
        end
      end

      for name, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config(name, config)
      end
      enable_available_servers()

      -- Enable language servers immediately when Mason installs them in this session.
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("UserEnableMasonLsp", { clear = true }),
        pattern = "MasonToolsUpdateCompleted",
        callback = enable_available_servers,
      })

      require("lspsaga").setup({
        ui = { border = "rounded" },
        symbol_in_winbar = { enable = true },
        lightbulb = { enable = false, virtual_text = false },
      })

      require("trouble").setup({
        win = {
          type = "float",
          relative = "editor",
          border = "rounded",
          size = { width = 0.85, height = 0.7 },
        },
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
