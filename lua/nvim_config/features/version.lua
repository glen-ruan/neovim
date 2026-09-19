local M = {}

local cached

--- 配置版本号，来自仓库根目录的 VERSION 文件（形如 "1.0.7"）。
--- 结果缓存：状态栏会频繁调用，避免每次都读盘。
--- @return string
function M.get()
  if cached ~= nil then
    return cached
  end
  local path = vim.fs.joinpath(vim.fn.stdpath("config"), "VERSION")
  local ok, lines = pcall(vim.fn.readfile, path)
  local value = ok and vim.trim(lines[1] or "") or ""
  cached = value ~= "" and value or "unknown"
  return cached
end

--- 状态栏用的短标签，形如 "v1.0.7"。
--- @return string
function M.label()
  local version = M.get()
  return version == "unknown" and version or ("v" .. version)
end

--- 详细信息：版本号 + 分支 + 短提交 + 配置目录。
--- 会起 git 进程，所以只在 :ConfigVersion 里按需调用，不放进状态栏。
--- @return string
function M.info()
  local dir = vim.fn.stdpath("config")
  local parts = { "配置版本 " .. M.get() .. "（" .. dir .. "）" }
  if vim.fn.executable("git") == 1 then
    local branch = vim.trim(vim.fn.system({ "git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD" }))
    local commit = vim.trim(vim.fn.system({ "git", "-C", dir, "rev-parse", "--short", "HEAD" }))
    if vim.v.shell_error == 0 and branch ~= "" and commit ~= "" then
      table.insert(parts, string.format("git: %s @ %s", branch, commit))
    end
  end
  return table.concat(parts, "\n")
end

--- 注册 :ConfigVersion 命令。
function M.setup()
  vim.api.nvim_create_user_command("ConfigVersion", function()
    vim.notify(M.info(), vim.log.levels.INFO, { title = "Neovim distribution" })
  end, { desc = "显示当前配置的版本号、分支与提交" })
end

return M
