local M = {}

local function executable(name, required)
  local path = vim.fn.exepath(name)
  if path ~= "" then
    vim.health.ok(name .. ": " .. path)
  elseif required then
    vim.health.error(name .. " was not found", { "Install it and make it available in PATH." })
  else
    vim.health.warn(name .. " was not found (optional)")
  end
end

local function compiler()
  for _, name in ipairs({ "cc", "gcc", "clang", "cl" }) do
    local path = vim.fn.exepath(name)
    if path ~= "" then
      vim.health.ok("C compiler: " .. path)
      return
    end
  end
  vim.health.error("A C compiler was not found", { "Install GCC, Clang, MSVC, or w64devkit for Treesitter." })
end

function M.check()
  local platform = require("config.platform")
  vim.health.start("Neovim distribution")
  local version = vim.version()
  vim.health.info(string.format("Neovim %d.%d.%d", version.major, version.minor, version.patch))
  vim.health.info("config: " .. vim.fn.stdpath("config"))
  vim.health.info("data: " .. vim.fn.stdpath("data"))
  vim.health.info("platform: " .. (platform.is_windows and "Windows" or platform.is_linux and "Linux" or "Unix"))

  executable("git", true)
  executable("curl", true)
  executable("tar", true)
  executable("tree-sitter", true)
  compiler()
  executable("rg", false)
  executable("fd", false)
  executable("node", false)
  executable("clangd", false)
  executable("cmake-language-server", false)

  local python = platform.project_python()
  if python then
    vim.health.ok("Python: " .. python)
  else
    vim.health.warn("Python was not found")
  end

  local debugpy = platform.debugpy_python()
  if debugpy then
    vim.health.ok("debugpy Python: " .. debugpy)
  else
    vim.health.warn("debugpy is not installed; run :MasonToolsInstall")
  end

  if platform.is_windows then
    local iar = platform.find_executable("iarbuild", "IARBUILD", { "IarBuild.exe" })
    local keil = platform.find_executable("uv4", "UV4_EXE", { "UV4.exe" })
    if iar then
      vim.health.ok("IAR: " .. iar)
    else
      vim.health.warn("IAR not configured (optional)")
    end
    if keil then
      vim.health.ok("Keil: " .. keil)
    else
      vim.health.warn("Keil not configured (optional)")
    end
  end
end

return M
