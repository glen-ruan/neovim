return {
  "rachartier/tiny-inline-diagnostic.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("tiny-inline-diagnostic").setup({
      preset = "ghost",
      options = {
        overwrite_events = { "BufEnter", "LspAttach" },
        throttle = 0,
        multilines = {
          enabled = true,
          always_show = true,
        },
        enable_on_insert = true,
        enable_on_select = true,

        virt_texts = {
          priority = 2048,
        },
      },
    })
    vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
  end,
}
