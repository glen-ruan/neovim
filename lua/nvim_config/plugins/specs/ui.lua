return {
  -- Statusline.
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      -- Show the cached configuration version on the right.
      sections = {
        lualine_x = { "encoding", "fileformat", "filetype", { require("nvim_config.features.version").label } },
      },
    },
  },

  -- Syntax highlighting and Treesitter.
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall", "TSInstallConfigured" },
    branch = "main",
    build = ":TSUpdate",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
      local treesitter = require("nvim-treesitter")
      local languages = {
        "bash",
        "c",
        "cmake",
        "cpp",
        "css",
        "html",
        "javascript",
        "json",
        "latex",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "r",
        "regex",
        "typescript",
        "vim",
        "yaml",
      }

      treesitter.setup({})

      vim.api.nvim_create_user_command("TSInstallConfigured", function(opts)
        local task = treesitter.install(languages)
        if opts.bang then
          task:wait(300000)
          -- The task may not raise when parser compilation fails, so verify the installed list.
          local installed = treesitter.get_installed() or {}
          local missing = vim.tbl_filter(function(lang)
            return not vim.list_contains(installed, lang)
          end, languages)
          if #missing > 0 then
            error("Treesitter parser installation failed: " .. table.concat(missing, ", "))
          end
        end
      end, { bang = true, desc = "Install configured Treesitter parsers; ! waits for completion" })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if lang and pcall(vim.treesitter.language.add, lang) then
            pcall(vim.treesitter.start, args.buf, lang)
          end
        end,
      })
    end,
  },
}
