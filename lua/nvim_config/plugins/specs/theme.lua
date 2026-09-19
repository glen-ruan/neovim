-- plugins/theme.lua

-- Select the active colorscheme.
-- Other supported choices include "tokyonight" and "catppuccin".
local active_theme = "onedark"

-- Colorscheme specifications.
local themes = {
  -- tokyonight
  tokyonight = {
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
      style = "night", -- "storm", "night", "moon", or "day"
        transparent = true,
        terminal_colors = true,
        lualine_bold = true, -- When `true`, section headers in the lualine theme will be bold
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = { bold = true },
          variables = {},
          sidebars = "transparent",
          floats = "transparent",
        },
      })
      vim.cmd("colorscheme tokyonight")
    end,
  },

  -- catppuccin
  catppuccin = {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
      flavour = "macchiato", -- "latte", "frappe", "macchiato", or "mocha"
        background = { light = "latte", dark = "mocha" },
        transparent_background = true,
        term_colors = true,
        styles = {
          comments = { "italic" },
          -- functions = { "bold" },
          -- keywords = { "italic" },
        },
        integrations = {
          telescope = true,
          nvimtree = true,
          treesitter = true,
          notify = true,
        },
      })
      vim.cmd("colorscheme catppuccin")
    end,
  },

  -- gruvbox
  gruvbox = {
    "ellisonleao/gruvbox.nvim",
    config = function()
      require("gruvbox").setup({
      contrast = "medium", -- "hard", "medium", or "soft"
      transparent_mode = false,
      })
      vim.cmd("colorscheme gruvbox")
    end,
  },

-- Nightfox configuration.
  nightfox = {
    "EdenEast/nightfox.nvim",
    config = function()
      require("nightfox").setup({
        options = {
      -- Transparent floating windows and sidebars.
          transparent = false,
      -- Terminal colors.
          terminal_colors = true,
      -- Inactive window background.
          dim_inactive = false,
      -- Enable default modules.
          module_default = true,
      -- Style settings.
          styles = {
            comments = "italic",
            conditionals = "italic",
            constants = "NONE",
            functions = "bold",
            keywords = "bold,italic",
            numbers = "NONE",
            operators = "NONE",
            strings = "NONE",
            types = "italic",
            variables = "NONE",
          },
        },
      })

-- Configure colorschemes.
      vim.cmd("colorscheme dawnfox")
    end,
  },

  fluoromachine = {
    {
      "maxmx03/fluoromachine.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        local fm = require("fluoromachine")

        fm.setup({
          glow = true,
          theme = "delta",
          transparent = true,
        })

        vim.cmd("colorscheme fluoromachine")
      end,
    },
  },

  oxocarbon = {
    "nyoom-engineering/oxocarbon.nvim",
  },

  rose_pine = {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        variant = "auto", -- auto, main, moon, or dawn
        dark_variant = "main", -- main, moon, or dawn
        dim_inactive_windows = false,
        extend_background_behind_borders = true,

        enable = {
          terminal = true,
          legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
          migrations = true, -- Handle deprecated options automatically
        },
      })
      vim.cmd("colorscheme rose-pine")
    end,
  },

  onedark = {
    "navarasu/onedark.nvim",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("onedark").setup({
        style = "darker",
        transparent = true, -- Show/hide background
        term_colors = true, -- Change terminal color as per the selected theme style
        ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
        cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

        -- code_style = {
      --   comments = "italic",
      --   keywords = "bold",
      --   functions = "bold",
      --   strings = "italic",
      --   variables = "none",
        -- },

        code_style = {
          comments = "italic",
          keywords = "none",
          functions = "none",
          strings = "italic",
          variables = "none",
        },

        lualine = {
          transparent = false, -- lualine center bar transparency
        },
      })
      require("onedark").load()
    end,
  },

  vscode = {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      require("vscode").setup({})
      vim.cmd.colorscheme("vscode")
    end,
  },

  github = {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("github-theme").setup({
        options = {
          transparent = true, -- Disable setting bg (make neovim's background transparent)
          terminal_colors = true,
        },
      })

      vim.cmd("colorscheme github_dark")
    end,
  },

  onedarkpro = {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- Ensure it loads first

    config = function()
      require("onedarkpro").setup({
        options = {
          transparency = true,
        },

        styles = {
          types = "NONE",
          methods = "NONE",
          numbers = "NONE",
          strings = "NONE",
          comments = "italic",
          keywords = "italic",
          constants = "NONE",
          functions = "bold",
          operators = "NONE",
          variables = "NONE",
          parameters = "NONE",
          conditionals = "italic",
          virtual_text = "NONE",
        },
      })

      -- somewhere in your config:
      vim.cmd("colorscheme vaporwave")
    end,
  },

  melange = {
    "savq/melange-nvim",
    priority = 1000,

    config = function()
      vim.cmd("colorscheme melange")
    end,
  },

  monokai = {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("monokai-pro").setup({
        transparent_background = true,
        terminal_colors = true,
        devicons = true,
        styles = {
          comment = { italic = true },
          keyword = { italic = true },
          type = { italic = true },
          storageclass = { italic = true },
          structure = { italic = true },
          parameter = { italic = true },
          annotation = { italic = true },
          tag_attribute = { italic = true },
        },
        filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
      })
      vim.cmd.colorscheme("monokai-pro")
    end,
  },
}

-- Return the active colorscheme specification.
return { themes[active_theme] }
