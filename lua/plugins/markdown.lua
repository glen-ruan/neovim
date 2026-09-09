return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = "npm install --prefix app", -- 兼容 Windows PowerShell 5.1
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
}
