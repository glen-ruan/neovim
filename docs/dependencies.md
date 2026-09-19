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

运行 `:checkhealth nvim_config` 查看当前设备实际可用的依赖，运行 `:LspAvailability` 查看语言服务器。
