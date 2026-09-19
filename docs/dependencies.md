# 依赖说明

依赖按影响范围分为基础依赖和功能依赖。缺少功能依赖不会阻止基础编辑器启动。

## 基础依赖

| 工具 | 用途 |
|---|---|
| Neovim 0.12+ | 编辑器运行时 |
| Git | 下载插件和更新配置 |
| curl、tar | 下载与解压工具 |
| ripgrep (`rg`) | `空格 f g` 全文搜索 |
| tree-sitter-cli 0.26.1+ | 编译 Treesitter parsers |
| C 编译器 | 编译 Treesitter parsers |

`tree-sitter-cli` 可通过 `npm install -g tree-sitter-cli` 安装。切换 Node.js 版本后，可能需要重新安装全局 CLI。

## 推荐依赖

| 工具 | 用途 | 缺少时的行为 |
|---|---|---|
| `fd` 或 `fdfind` | 快速文件与项目搜索 | 回退到较慢的实现 |
| Node.js | 部分语言服务器和 Markdown 预览 | 相关功能不可用 |
| GitHub CLI (`gh`) | 在 Neovim 内浏览 GitHub 仓库、Issue 和 PR | Octo 联网功能不可用 |
| `opencode`、`codex`、`claude`、`copilot` | Neovim 内的 AI 对话与 agent（CodeCompanion） | 对应 agent 不可用 |
| 工程 `.venv` | Python LSP 与调试目标 | Python 工程功能给出提示 |

## 功能依赖

| 功能 | 依赖 |
|---|---|
| C/C++ | `clangd`、`clang-format` |
| CMake | `cmake-language-server` |
| Python | `pyright`、`black`、`debugpy` |
| Web | 对应语言服务器和 `prettier` |
| Quarto | `quarto` CLI |
| LaTeX | `latexmk`、`xelatex`；中文排版需要 `ctex` 或 `xeCJK` |
| IAR | Windows、IAR 工具链、`IarBuild.exe` |
| Keil | Windows、Keil MDK、`UV4.exe` |

Mason 管理常见语言服务器、格式化器和 debugpy。系统工具、专有工具链、Quarto、TeX 和 ripgrep 不由 Mason 安装。

Octo 使用 GitHub CLI 访问 GitHub。安装后在每个系统中分别运行 `gh auth login`；Windows 与 WSL 的登录状态互不共用。可用 `gh auth status` 检查状态，Neovim 内可运行 `:checkhealth octo` 检查插件。

CodeCompanion 的 AI 对话走 ACP 适配器，按 PATH 自动识别：`opencode` 自带 ACP，装好并配置过即可直接对话；Codex 与 Claude Code 的对话还需要各自的桥接命令 `codex-acp`、`claude-agent-acp`（只装 `codex` / `claude` 本体时它们只出现在 `空格 a t` 的终端 agent 列表里）。`copilot` 需要已登录的 GitHub Copilot CLI。可用 `:checkhealth codecompanion` 检查适配器状态。

运行 `:checkhealth nvim_config` 查看当前设备实际可用的依赖，运行 `:LspAvailability` 查看语言服务器。
