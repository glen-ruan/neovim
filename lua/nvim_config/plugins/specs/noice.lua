return {
  "folke/noice.nvim",
  dependencies = {
      "MunifTanjim/nui.nvim",
  },
  config = function()
    require("noice").setup({
      -- Command line.
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { pattern = "^/", icon = "", lang = "regex" },
          search_up = { pattern = "^%?", icon = "", lang = "regex" },
          lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
        },
      },

      -- LSP integration.
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        progress = { enabled = false, view = "mini" },
        hover = { enabled = false },
        signature = { enabled = false },
        message = { enabled = false, view = "notify" },
      },

      notify = {
        enabled = false,
      },

      -- Presets.
      presets = {
        bottom_search = false,
        command_palette = false,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
    })
  end,
}
