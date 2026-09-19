return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  init = function()
    require("nvim_config.features.github").setup()
  end,
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
    {
      "<leader>ghr",
      function()
        require("nvim_config.features.github").search_repositories()
      end,
      desc = "Search GitHub repositories",
    },
    {
      "<leader>ghc",
      function()
        require("nvim_config.features.github").search_code()
      end,
      desc = "Search GitHub code",
    },
    {
      "<leader>ghi",
      function()
        require("nvim_config.features.github").search_octo("is:issue", "Search GitHub Issues: ")
      end,
      desc = "Search GitHub Issues",
    },
    {
      "<leader>ghp",
      function()
        require("nvim_config.features.github").search_octo("is:pr", "Search GitHub Pull Requests: ")
      end,
      desc = "Search GitHub Pull Requests",
    },
    {
      "<leader>ghd",
      function()
        require("nvim_config.features.github").search_octo("is:discussion", "Search GitHub Discussions: ")
      end,
      desc = "Search GitHub Discussions",
    },
    { "<leader>ghl", "<cmd>Octo repo list<CR>", desc = "List account repositories" },
    { "<leader>ghn", "<cmd>Octo notification list<CR>", desc = "GitHub notifications" },
    {
      "<leader>ghs",
      function()
        require("nvim_config.features.github").search_octo(nil, "Search GitHub Issues, PRs, or Discussions: ")
      end,
      desc = "Search GitHub activity",
    },
  },
}
