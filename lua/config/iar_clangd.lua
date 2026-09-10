local M = {}
local platform = require("config.platform")

local function output_text(result)
  local parts = {}
  if result.stdout and result.stdout ~= "" then
    table.insert(parts, vim.trim(result.stdout))
  end
  if result.stderr and result.stderr ~= "" then
    table.insert(parts, vim.trim(result.stderr))
  end
  return table.concat(parts, "\n")
end

function M.generate(configuration)
  if vim.fn.has("win32") ~= 1 then
    vim.notify("IarClangd currently supports Windows IAR projects.", vim.log.levels.ERROR)
    return
  end

  local powershell = platform.find_executable("powershell", "NVIM_POWERSHELL", { "pwsh", "powershell" })

  local script = vim.fn.stdpath("config") .. "/tools/iar-clangd.ps1"
  if not powershell or vim.fn.filereadable(script) ~= 1 then
    vim.notify("IAR clangd generator is not installed correctly.", vim.log.levels.ERROR)
    return
  end

  local working_directory = vim.fn.getcwd()
  local command = {
    powershell,
    "-NoLogo",
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    script,
    "-OutputDirectory",
    working_directory,
  }
  if configuration and configuration ~= "" then
    vim.list_extend(command, { "-Configuration", configuration })
  end
  local iarbuild = platform.find_executable("iarbuild", "IARBUILD", { "IarBuild.exe" })
  if iarbuild then
    vim.list_extend(command, { "-IarBuild", iarbuild })
  end

  vim.notify("正在读取 IAR 工程并生成 compile_commands.json…")
  vim.system(command, { cwd = working_directory, text = true }, function(result)
    vim.schedule(function()
      local message = output_text(result)
      if result.code == 0 then
        vim.notify(message ~= "" and message or "IAR clangd 配置已生成")
        pcall(vim.cmd, "lsp restart")
      else
        vim.notify(message ~= "" and message or "IAR clangd 配置生成失败", vim.log.levels.ERROR)
      end
    end)
  end)
end

vim.api.nvim_create_user_command("IarClangd", function(options)
  M.generate(options.args)
end, {
  nargs = "?",
  desc = "从当前目录中的 IAR .ewp 工程生成 clangd 配置",
})

return M
