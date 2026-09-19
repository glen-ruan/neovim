-- Invoked by scripts/bootstrap.ps1 / scripts/bootstrap.sh as:
--   nvim --headless -i NONE -u <config>/init.lua -l <config>/scripts/bootstrap.lua
-- Errors in +cmd still return zero, while Lua errors in -l mode return one.
-- The -l flag skips user configuration, so -u must explicitly load init.lua.

---@param step string
---@param fn fun()
local function run(step, fn)
  local ok, err = pcall(fn)
  if not ok then
    io.stderr:write(string.format("Bootstrap failed [%s]: %s\n", step, tostring(err)))
    error(string.format("Bootstrap stopped at step: %s", step), 0)
  end
  print(string.format("Bootstrap completed [%s]", step))
end

run("prerequisite check", function()
  local missing = {}
  local dependencies = require("nvim_config.dependencies")
  for _, group_name in ipairs({ "core", "search" }) do
    for _, dependency in ipairs(dependencies.commands[group_name]) do
      if dependency.required and not dependencies.resolve(dependency) then
        missing[#missing + 1] = dependency.name
      end
    end
  end
  if vim.fn.executable("tree-sitter") ~= 1 then
    missing[#missing + 1] = "tree-sitter"
  end
  if #missing > 0 then
    error("The following commands are not available in PATH: " .. table.concat(missing, ", "))
  end

  local compiler
  for _, name in ipairs({ "cc", "gcc", "clang", "cl" }) do
    if vim.fn.executable(name) == 1 then
      compiler = vim.fn.exepath(name)
      break
    end
  end
  if not compiler then
    error("A C compiler is required to build Treesitter parsers")
  end
  print("  C compiler: " .. compiler)
end)

run("restore locked plugin versions (:Lazy! restore)", function()
  vim.cmd("Lazy! restore")
end)

run("verify plugin directories", function()
  local missing = {}
  for name, plugin in pairs(require("lazy.core.config").plugins) do
    if plugin.url and plugin.dir and vim.fn.isdirectory(plugin.dir) ~= 1 then
      missing[#missing + 1] = name
    end
  end
  if #missing > 0 then
    table.sort(missing)
    error("The following plugins are not installed: " .. table.concat(missing, ", "))
  end
end)

run("install Mason tools (MasonToolsInstallSync)", function()
  vim.cmd("MasonToolsInstallSync")
end)

run("verify Mason tools", function()
  -- Read ensure_installed from the plugin specification to keep one source of truth.
  local expected = {}
  local spec_path = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "nvim_config", "plugins", "specs", "mason.lua")
  for _, spec in ipairs(dofile(spec_path)) do
    if type(spec) == "table" and spec.opts and spec.opts.ensure_installed then
      vim.list_extend(expected, spec.opts.ensure_installed)
    end
  end

  local registry = require("mason-registry")
  local missing = {}
  for _, name in ipairs(expected) do
    local ok, package = pcall(registry.get_package, name)
    if not ok or not package:is_installed() then
      missing[#missing + 1] = name
    end
  end
  if #missing > 0 then
    error("The following tools are not installed: " .. table.concat(missing, ", "))
  end
end)

run("install Treesitter parsers (TSInstallConfigured!)", function()
  vim.cmd("TSInstallConfigured!")
end)

run("check optional dependencies", function()
  -- Optional dependencies produce hints without stopping bootstrap.
  local hints = {}

  local latex = {}
  for _, name in ipairs({ "latexmk", "xelatex" }) do
    if vim.fn.executable(name) ~= 1 then
      latex[#latex + 1] = name
    end
  end
  if #latex > 0 then
    hints[#hints + 1] = string.format(
      "LaTeX toolchain is missing %s; this configuration uses latexmk -xelatex and compilation will fail with exit code 127.",
      table.concat(latex, "、")
    )
    hints[#hints + 1] =
      "  Ubuntu: sudo apt install texlive-xetex texlive-lang-chinese texlive-latex-extra latexmk"
  elseif vim.fn.executable("kpsewhich") == 1 then
    local absent = {}
    for _, style in ipairs({ "ctex.sty", "xeCJK.sty" }) do
      if vim.trim(vim.fn.system({ "kpsewhich", style })) == "" then
        absent[#absent + 1] = style
      end
    end
    if #absent > 0 then
      hints[#hints + 1] = string.format("Chinese typesetting packages are missing: %s", table.concat(absent, ", "))
      hints[#hints + 1] = "  Ubuntu: sudo apt install texlive-lang-chinese"
    end
  end

  if vim.fn.executable("fd") ~= 1 then
    hints[#hints + 1] = "fd is missing; file and project search will use a slower fallback"
  end

  if #hints > 0 then
    io.stderr:write("Optional dependency hints (bootstrap can still complete):\n")
    for _, hint in ipairs(hints) do
      io.stderr:write("  - " .. hint .. "\n")
    end
  else
    print("  Optional dependencies are ready")
  end
end)

print("Bootstrap completed. Run :checkhealth nvim_config inside Neovim to verify the installation.")
