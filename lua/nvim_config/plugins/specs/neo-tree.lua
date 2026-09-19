return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- File icons.
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true, -- Exit Neovim when Neo-tree is the final window.
        popup_border_style = "rounded",
        clipboard = {
          sync = "universal",
        },
        enable_git_status = true,
        enable_diagnostics = false,
        open_files_do_not_replace_types = { "terminal", "trouble", "qf" },

        -- Filesystem source.
        filesystem = {
          bind_to_cwd = false,
          follow_current_file = {
            enabled = true, -- Reveal the current file automatically.
          },
          use_libuv_file_watcher = true,
          filtered_items = {
              visible = true, -- Show hidden files; press i to toggle.
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },

        -- Window and mappings.
        window = {
          position = "left",
          width = 0.15,
        },

        -- Source selector can be enabled here if needed.
        source_selector = {
          winbar = false,
          statusline = false,
        },
      })
    end,
  },
}
