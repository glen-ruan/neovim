local M = {}

local cached

--- Configuration version read from the repository's VERSION file.
--- Cache the result because the statusline calls this frequently.
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

--- Short statusline label such as "v1.0.7".
--- @return string
function M.label()
  local version = M.get()
  return version == "unknown" and version or ("v" .. version)
end

--- Detailed version, branch, short commit, and configuration directory.
--- This starts Git, so call it on demand rather than from the statusline.
--- @return string
function M.info()
  local dir = vim.fn.stdpath("config")
  local parts = { "Configuration version " .. M.get() .. " (" .. dir .. ")" }
  if vim.fn.executable("git") == 1 then
    local branch = vim.trim(vim.fn.system({ "git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD" }))
    local commit = vim.trim(vim.fn.system({ "git", "-C", dir, "rev-parse", "--short", "HEAD" }))
    if vim.v.shell_error == 0 and branch ~= "" and commit ~= "" then
      table.insert(parts, string.format("git: %s @ %s", branch, commit))
    end
  end
  return table.concat(parts, "\n")
end

--- Register the :ConfigVersion command.
function M.setup()
  vim.api.nvim_create_user_command("ConfigVersion", function()
    vim.notify(M.info(), vim.log.levels.INFO, { title = "Neovim distribution" })
  end, { desc = "Show the current configuration version, branch, and commit" })
end

return M
