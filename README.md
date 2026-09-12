# Neovim 配置

这是 `glen-ruan` 的跨平台 Neovim 配置发行版，支持 Windows 和 Linux，面向 Neovim 0.12+，使用 `lazy.nvim` 管理插件。所有运行时路径通过 Neovim 标准目录和 PATH 解析，不依赖某台设备的用户名或磁盘目录。

## 文档

- [快捷键说明](docs/Neovim快捷键说明.md)
- [嵌入式开发流程](docs/嵌入式开发流程.md)
- [版本记录](CHANGELOG.md)

## 仓库内容

```text
init.lua                         配置入口
lua/config/options.lua           编辑器选项、PATH 和 PowerShell
lua/config/keymaps.lua           全局快捷键
lua/config/autocmds.lua          自动命令
lua/config/lazy.lua              lazy.nvim 引导和插件导入
lua/config/platform.lua          平台、PATH 和本机配置解析
lua/config/iar_clangd.lua        IAR 语言服务命令
lua/config/keil_clangd.lua       Keil 语言服务命令
lua/plugins/*.lua                插件配置
lua/customs/float_trem.lua       浮动终端
tools/iar-clangd.ps1             IAR 编译数据库生成器
tools/keil-clangd.ps1            Keil 编译数据库生成器
tools/clangd-compat/include      嵌入式 clangd 兼容头文件
docs                             使用文档
scripts                          引导、检查和可选工具安装脚本
scripts/bootstrap.lua            引导脚本主体：恢复插件、安装并校验 Mason 工具与 Treesitter parser
local.example.lua                本机私有路径配置模板
lazy-lock.json                   插件版本锁定文件
VERSION                          发行版本号
stylua.toml                      Lua 格式化配置
```

插件、Mason 工具、Treesitter parser 和日志位于 `stdpath("data")`，不属于本仓库。Windows 通常是 `%LOCALAPPDATA%\nvim-data`，Linux 通常是 `~/.local/share/nvim`。字节码缓存位于 `stdpath("cache")`（Windows 上在 `%TEMP%\nvim` 下，本配置在 Windows 已将其关闭）。

## 主要组件

- `nvim-treesitter`：语法树和高亮
- `nvim-lspconfig`、`mason.nvim`：语言服务器
- `blink.cmp`、`LuaSnip`：补全和代码片段
- `snacks.nvim`：文件、文本、Buffer、Git 和 LSP 搜索
- `neo-tree.nvim`、`bufferline.nvim`：文件树和 Buffer 栏
- `nvim-dap`、`debugpy`：Python 调试
- `conform.nvim`：代码格式化
- `quarto-nvim`、`otter.nvim`：QMD 支持
- `vimtex`：LaTeX 编译（latexmk -xelatex）和 PDF 预览
- `gitsigns.nvim`：Git 修改标记

## 环境要求

- Neovim 0.12+
- Git、curl、tar
- Node.js 和 Python
- `tree-sitter-cli` 0.26.1+ 和可用的 C 编译器
- 按实际工程安装 IAR 或 Keil 工具链

## 本机配置

仓库不保存任何设备专用绝对路径。工具链不在 PATH 时，复制模板并填写当前机器的路径：

```powershell
Copy-Item local.example.lua local.lua
```

```bash
cp local.example.lua local.lua
```

`local.lua` 已被 Git 忽略。也可以使用环境变量 `NVIM_PYTHON`、`DEBUGPY_PYTHON`、`IARBUILD`、`UV4_EXE` 和 `NVIM_POWERSHELL`。

## 安装

Windows：

```powershell
git clone --branch main https://github.com/glen-ruan/neovim.git "$env:LOCALAPPDATA\nvim"
& "$env:LOCALAPPDATA\nvim\scripts\bootstrap.ps1"
```

Linux：

```bash
git clone --branch main https://github.com/glen-ruan/neovim.git ~/.config/nvim
~/.config/nvim/scripts/bootstrap.sh
```

进入 Neovim 后检查：

```vim
:TSInstallConfigured!
:checkhealth nvim_distribution
:LspAvailability
```

`lazy-lock.json` 已纳入版本控制，引导脚本会严格恢复锁定的插件版本并安装通用开发工具，任何一步失败都会以非零退出码结束并说明失败原因。正常启动不会在后台检查插件或 Mason 工具；需要升级插件时执行 `:Lazy update`，需要安装或修复通用开发工具时执行 `:MasonToolsInstall`。`cmake-language-server` 不由 Mason 安装，因为其 Python 版本要求可能与系统 Python 冲突；安装方法见嵌入式开发流程。

## 更新和保存配置

获取远程更新：

```text
cd <Neovim 配置仓库>
git pull
```

保存本地修改：

```text
cd <Neovim 配置仓库>
git status
git add .
git commit -m "描述本次 Neovim 配置修改"
git push
```
