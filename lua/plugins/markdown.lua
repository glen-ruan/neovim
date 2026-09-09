return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function(plugin)
    local app = vim.fs.joinpath(plugin.dir, "app")
    local command = vim.fn.has("win32") == 1 and { "cmd.exe", "/d", "/s", "/c", "install.cmd" }
      or { vim.fs.joinpath(app, "install.sh") }
    local result = vim.system(command, { cwd = app, text = true }):wait()
    if result.code ~= 0 then
      error(result.stderr ~= "" and result.stderr or result.stdout)
    end
  end,
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
}
