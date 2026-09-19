-- lazy.nvim plugin config
return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_view_method = "general" -- Use the platform's default PDF viewer.
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_compiler_latexmk = {
      executable = "latexmk",
      options = {
      "-xelatex", -- fontspec requires XeLaTeX.
        "-shell-escape",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      },
    }
  end,
}
