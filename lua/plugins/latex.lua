-- lazy.nvim plugin config
return {
  "lervag/vimtex",
  lazy = false, -- 不要 lazy load
  init = function()
    vim.g.vimtex_view_method = "zathura" -- PDF 查看器
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_compiler_latexmk = {
      executable = "latexmk",
      options = {
        "-xelatex", -- 这里关键，fontspec 必须用 XeLaTeX
        "-shell-escape",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      },
    }
  end,
}
