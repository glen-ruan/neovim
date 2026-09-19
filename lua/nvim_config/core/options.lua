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

-- Stop comments from continuing automatically.
vim.opt.formatoptions:remove({ "c", "r", "o" })

vim.opt.cursorline = true
-- vim.opt.cursorlineopt = "number" -- Highlight only the line number.

-- Global LSP diagnostic settings.
vim.diagnostic.config({
  signs = true,
  underline = true,
  virtual_text = false, -- tiny-inline-diagnostic renders inline messages.
  update_in_insert = false,
})

-- Open help in a vertical split.
vim.api.nvim_create_user_command("Hv", function(opts)
  vim.cmd("vertical help " .. (opts.args ~= "" and opts.args or ""))
end, { nargs = "*", complete = "help" })

vim.o.modeline = false

-- Treat hyphenated identifiers as one word.
vim.opt.iskeyword:append("-")

-- Allow horizontal movement to wrap across lines.
vim.o.whichwrap = vim.o.whichwrap .. "<>,h,l"

-- Make tools installed below Neovim's data directory visible on every platform.
local platform = require("nvim_config.core.platform")
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
-- These directories may be created by Mason or uv later in this session, so
-- include them even when they do not exist yet.
platform.prepend_path(tool_paths, { must_exist = false })

if platform.is_windows then
  local gcc = vim.fs.joinpath(data, "tools", "w64devkit", "bin", "gcc.exe")
  if vim.fn.executable(gcc) == 1 then
    vim.env.CC = gcc
  end

  -- Keep shell commands, plugin builds, and terminals on UTF-8 PowerShell.
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

-- Optional netrw disable switches.
-- vim.g.loaded_netrw = 1
--
-- -- Disable the netrw plugin layer.
-- vim.g.loaded_netrwPlugin = 1
