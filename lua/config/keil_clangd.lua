local M = {}

local function notify_result(result)
  local text = vim.trim(table.concat({ result.stdout or "", result.stderr or "" }, "\n"))
  if result.code == 0 then
    vim.notify(text ~= "" and text or "Keil clangd 配置已生成")
    pcall(vim.cmd, "LspRestart")
  else
    vim.notify(text ~= "" and text or "Keil clangd 配置生成失败", vim.log.levels.ERROR)
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
  local powershell = vim.fn.exepath("pwsh")
  if powershell == "" then
    powershell = vim.fn.exepath("powershell")
  end
  local script = vim.fn.stdpath("config") .. "/tools/keil-clangd.ps1"
  if powershell == "" or vim.fn.filereadable(script) ~= 1 then
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

  vim.notify("正在从 µVision 工程生成 compile_commands.json…")
  vim.system(command, { cwd = vim.fn.getcwd(), text = true }, function(result)
    vim.schedule(function()
      notify_result(result)
    end)
  end)
end

local function choose_target(project)
  local targets = target_names(project)
  if #targets == 0 then
    vim.notify("该 .uvprojx 中没有 Target", vim.log.levels.ERROR)
  elseif #targets == 1 then
    run(project, targets[1])
  else
    vim.ui.select(targets, { prompt = "选择 Keil Target" }, function(target)
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
    vim.notify("当前目录下没有找到 .uvprojx 工程", vim.log.levels.ERROR)
  elseif #projects == 1 then
    choose_target(projects[1])
  else
    vim.ui.select(projects, {
      prompt = "选择 Keil 工程",
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
  desc = "选择当前目录中的 Keil 工程并生成 clangd 配置",
})

return M
