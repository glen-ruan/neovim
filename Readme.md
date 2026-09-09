# Neovim 配置

这是 `glen-ruan` 的 Windows Neovim 配置仓库，面向 Neovim 0.12.5，使用 `lazy.nvim` 管理插件。

## 文档

- [快捷键说明](docs/Neovim快捷键说明.md)
- [嵌入式开发流程](docs/嵌入式开发流程.md)

## 仓库内容

```text
init.lua                         配置入口
lua/config/options.lua           编辑器选项、PATH 和 PowerShell
lua/config/keymaps.lua           全局快捷键
lua/config/autocmds.lua          自动命令
lua/config/lazy.lua              lazy.nvim 引导和插件导入
lua/config/iar_clangd.lua        IAR 语言服务命令
lua/config/keil_clangd.lua       Keil 语言服务命令
lua/plugins/*.lua                插件配置
lua/customs/float_trem.lua       浮动终端
tools/iar-clangd.ps1             IAR 编译数据库生成器
tools/keil-clangd.ps1            Keil 编译数据库生成器
tools/clangd-compat/include      嵌入式 clangd 兼容头文件
docs                             使用文档
lazy-lock.json                   插件版本锁定文件
stylua.toml                      Lua 格式化配置
```

插件安装目录、Mason 工具、Treesitter parser、日志和缓存位于 `%LOCALAPPDATA%\nvim-data`，不属于本仓库。

## 主要组件

- `nvim-treesitter`：语法树和高亮
- `nvim-lspconfig`、`mason.nvim`：语言服务器
- `blink.cmp`、`LuaSnip`：补全和代码片段
- `snacks.nvim`：文件、文本、Buffer、Git 和 LSP 搜索
- `neo-tree.nvim`、`bufferline.nvim`：文件树和 Buffer 栏
- `nvim-dap`、`debugpy`：Python 调试
- `conform.nvim`：代码格式化
- `quarto-nvim`、`otter.nvim`：QMD 支持
- `gitsigns.nvim`：Git 修改标记

## 环境要求

- Neovim 0.12.5
- Git
- Node.js 和 Python
- 可供 Treesitter 编译 parser 的 C 编译器
- 按实际工程安装 IAR 或 Keil 工具链

工具链不在常规路径时，可以将可执行文件加入 PATH，或设置用户环境变量 `IARBUILD`、`UV4_EXE`。

## Windows 安装

如果 `%LOCALAPPDATA%\nvim` 已存在，先将它重命名为备份目录，然后执行：

```powershell
git clone https://github.com/glen-ruan/neovim.git "$env:LOCALAPPDATA\nvim"
nvim
```

首次启动后执行：

```vim
:Lazy sync
:Mason
:TSInstallConfigured
:checkhealth
```

`lazy-lock.json` 已纳入版本控制，`:Lazy sync` 会按照仓库锁定的版本恢复插件。

## 更新和保存配置

获取远程更新：

```powershell
cd "$env:LOCALAPPDATA\nvim"
git pull
```

保存本地修改：

```powershell
cd "$env:LOCALAPPDATA\nvim"
git status
git add .
git commit -m "描述本次 Neovim 配置修改"
git push
```
