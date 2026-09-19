# 故障排查

## 建议的检查顺序

```vim
:checkhealth nvim_config
:LspAvailability
:Lazy
:Mason
```

先处理 `nvim_config` 报告的基础依赖错误，再检查具体插件。

## 按下 `:` 后无法输入

先完全退出并重新启动 Neovim。Windows 下本配置已关闭 lazy.nvim 字节码缓存，避免临时目录中的缓存文件在运行期间被系统清理后影响命令行界面。

若问题仍存在：

1. 执行 `:Noice history` 查看界面错误；
2. 执行 `:messages` 查看最近消息；
3. 临时执行 `:Noice disable` 判断是否与 Noice 有关；
4. 保存 `:checkhealth` 输出和 Neovim 版本。

## `checkhealth` 报告可选 provider 缺失

Ruby、Perl、Node 和 Python provider 只在插件显式使用对应远程 provider 时需要。本配置的核心功能不依赖 Ruby 或 Perl provider。不要仅为消除所有警告而安装无关运行时。

## `LspAvailability` 显示 missing

运行 `:MasonToolsInstall` 安装由 Mason 管理的工具。`cmake-language-server`、Quarto、TeX、IAR 和 Keil 需要单独安装。安装完成后重启 Neovim，或等待 Mason 完成事件触发语言服务器重新检测。

## 全文搜索不可用

确认终端中 `rg --version` 可以运行。ripgrep 是全文搜索的后端，不由 Mason 安装。

## Diffview 无法退出

按 `空格 g q`，或执行 `:DiffviewClose`。

## VimTeX PDF 预览

在 `.tex` 文件中使用 `\lv`。若 PDF 没有打开，请确认系统已关联 PDF 阅读器；Windows 的 VimTeX 健康检查可能把系统 `start` 启动方式显示为不可执行，此时以实际预览结果为准。

## 收集诊断信息

报告问题时请附上：

- `nvim --version`；
- `:ConfigVersion`；
- `:checkhealth nvim_config`；
- 出现问题前的最小操作步骤；
- 是否存在 `local.lua`，但不要提交其中的绝对路径。
