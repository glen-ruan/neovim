# Neovim 配置说明

本配置用于 Windows 上的 Neovim 0.12.5，插件由 `lazy.nvim` 管理。实际配置目录为：

完整操作手册：[Neovim 快捷键与嵌入式语言服务](docs/Neovim快捷键与嵌入式语言服务.md)。其中包含文件管理、Buffer、分屏、终端、LSP、补全、Python 调试、QMD，以及 IAR/Keil 工程的语言服务流程。

```text
C:\Users\ruan\AppData\Local\nvim
```

插件、解析器和 Mason 工具保存在：

```text
C:\Users\ruan\AppData\Local\nvim-data
```

## 目录结构

- `init.lua`：配置入口
- `lua/config/options.lua`：编辑器选项、Windows PATH 和 PowerShell 设置
- `lua/config/keymaps.lua`：全局快捷键
- `lua/config/autocmds.lua`：自动命令
- `lua/config/lazy.lua`：插件导入
- `lua/plugins/*.lua`：各插件配置
- `lua/customs/float_trem.lua`：可复用的浮动终端

## 主要插件

- `nvim-treesitter`：Python、C/C++、QMD/Markdown、Lua、Web 等语法高亮
- `nvim-lspconfig` + `mason.nvim`：语言服务器
- `blink.cmp` + `LuaSnip`：补全和代码片段
- `snacks.nvim`：文件、文本、缓冲区和符号搜索
- `neo-tree.nvim`：左侧文件树
- `bufferline.nvim`：顶部文件列表
- `nvim-dap` + `debugpy`：Python 调试
- `conform.nvim`：手动格式化
- `quarto-nvim` + `otter.nvim`：QMD 支持
- `aerial.nvim`：代码结构大纲
- `trouble.nvim`、`tiny-inline-diagnostic.nvim`：诊断显示
- `markdown-preview.nvim`：Markdown 浏览器预览

## 常用快捷键

`<leader>` 是空格。

| 功能 | 快捷键 |
| --- | --- |
| 保存文件 | `<Space>w` |
| 关闭当前文件 | `<Space>bd` |
| 打开/关闭文件树 | `<Space>e` |
| 查找文件 | `<Space>ff` |
| 搜索项目文字 | `<Space>fg` |
| 切换已打开文件 | `<Space>fb` |
| 最近文件 | `<Space>fr` |
| 上一个/下一个文件 | `<Space><PageUp>` / `<Space><PageDown>` |
| 跳到第 1～9 个文件 | `<Space>1` ～ `<Space>9` |
| 垂直/水平分屏 | `<Space>sv` / `<Space>sh` |
| 平均分配分屏 | `<Space>se` |
| 关闭当前分屏 | `<Space>sx` |
| 切换分屏 | `<Space>` + 方向键 |
| 打开/关闭浮动终端 | `<Space>ft` |
| 终端回普通模式 | `Esc` |
| 从终端切换窗口 | `Ctrl+w` 后接方向键 |
| 诊断列表 | `<Space>xx` |
| 代码结构 | `<Space>o` |
| 重命名符号 | `<Space>rn` |
| 格式化当前文件 | `<Space>cf` |
| QMD 预览/关闭预览 | `<Space>qp` / `<Space>qc` |

Python 调试：`F5` 启动或继续，`F9` 切换断点，`F10` 单步跳过，`F11` 单步进入，`Shift+F11` 跳出，`F6` 停止，`<Space>du` 切换调试面板。

## 管理和检查

- `:Lazy`：管理插件
- `:Mason`：管理语言服务器和外部工具
- `:checkhealth`：检查运行状态
- `:TSInstallConfigured`：重新安装本配置使用的 Treesitter 解析器
- `:ConformInfo`：检查格式化工具
- `:LspInfo`：查看当前文件的语言服务器

## Git 管理与新机器恢复

仓库跟踪 `lazy-lock.json`，因此 `:Lazy sync` 会尽量恢复相同的插件版本。`nvim-data` 不属于仓库；它保存下载的插件、Mason 工具、Treesitter parser、日志和缓存，应该由 Neovim 在每台机器上重新生成。

在当前机器查看改动并保存一个版本：

```powershell
cd "$env:LOCALAPPDATA\nvim"
git status
git add .
git commit -m "描述本次 Neovim 配置修改"
```

绑定远程仓库后首次上传：

```powershell
git remote add origin <你的仓库地址>
git push -u origin main
```

在另一台 Windows 机器恢复：

```powershell
git clone <你的仓库地址> "$env:LOCALAPPDATA\nvim"
nvim
```

首次启动后运行 `:Lazy sync`，再用 `:Mason` 检查语言服务器和外部工具。需要提前安装 Git、Node.js、Python，以及可供 Treesitter 编译 parser 的 C 编译器。嵌入式工程还需要对应的 IAR 或 Keil 工具链；可以把 `IarBuild.exe`、`UV4.exe` 加入 PATH，或分别设置 `IARBUILD_EXE`、`UV4_EXE` 环境变量。
