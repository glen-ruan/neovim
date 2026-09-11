return {
  -- 状态栏
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- 语法高亮 & Treesitter
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
        end
      end, { bang = true, desc = "安装本配置使用的 Treesitter 解析器；! 表示等待完成" })

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
