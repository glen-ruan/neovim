local M = {}

local defaults = {
  tools = {},
}

local values = vim.deepcopy(defaults)

local function local_config_path()
  return vim.fs.joinpath(vim.fn.stdpath("config"), "local.lua")
end

function M.setup()
  local path = local_config_path()
  if vim.fn.filereadable(path) ~= 1 then
    return
  end

  local ok, result = pcall(dofile, path)
  if not ok or type(result) ~= "table" then
    local reason = ok and "文件必须返回一个 Lua table" or tostring(result)
    vim.schedule(function()
      vim.notify("无法加载用户配置 " .. path .. ":\n" .. reason, vim.log.levels.ERROR)
    end)
    return
  end

  values = vim.tbl_deep_extend("force", vim.deepcopy(defaults), result)
end

function M.get()
  return values
end

return M
