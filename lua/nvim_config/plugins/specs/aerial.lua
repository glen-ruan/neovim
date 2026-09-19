return {
  "stevearc/aerial.nvim",
  config = function()
    require("aerial").setup({
      backends = { "lsp", "treesitter" }, -- Prefer LSP and fall back to Treesitter.
      -- filter_kind = {
      --   "Class",
      --   "Constructor",
      --   "Enum",
      --   "Function",
      --   "Interface",
      --   "Module",
      --   "Method",
      --   "Struct",
        --   "Variable",
        --   "Constant",
        --   "Property",
        --   "Field",
      -- },

      filter_kind = false,

      layout = {
        resize_to_content = false,
        min_width = 30,
        width = 0.35,
        max_width = { 60, 0.5 },
        placement = "edge",
        default_direction = "prefer_right",
      },
      float = {
        border = "rounded",
        relative = "editor",
        max_height = 0.8,
        height = 0.7,
      },
      show_guides = true,
      guides = { -- Aerial calls this option "guides" rather than "guide_chars".
        mid_item = "├─",
        last_item = "└─",
        nested_top = "│ ",
        whitespace = "  ",
      },
      autojump = true,
    })
    vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle float<CR>", { desc = "Floating code outline" })
  end,
  -- Lazy-load on the mapping.
  keys = { "<leader>o" },
}
