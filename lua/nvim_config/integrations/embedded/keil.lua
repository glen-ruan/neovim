local M = {}
local platform = require("nvim_config.core.platform")

local function notify_result(result)
  local text = vim.trim(table.concat({ result.stdout or "", result.stderr or "" }, "\n"))
  if result.code == 0 then
    vim.notify(text ~= "" and text or "Keil clangd configuration generated")
    pcall(vim.cmd, "lsp restart")
  else
    vim.notify(text ~= "" and text or "Failed to generate the Keil clangd configuration", vim.log.levels.ERROR)
  end
end

local function target_names(project)
  local names = {}
  for _, line in ipairs(vim.fn.readfile(project)) do
    local name = line:match("<TargetName>(.-)</TargetName>")
    if name and name ~= "" then
      table.insert(names, name)
    end
  end
  return names
end

local function run(project, target)
  local powershell = platform.find_executable("powershell", "NVIM_POWERSHELL", { "pwsh", "powershell" })
  local script = vim.fn.stdpath("config") .. "/tools/keil-clangd.ps1"
  if not powershell or vim.fn.filereadable(script) ~= 1 then
    vim.notify("Keil clangd generator is not installed correctly.", vim.log.levels.ERROR)
    return
  end

  local command = {
    powershell,
    "-NoLogo",
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    script,
    "-Project",
    project,
    "-Target",
    target,
    "-OutputDirectory",
    vim.fn.getcwd(),
  }
  local uv4 = platform.find_executable("uv4", "UV4_EXE", { "UV4.exe" })
  if uv4 then
    vim.list_extend(command, { "-UV4", uv4 })
  end

  vim.notify("Generating compile_commands.json from the µVision project...")
  vim.system(command, { cwd = vim.fn.getcwd(), text = true }, function(result)
    vim.schedule(function()
      notify_result(result)
    end)
  end)
end

local function choose_target(project)
  local targets = target_names(project)
  if #targets == 0 then
      vim.notify("The .uvprojx file does not contain any targets", vim.log.levels.ERROR)
  elseif #targets == 1 then
    run(project, targets[1])
  else
    vim.ui.select(targets, { prompt = "Select a Keil target" }, function(target)
      if target then
        run(project, target)
      end
    end)
  end
end

function M.generate()
  local cwd = vim.fn.getcwd()
  local projects = vim.fs.find(function(name)
    return name:lower():sub(-8) == ".uvprojx"
  end, { path = cwd, type = "file", limit = 500 })

  table.sort(projects)
  if #projects == 0 then
      vim.notify("No .uvprojx project was found in the current directory", vim.log.levels.ERROR)
  elseif #projects == 1 then
    choose_target(projects[1])
  else
    vim.ui.select(projects, {
      prompt = "Select a Keil project",
      format_item = function(path)
        return vim.fs.relpath(cwd, path) or path
      end,
    }, function(project)
      if project then
        choose_target(project)
      end
    end)
  end
end

vim.api.nvim_create_user_command("KeilClangd", M.generate, {
    desc = "Select a Keil project in the current directory and generate clangd configuration",
})

return M
