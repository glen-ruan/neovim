# 配置说明

这套配置默认不依赖用户名、盘符或某台设备的安装目录。可执行程序按照以下顺序解析：

1. `local.lua` 中的显式设置；
2. 对应环境变量；
3. Neovim 的有效 `PATH`，其中会加入用户工具目录、Mason 和配置数据目录中的工具。

## local.lua

复制仓库根目录的 `local.example.lua` 为 `local.lua`。该文件已被 Git 忽略，必须返回一个 Lua table：

```lua
return {
  tools = {
    python = "<absolute-path-to-python>",
    debugpy_python = "<absolute-path-to-debugpy-python>",
    powershell = "<absolute-path-to-powershell>",
    iarbuild = "<absolute-path-to-IarBuild.exe>",
    uv4 = "<absolute-path-to-UV4.exe>",
  },
}
```

只填写无法通过 `PATH` 找到的工具。不要把 `local.lua` 提交到仓库。

## 环境变量

| 变量 | 用途 |
|---|---|
| `NVIM_PYTHON` | 为 Python LSP 和调试目标指定解释器 |
| `DEBUGPY_PYTHON` | 指定安装了 debugpy 的解释器 |
| `NVIM_POWERSHELL` | Windows 下指定 PowerShell 可执行程序 |
| `IARBUILD` | 指定 `IarBuild.exe` |
| `UV4_EXE` | 指定 `UV4.exe` |
| `UV_TOOL_BIN_DIR` | 将 uv 工具目录加入 Neovim 的 `PATH` |

## Python 环境

解析顺序为：

1. `tools.python`；
2. `NVIM_PYTHON`；
3. 从当前文件或工作目录向上查找 `.venv`。

配置不会静默回退到任意系统 Python，以免全局包掩盖工程缺失的依赖。推荐在工程根目录创建 `.venv`。

## 配置位置

配置和数据位置由 Neovim 标准目录决定，可通过以下命令查看，不应在 Lua 配置中写死：

```vim
:lua print(vim.fn.stdpath("config"))
:lua print(vim.fn.stdpath("data"))
:lua print(vim.fn.stdpath("state"))
```
