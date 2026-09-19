# 贡献与验证

## 修改原则

- 通用运行时代码不得包含用户名、私人目录、固定盘符或生成状态。
- 设备专属路径只能放在未跟踪的 `local.lua` 或环境变量中。
- 新增用户命令或快捷键时同步更新对应文档。
- 新增外部依赖时同步更新 `lua/nvim_config/dependencies.lua`、health、bootstrap 和依赖文档。
- 插件升级必须提交 `lazy-lock.json`。
- 文档可以使用中文；代码、脚本和配置中的注释、通知、提示及错误信息必须使用英文。此规则由 `scripts/check.lua` 自动检查。

## 本地检查

Lua 语法检查：

```text
nvim --headless -u NONE -i NONE -l scripts/check.lua
```

安装插件后，使用一个能够连接 LSP 的 Lua 文件验证文档中的命令和快捷键：

```text
nvim --headless -i NONE -u init.lua init.lua -l scripts/verify-runtime.lua
```

该检查覆盖核心窗口操作、搜索、Git、DAP、LSP、格式化、Quarto、终端以及用户命令。修改快捷键或用户文档后必须运行。

运行配置检查：

```vim
:checkhealth nvim_config
:LspAvailability
```

交互验证至少覆盖命令行输入、文件与全文搜索、文件树、LSP、格式化、Diffview 和浮动终端，以及本次修改涉及的可选功能。

## 发布

发布前更新 `CHANGELOG.md` 和 `VERSION`，运行 Windows、Linux CI，确认工作树干净，然后创建与 `VERSION` 一致的 Git tag。版本号遵循语义化版本；破坏用户配置或快捷键兼容性的更改必须提升主版本。
