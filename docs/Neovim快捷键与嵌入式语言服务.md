# Neovim 使用与嵌入式语言服务

本文对应当前 Windows 配置：

- Neovim 配置：`C:\Users\ruan\AppData\Local\nvim`
- Neovim 数据：`C:\Users\ruan\AppData\Local\nvim-data`
- Leader 键：空格
- Neovim：0.12.5
- 插件管理：lazy.nvim

## 1. 打开工程

先在 PowerShell 进入工程根目录，再启动 Neovim：

```powershell
cd D:\path\to\project
nvim .
```

当前工作目录决定文件搜索范围、Neo-tree 起始位置，以及嵌入式语言服务数据库的输出位置。不要从用户主目录启动后再逐层寻找大型工程。

## 2. Buffer、Window 和 Tab 的区别

顶部显示的 `1. 文件名`、`2. 文件名` 是 **Buffer（已打开文件）**。它们由 bufferline.nvim 显示，不是 Vim 原生 Tab 页。

- Buffer：内存中打开的文件。
- Window：一个分屏，用来显示某个 Buffer。
- Tab page：一组 Window 的布局。

从左侧文件树打开文件时，文件会进入当前激活的分屏，并出现在顶部 Buffer 列表。它不会固定在顶部编号 1；编号表示当前 Buffer 排列顺序。

## 3. 常用文件操作

| 操作 | 快捷键或命令 |
|---|---|
| 保存当前文件 | `空格 w` 或 `:w` |
| 关闭当前文件 Buffer | `空格 b d` |
| 强制关闭未保存文件 | `:bd!` |
| 关闭当前分屏 | `空格 s x` |
| 保存并退出当前窗口 | `:wq` |
| 退出全部 Neovim | `:qa` |
| 保存全部并退出 | `:wqa` |
| 新建或打开文件 | `:edit 路径\文件名` |
| 打开/关闭文件树 | `空格 e` |

在 Neo-tree 文件树中：

| 操作 | 按键 |
|---|---|
| 打开文件或目录 | `Enter` |
| 新建文件/目录 | `a`，目录名以 `/` 结尾 |
| 删除文件/目录 | `d` |
| 重命名 | `r` |
| 刷新 | `R` |
| 关闭文件树 | `q` |

`空格 b d` 会保护未保存内容：文件有修改时不会直接关闭，需要先保存或明确使用 `:bd!`。

## 4. Buffer 切换

| 操作 | 快捷键 |
|---|---|
| 下一个 Buffer | `空格 PageDown` |
| 上一个 Buffer | `空格 PageUp` |
| 跳到第 1～9 个 Buffer | `空格 1` ～ `空格 9` |
| 打开 Buffer 列表 | `空格 f b` |
| 显示/隐藏顶部 Buffer 栏 | `空格 t b` |

## 5. 分屏

| 操作 | 快捷键 |
|---|---|
| 左右分屏 | `空格 s v` |
| 上下分屏 | `空格 s h` |
| 平均分配大小 | `空格 s e` |
| 关闭当前分屏 | `空格 s x` |
| 激活左侧分屏 | `空格 ←` |
| 激活下方分屏 | `空格 ↓` |
| 激活上方分屏 | `空格 ↑` |
| 激活右侧分屏 | `空格 →` |

当前激活窗口会显示光标行高亮。状态栏也会显示当前文件和光标位置。

## 6. 搜索和导航

| 操作 | 快捷键 |
|---|---|
| 查找文件 | `空格 f f` |
| 全工程搜索文字 | `空格 f g` |
| 最近文件 | `空格 f r` |
| 工程列表 | `空格 f p` |
| 命令历史 | `空格 :` |
| 搜索历史 | `空格 /` |
| 通知历史 | `空格 n h` |
| 当前文件结构 | `空格 o` |
| Git 状态 | `空格 g s` |
| Git 差异 | `空格 g d` |

Snacks Picker 中使用 `Tab` 向下选择，`Shift+Tab` 向上选择，`Enter` 打开。

## 7. LSP 代码导航

| 操作 | 快捷键 |
|---|---|
| 跳转到定义 | `g d` |
| 跳转到声明 | `g D` |
| 查找引用 | `g r` |
| 跳转到实现 | `g I` |
| 跳转到类型定义 | `g y` |
| 查看调用者 | `g a i` |
| 查看被调用函数 | `g a o` |
| 当前文件符号 | `空格 s s` |
| 工作区符号 | `空格 s S` |
| 重命名符号 | `空格 r n`，输入新名称后回车 |
| 诊断列表 | `空格 x x` 或 `空格 s d` |
| 格式化当前文件 | `空格 c f` |

查看当前语言服务状态：

```vim
:LspInfo
```

重启语言服务：

```vim
:LspRestart
```

## 8. 自动补全

| 操作 | 快捷键 |
|---|---|
| 下一项 | `Tab` 或 `↓` |
| 上一项 | `Shift+Tab` 或 `↑` |
| 接受补全 | `Enter` |
| 主动打开补全/文档 | `Ctrl+Space` |
| 函数签名提示 | `Ctrl+K` |
| 关闭补全窗口 | `Esc` |

补全来源包括 LSP、当前 Buffer、文件路径和代码片段。

## 9. 终端与命令

| 操作 | 快捷键或命令 |
|---|---|
| 打开/关闭浮动终端 | `空格 f t` |
| 从终端输入模式回到普通模式 | `Esc` |
| 临时执行一个 PowerShell 命令 | `:!命令` |
| 打开普通终端 Buffer | `:terminal` |

关闭浮动终端时，如果当前正在输入命令，先按 `Esc`，再按 `空格 f t`。

## 10. Python 调试

| 操作 | 快捷键 |
|---|---|
| 启动/继续 | `F5` |
| 停止调试 | `F6` |
| 添加/取消断点 | `F9` |
| 单步跳过 | `F10` |
| 单步进入 | `F11` |
| 跳出当前函数 | `Shift+F11` |
| 调试面板 | `空格 d u` |
| 查看表达式 | `空格 d e` |
| 条件断点 | `空格 d b` |

调试器依次寻找当前虚拟环境、工程中的 `.venv`/`venv`/`.env`/`env`，最后使用 PATH 中的 Python。

手动指定解释器：

```vim
:DebugPython D:\path\to\.venv\Scripts\python.exe
```

恢复自动选择：

```vim
:DebugPython
```

## 11. Markdown、QMD 和 LaTeX

| 类型 | 操作 |
|---|---|
| Markdown 预览 | `:MarkdownPreview` |
| 停止 Markdown 预览 | `:MarkdownPreviewStop` |
| QMD/Quarto 预览 | `空格 q p` |
| 关闭 QMD 预览 | `空格 q c` |
| LaTeX 编译 | 由 VimTeX 调用 `latexmk -xelatex` |

## 12. 嵌入式语言服务原理

clangd 不会读取 IAR `.ewp` 或 Keil `.uvprojx`。它需要标准文件：

```text
IAR/Keil 工程配置
        ↓
生成 compile_commands.json
        ↓
clangd 读取每个源文件的 CPU、宏和包含路径
        ↓
Neovim 获得补全、跳转、引用和诊断
```

`compile_commands.json` 是机器生成文件。工程增加文件、修改宏、修改包含路径、切换 Target/Configuration 后，要重新生成。

### 12.1 IAR 工程

在包含单个 `.ewp` 的工程根目录启动 Neovim：

```powershell
cd D:\path\to\iar-project
nvim .
```

执行：

```vim
:IarClangd
```

工程有多个 Configuration 时指定名称：

```vim
:IarClangd Debug
```

当前电脑使用旧版 IAR，生成器调用 IAR 官方的 dry-run 输出，取得每个源文件的真实宏和包含目录，再转换为 clangd 参数。

目录中有多个 `.ewp` 时，在 PowerShell 明确指定：

```powershell
& "$env:LOCALAPPDATA\nvim\tools\iar-clangd.ps1" `
  -Project ".\Project\CPU\EWARM\Project.ewp" `
  -Configuration "FWLib"
```

### 12.2 Keil MDK5 工程

当前 SPC2168 SDK：

```powershell
cd D:\workfile\project\Keil_Project\SP\dc9fd94389a51e3b4b1ce6579260b391\SPC2168_FW_V1_6
nvim .
```

执行：

```vim
:KeilClangd
```

操作顺序：

1. 从列表选择一个 `.uvprojx` 工程。
2. 如果该工程有多个 Target，再选择 Target。
3. 工具调用 µVision 官方 `-et` 导出目标配置。
4. 临时 `.cprj` 被解析后恢复或删除。
5. 在当前 Neovim 工作目录生成 `compile_commands.json`。
6. clangd 自动重启。

这套 SDK 有 76 个示例工程，一次只能激活一个工程的编译配置。切换示例后再次执行 `:KeilClangd`。共享驱动文件的宏和包含目录会跟随最后选中的工程。

当前已验证的配置：

- 工程：`Project\0_Examples\Template\MDK-ARM\Project.uvprojx`
- Target：`FWLib`
- 编译器：Arm Compiler 5
- CPU：Cortex-M4
- FPU：单精度硬件 FPU，softfp ABI
- 编译数据库：23 个 C 源文件

命令行方式：

```powershell
& "$env:LOCALAPPDATA\nvim\tools\keil-clangd.ps1" `
  -Project ".\Project\0_Examples\Template\MDK-ARM\Project.uvprojx" `
  -Target "FWLib" `
  -OutputDirectory (Get-Location)
```

若 Keil 或 IAR 安装在其他位置，可以设置用户环境变量：

```powershell
[Environment]::SetEnvironmentVariable("UV4_EXE", "C:\Keil_v5\UV4\UV4.exe", "User")
[Environment]::SetEnvironmentVariable("IARBUILD", "C:\path\to\common\bin\IarBuild.exe", "User")
```

## 13. 当前主要插件

| 类别 | 插件 | 用途 |
|---|---|---|
| 插件管理 | lazy.nvim | 安装、更新和锁定插件 |
| 语法 | nvim-treesitter | C/C++、Python、Lua、Markdown、QMD 等语法树 |
| LSP | nvim-lspconfig、mason.nvim | clangd、Pyright、Lua、Web、CMake、Bash、LaTeX 服务 |
| 补全 | blink.cmp、LuaSnip | LSP 补全、路径、Buffer 和代码片段 |
| 文件 | neo-tree.nvim | 左侧文件树 |
| 搜索 | snacks.nvim | 文件、文字、Buffer、Git 和 LSP 搜索 |
| 顶部文件栏 | bufferline.nvim | 显示和切换 Buffer |
| 结构 | aerial.nvim | 函数、类型和变量大纲 |
| 诊断 | trouble.nvim、tiny-inline-diagnostic.nvim | 诊断列表和行内提示 |
| 格式化 | conform.nvim | clang-format、Black、Prettier、Stylua 等 |
| 调试 | nvim-dap、nvim-dap-python、nvim-dap-ui | Python 断点调试 |
| Git | gitsigns.nvim | 修改标记 |
| 编辑 | nvim-autopairs、inc-rename.nvim | 自动括号和重命名 |
| 文档 | quarto-nvim、otter.nvim、markdown-preview.nvim、vimtex | QMD、Markdown、LaTeX |
| 界面 | onedark.nvim、lualine.nvim、noice.nvim、neoscroll.nvim | 主题、状态栏、命令行和滚动效果 |

Telescope 和 Avante 的配置文件仍保留，但目前返回空配置，没有加载。当前查找功能由 Snacks Picker 提供。

## 14. 新机器恢复

1. 复制整个 `C:\Users\ruan\AppData\Local\nvim`。
2. 启动 Neovim 后执行 `:Lazy sync`。
3. 执行 `:Mason` 检查 clangd、Pyright 等语言服务。
4. 执行 `:TSInstallConfigured` 安装本配置使用的 Treesitter 解析器。
5. 安装项目实际使用的 IAR 或 Keil，并按需设置 `IARBUILD`、`UV4_EXE`。
6. 进入嵌入式工程后执行 `:IarClangd` 或 `:KeilClangd`。
