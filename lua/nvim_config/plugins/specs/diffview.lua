return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewToggleFiles",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
    },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Git Diffview" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Current File History" },
      { "<leader>gl", "<cmd>DiffviewFileHistory<cr>", desc = "Repository History" },
    },
  },
}
