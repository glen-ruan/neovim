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

-- VimTeX only calls the toolchain when a document is compiled, so a missing
-- LaTeX install fails late and far from its cause. Report it here instead.
local function latex()
  local missing = {}
  for _, name in ipairs({ "latexmk", "xelatex" }) do
    if vim.fn.exepath(name) == "" then
      missing[#missing + 1] = name
    end
  end

  if #missing > 0 then
    vim.health.warn("LaTeX toolchain is incomplete, missing: " .. table.concat(missing, ", "), {
      "This config always runs `latexmk -xelatex` (fontspec needs XeLaTeX); without xelatex compilation fails with exit code 127.",
      "Ubuntu: sudo apt install texlive-xetex texlive-lang-chinese texlive-latex-extra latexmk",
      "Only needed when writing LaTeX; ignore this otherwise.",
    })
    return
  end

  vim.health.ok("latexmk: " .. vim.fn.exepath("latexmk"))
  vim.health.ok("xelatex: " .. vim.fn.exepath("xelatex"))

  if vim.fn.executable("kpsewhich") ~= 1 then
    return
  end

  local absent = {}
  for _, style in ipairs({ "ctex.sty", "xeCJK.sty" }) do
    if vim.trim(vim.fn.system({ "kpsewhich", style })) == "" then
      absent[#absent + 1] = style
    end
  end
  if #absent > 0 then
    vim.health.warn("Chinese typesetting packages are missing: " .. table.concat(absent, ", "), {
      "Typesetting Chinese documents needs ctex / xeCJK.",
      "Ubuntu: sudo apt install texlive-lang-chinese",
    })
  else
    vim.health.ok("Chinese typesetting: ctex / xeCJK")
  end
end

-- The CLI is only needed to build parsers, so a missing or outdated one stays
-- invisible until :TSInstallConfigured! fails. Check it explicitly.
local function tree_sitter()
  local path = vim.fn.exepath("tree-sitter")
  if path == "" then
    vim.health.error("tree-sitter was not found", {
      "This config builds Treesitter parsers with the CLI; already-compiled parsers keep working without it.",
      "Install it with: npm install -g tree-sitter-cli",
    })
    return
  end

  local minimum = { 0, 26, 1 }
  local major, minor, patch = vim.fn.system({ "tree-sitter", "--version" }):match("(%d+)%.(%d+)%.(%d+)")
  local found = major and { tonumber(major), tonumber(minor), tonumber(patch) } or nil
  if found and not vim.version.ge(found, minimum) then
    vim.health.error(string.format("tree-sitter %s is too old", table.concat(found, ".")), {
      string.format("At least %s is required.", table.concat(minimum, ".")),
      "Upgrade it with: npm install -g tree-sitter-cli",
    })
    return
  end

  vim.health.ok("tree-sitter: " .. path .. (found and (" (" .. table.concat(found, ".") .. ")") or ""))
end

-- Snacks' grep picker hardcodes `rg` and has no fallback, so a missing ripgrep
-- breaks a bound keymap instead of merely slowing searches down.
local function ripgrep()
  local path = vim.fn.exepath("rg")
  if path ~= "" then
    vim.health.ok("rg: " .. path)
    return
  end
  vim.health.error("rg was not found", {
    "`Snacks.picker.grep()` has no fallback, so the `<leader>fg` keymap cannot work without it.",
    "Mason does not provide ripgrep; install it with the system package manager, e.g. Ubuntu: sudo apt install ripgrep",
  })
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
  tree_sitter()
  compiler()
  ripgrep()
  executable("fd", false)
  executable("node", false)
  executable("clangd", false)
  executable("cmake-language-server", false)
  latex()

  local python = platform.project_python()
  if python then
    vim.health.ok("Project .venv Python: " .. python)
  else
    vim.health.warn("No project .venv was found from the current working directory")
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
