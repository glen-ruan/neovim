return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    picker = "snacks",
    enable_builtin = true,
    suppress_missing_scope = {
      projects_v2 = true,
    },
  },
  keys = {
    { "<leader>ghr", "<cmd>Octo repo list<CR>", desc = "GitHub repositories" },
    { "<leader>ghi", "<cmd>Octo issue list<CR>", desc = "GitHub Issues" },
    { "<leader>ghp", "<cmd>Octo pr list<CR>", desc = "GitHub Pull Requests" },
    { "<leader>ghn", "<cmd>Octo notification list<CR>", desc = "GitHub notifications" },
    {
      "<leader>ghs",
      function()
        require("octo.utils").create_base_search_command({ include_current_repo = true })
      end,
      desc = "Search GitHub",
    },
  },
}
