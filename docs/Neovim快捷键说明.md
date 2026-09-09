# Neovim 快捷键说明

本文对应当前跨平台配置：

- Windows 配置：`%LOCALAPPDATA%\nvim`
- Linux 配置：`~/.config/nvim`
- 数据目录：由 `:lua print(vim.fn.stdpath("data"))` 查询
- Leader 键：空格
- Neovim：0.12.5
- 插件管理：lazy.nvim

本文只记录日常编辑操作和快捷键。IAR、Keil、编译与烧录流程见 [嵌入式开发流程](嵌入式开发流程.md)。

## 1. 打开工程

先在 PowerShell 进入工程根目录，再启动 Neovim：

```text
cd <项目根目录>
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

Python 的标准输出和错误信息显示在底部 DAP REPL 中。程序正常结束后调试面板会保留，查看完输出后按 `F6` 关闭；此时会恢复按 `F5` 前的分屏比例和激活窗口。也可以用 `空格 d u` 隐藏或重新打开面板。

Python LSP 和调试器当前只使用工程目录（或其父目录）中的 `.venv`。全局 Python、Conda、`venv`、`.env` 和 `env` 的自动回退已暂时禁用，避免全局安装的包掩盖当前工程缺少的依赖。已有 `pyproject.toml` 的 uv 工程用 `uv add 包名` 安装依赖；只有 `.venv` 的简单工程可用 `uv pip install --python .venv 包名`。

手动指定解释器：

```vim
:DebugPython <Python 可执行文件路径>
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

## 12. Git 查看

| 操作 | 快捷键或命令 |
|---|---|
| 查看 Git 状态 | `空格 g s` |
| 查看修改片段 | `空格 g d` |
| 查看仓库提交记录 | `:lua Snacks.picker.git_log()` |
| 查看当前文件历史 | `:lua Snacks.picker.git_log_file()` |
| 查看当前行历史 | `:lua Snacks.picker.git_log_line()` |

`gitsigns.nvim` 会在行号旁显示新增、修改和删除标记。提交、推送和分支操作可以在 `空格 f t` 打开的 PowerShell 中执行。

## 13. 插件管理和检查

| 功能 | 命令 |
|---|---|
| 管理和更新插件 | `:Lazy` |
| 管理语言服务器及外部工具 | `:Mason` |
| 检查 Neovim 环境 | `:checkhealth` |
| 安装配置中的 Treesitter parser | `:TSInstallConfigured` |
| 检查格式化工具 | `:ConformInfo` |
| 查看当前 LSP | `:LspInfo` |
