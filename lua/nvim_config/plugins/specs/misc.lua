return {
  -- Git integration.
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Automatic bracket pairing.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
      check_ts = true, -- Use Treesitter-aware pairing.
      enable_check_bracket_line = true, -- Avoid duplicate closing brackets on the same line.
      })
    end,
  },
}
