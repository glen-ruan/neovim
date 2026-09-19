local M = {}

M.commands = {
  core = {
    { name = "git", required = true, purpose = "plugin and configuration updates" },
    { name = "curl", required = true, purpose = "downloads" },
    { name = "tar", required = true, purpose = "archive extraction" },
  },
  search = {
    { name = "rg", required = true, purpose = "full-text search" },
    { name = "fd", aliases = { "fdfind" }, required = false, purpose = "fast file search" },
  },
  development = {
    { name = "tree-sitter", required = false, purpose = "compile Treesitter parsers" },
    { name = "node", required = false, purpose = "selected language servers and Markdown preview" },
    { name = "quarto", required = false, purpose = "Quarto preview" },
  },
  latex = {
    { name = "latexmk", required = false, purpose = "LaTeX compilation" },
    { name = "xelatex", required = false, purpose = "XeLaTeX engine" },
  },
}

M.lsp = {
  clangd = "clangd",
  cmake = "cmake-language-server",
  pyright = "pyright-langserver",
  lua_ls = "lua-language-server",
  bashls = "bash-language-server",
  html = "vscode-html-language-server",
  cssls = "vscode-css-language-server",
  ts_ls = "typescript-language-server",
  texlab = "texlab",
}

function M.resolve(entry)
  for _, name in ipairs(vim.list_extend({ entry.name }, entry.aliases or {})) do
    local path = vim.fn.exepath(name)
    if path ~= "" then
      return path, name
    end
  end
  return nil
end

return M
