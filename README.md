# Neovim 配置发行版

一套面向日常开发、跨平台使用的 Neovim 配置，支持 Windows 与 Linux，最低要求为 Neovim 0.12。配置使用 `lazy.nvim` 锁定插件版本，并把语言服务、调试、写作和嵌入式工具作为按需启用的功能。

## 功能

- Treesitter 语法高亮和代码结构导航
- 原生 Neovim LSP、补全、格式化和诊断
- 文件、全文、Git、符号和历史记录搜索
- 文件树、Buffer 栏、浮动终端和通知历史
- Diffview 文件历史与仓库差异视图
- Python 调试
- Markdown、Quarto 和 LaTeX 写作支持
- Windows 下可选的 IAR、Keil clangd 编译数据库生成工具

## 安装要求

基础安装需要：

- Neovim 0.12 或更新版本
- Git、curl、tar
- ripgrep（命令名为 `rg`）
- `tree-sitter-cli` 0.26.1 或更新版本
- GCC、Clang、MSVC 等可用的 C 编译器

其他工具只影响对应功能。完整分类和安装建议见 [依赖说明](docs/dependencies.md)。

## 安装

安装前请备份已有的 Neovim 配置目录。

Windows PowerShell：

```powershell
git clone --branch main https://github.com/glen-ruan/neovim.git "$env:LOCALAPPDATA\nvim"
& "$env:LOCALAPPDATA\nvim\scripts\bootstrap.ps1"
```

Linux：

```bash
git clone --branch main https://github.com/glen-ruan/neovim.git ~/.config/nvim
~/.config/nvim/scripts/bootstrap.sh
```

引导脚本严格恢复 `lazy-lock.json` 中锁定的插件版本，安装 Mason 工具和 Treesitter parsers，并在失败时返回非零退出码。

## 首次启动

启动 Neovim 后运行：

```vim
:checkhealth nvim_config
:LspAvailability
```

常用入口：

- `空格 f f`：查找文件
- `空格 f g`：全文搜索
- `空格 e`：文件树
- `空格 f t`：浮动终端
- `空格 g l`：仓库文件历史
- `空格 g q`：关闭 Diffview

完整列表见 [快捷键](docs/keymaps.md)。

## 用户配置

仓库不要求设备专用路径。工具能通过 `PATH` 找到时无需额外设置；否则复制 `local.example.lua` 为 `local.lua`，只填写当前设备需要覆盖的项目：

```powershell
Copy-Item local.example.lua local.lua
```

```bash
cp local.example.lua local.lua
```

`local.lua` 已被 Git 忽略，不会进入提交。支持的字段和环境变量见 [配置说明](docs/configuration.md)。

## 更新

```text
cd <Neovim 配置目录>
git pull --ff-only
```

随后重新运行对应平台的 bootstrap 脚本。插件不会在普通启动时自动更新；需要主动升级时使用 `:Lazy update`，并提交更新后的 `lazy-lock.json`。

## 文档

- [配置说明](docs/configuration.md)
- [依赖说明](docs/dependencies.md)
- [快捷键](docs/keymaps.md)
- [嵌入式开发](docs/embedded.md)
- [故障排查](docs/troubleshooting.md)
- [贡献与验证](docs/contributing.md)
- [版本记录](CHANGELOG.md)

## 卸载

删除 Neovim 配置目录即可移除配置。插件、Mason 工具、parser 和运行日志位于 Neovim 的数据目录；若希望完全清理，可在 `:checkhealth nvim_config` 中确认当前配置目录和数据目录后，再单独删除对应数据目录。
