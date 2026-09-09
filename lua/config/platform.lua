local M = {}

M.is_windows = vim.fn.has("win32") == 1
M.is_linux = vim.fn.has("linux") == 1
M.path_separator = M.is_windows and ";" or ":"

local local_config_path = vim.fs.joinpath(vim.fn.stdpath("config"), "local.lua")
local ok, settings = pcall(dofile, local_config_path)
if not ok or type(settings) ~= "table" then
  settings = {}
end
M.settings = settings

local function usable(command)
  return command and command ~= "" and vim.fn.executable(command) == 1
end

function M.find_executable(setting_name, environment_name, candidates)
  local tools = type(settings.tools) == "table" and settings.tools or {}
  local configured = setting_name and tools[setting_name] or nil
  if usable(configured) then
    return vim.fn.exepath(configured) ~= "" and vim.fn.exepath(configured) or configured
  end

  local environment_value = environment_name and vim.env[environment_name]
  if usable(environment_value) then
    return vim.fn.exepath(environment_value) ~= "" and vim.fn.exepath(environment_value) or environment_value
  end

  for _, candidate in ipairs(candidates or {}) do
    if usable(candidate) then
      return vim.fn.exepath(candidate) ~= "" and vim.fn.exepath(candidate) or candidate
    end
  end
  return nil
end

function M.prepend_path(paths)
  local current = vim.env.PATH or ""
  local present = {}
  for entry in current:gmatch("[^" .. M.path_separator .. "]+") do
    local normalized = vim.fs.normalize(entry)
    present[M.is_windows and normalized:lower() or normalized] = true
  end

  local additions = {}
  for _, path in ipairs(paths) do
    if path and path ~= "" and vim.fn.isdirectory(path) == 1 then
      local normalized = vim.fs.normalize(path)
      local key = M.is_windows and normalized:lower() or normalized
      if not present[key] then
        table.insert(additions, normalized)
        present[key] = true
      end
    end
  end

  if #additions > 0 then
    vim.env.PATH = table.concat(additions, M.path_separator) .. M.path_separator .. current
  end
end

function M.project_python(start_path)
  local configured = M.find_executable("python", "NVIM_PYTHON", {})
  if configured then
    return configured
  end

  local suffixes = M.is_windows and { "Scripts/python.exe", "python.exe" } or { "bin/python", "bin/python3" }
  local environments = { "VIRTUAL_ENV", "CONDA_PREFIX" }
  for _, name in ipairs(environments) do
    local environment = vim.env[name]
    if environment and environment ~= "" then
      for _, suffix in ipairs(suffixes) do
        local candidate = vim.fs.joinpath(environment, suffix)
        if usable(candidate) then
          return candidate
        end
      end
    end
  end

  local directory = start_path and vim.fs.dirname(start_path) or vim.fn.getcwd()
  while directory and directory ~= "" do
    for _, name in ipairs({ ".venv", "venv", ".env", "env" }) do
      for _, suffix in ipairs(suffixes) do
        local candidate = vim.fs.joinpath(directory, name, suffix)
        if usable(candidate) then
          return candidate
        end
      end
    end
    local parent = vim.fs.dirname(directory)
    if not parent or parent == directory then
      break
    end
    directory = parent
  end

  local names = M.is_windows and { "python", "python3" } or { "python3", "python" }
  return M.find_executable(nil, nil, names)
end

function M.debugpy_python()
  local data = vim.fn.stdpath("data")
  local candidates = M.is_windows
      and {
        vim.fs.joinpath(data, "mason", "packages", "debugpy", "venv", "Scripts", "python.exe"),
        vim.fs.joinpath(data, "tools", "debugpy", "Scripts", "python.exe"),
      }
    or {
      vim.fs.joinpath(data, "mason", "packages", "debugpy", "venv", "bin", "python"),
      vim.fs.joinpath(data, "tools", "debugpy", "bin", "python"),
    }
  return M.find_executable("debugpy_python", "DEBUGPY_PYTHON", candidates)
end

return M
