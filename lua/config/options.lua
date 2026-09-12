vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.opt.mouse = "a"
vim.opt.laststatus = 3
vim.opt.clipboard = "unnamedplus"

-- 禁止自动注释续行
vim.opt.formatoptions:remove({ "c", "r", "o" })

vim.opt.cursorline = true -- 开启光标行高亮（可以只高亮行号）
-- vim.opt.cursorlineopt = "number" -- 只高亮行号，而不是整行

-- 全局 LSP 诊断配置
vim.diagnostic.config({
  signs = true,
  underline = true,
  virtual_text = false, -- 由 tiny-inline-diagnostic 负责行内提示
  update_in_insert = false,
})

-- 创建 :Hv 命令，在垂直分屏中打开帮助
vim.api.nvim_create_user_command("Hv", function(opts)
  vim.cmd("vertical help " .. (opts.args ~= "" and opts.args or ""))
end, { nargs = "*", complete = "help" })

vim.o.modeline = false

-- 添加 '-' 词语
vim.opt.iskeyword:append("-")

-- 使得左右键可以跨行
vim.o.whichwrap = vim.o.whichwrap .. "<>,h,l"

-- Make tools installed below Neovim's data directory visible on every platform.
local platform = require("config.platform")
local data = vim.fn.stdpath("data")
local tool_paths = {}
if vim.env.UV_TOOL_BIN_DIR and vim.env.UV_TOOL_BIN_DIR ~= "" then
  table.insert(tool_paths, vim.env.UV_TOOL_BIN_DIR)
end
table.insert(tool_paths, vim.fs.joinpath(vim.fn.expand("~"), ".local", "bin"))
table.insert(tool_paths, vim.fs.joinpath(data, "mason", "bin"))
table.insert(tool_paths, vim.fs.joinpath(data, "tools", "bin"))
if platform.is_windows then
  table.insert(tool_paths, vim.fs.joinpath(data, "tools", "w64devkit", "bin"))
end
-- must_exist = false：这些目录可能在本会话中才由 mason / uv 创建，
-- 若因为"暂时不存在"被跳过，本次启动就找不到刚装好的语言服务器。
platform.prepend_path(tool_paths, { must_exist = false })

if platform.is_windows then
  local gcc = vim.fs.joinpath(data, "tools", "w64devkit", "bin", "gcc.exe")
  if vim.fn.executable(gcc) == 1 then
    vim.env.CC = gcc
  end

  -- 保证 :!、插件构建和终端命令使用正确的 PowerShell 参数与 UTF-8 输出。
  local powershell = platform.find_executable("powershell", "NVIM_POWERSHELL", { "pwsh", "powershell" })
  if powershell then
    vim.opt.shell = powershell
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
    vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
  end
end

-- 禁止加载 netrw 核心
-- vim.g.loaded_netrw = 1
--
-- -- 禁止加载 netrw 的 plugin 层
-- vim.g.loaded_netrwPlugin = 1
