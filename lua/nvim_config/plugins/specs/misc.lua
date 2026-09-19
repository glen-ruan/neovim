return {
  -- Git 集成
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- 自动括号匹配
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true, -- 启用 Treesitter 检测语言
        enable_check_bracket_line = true, -- 同一行避免重复括号
      })
    end,
  },
}
