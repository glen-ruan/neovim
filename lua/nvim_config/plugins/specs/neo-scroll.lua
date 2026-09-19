return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy",
  opts = {
    -- Use the plugin's default mappings.
    mappings = { "<C-u>", "<C-d>" },
    hide_cursor = true, -- Hide the cursor while scrolling.
    stop_eof = true, -- Stop at end of file.
    respect_scrolloff = false,
    cursor_scrolls_alone = true,
    easing = "quadratic",
    performance_mode = false, -- Enable if animations cause performance issues.
    pre_hook = nil,
    post_hook = nil,
  },
  config = function(_, opts)
    require("neoscroll").setup(opts)
  end,
}

-- return {}
