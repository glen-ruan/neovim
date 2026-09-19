local M = {}

M.commands = {
  core = {
    { name = "git", required = true, purpose = "插件与配置更新" },
    { name = "curl", required = true, purpose = "下载工具" },
    { name = "tar", required = true, purpose = "解压工具" },
  },
  search = {
    { name = "rg", required = true, purpose = "全文搜索" },
    { name = "fd", aliases = { "fdfind" }, required = false, purpose = "快速文件搜索" },
  },
  development = {
    { name = "tree-sitter", required = false, purpose = "编译 Treesitter parser" },
    { name = "node", required = false, purpose = "部分语言服务器和 Markdown 预览" },
    { name = "quarto", required = false, purpose = "Quarto 预览" },
  },
  latex = {
    { name = "latexmk", required = false, purpose = "LaTeX 编译" },
    { name = "xelatex", required = false, purpose = "XeLaTeX 引擎" },
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
