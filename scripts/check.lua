local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local failures = {}

local function fail(message)
  table.insert(failures, message)
end

local tracked_result = vim.system({ "git", "-C", root, "ls-files", "-z" }, { text = false }):wait()
local tracked_files = {}
if tracked_result.code ~= 0 then
  fail("Unable to list tracked repository files: " .. (tracked_result.stderr or "unknown git error"))
else
  tracked_files = vim.split(tracked_result.stdout or "", "\0", { plain = true, trimempty = true })
end

-- 只检查已跟踪的 Lua 文件；local.lua、日志和 Git worktree 元数据不属于发布内容。
for _, path in ipairs(tracked_files) do
  if path:sub(-4) == ".lua" and (path:match("^lua/") or path:match("^scripts/")) then
    local file = vim.fs.joinpath(root, path)
    local chunk, error_message = loadfile(file)
    if not chunk then
      fail(file .. ": " .. error_message)
    end
  end
end

local required_files = {
  "README.md",
  "local.example.lua",
  "lua/nvim_config/init.lua",
  "lua/nvim_config/dependencies.lua",
  "lua/nvim_config/health.lua",
  "scripts/verify-runtime.lua",
  "docs/configuration.md",
  "docs/dependencies.md",
  "docs/keymaps.md",
  "docs/embedded.md",
  "docs/troubleshooting.md",
  "docs/contributing.md",
}
for _, relative in ipairs(required_files) do
  if vim.fn.filereadable(vim.fs.joinpath(root, relative)) ~= 1 then
    fail("Required file is missing: " .. relative)
  end
end

local ok, example = pcall(dofile, vim.fs.joinpath(root, "local.example.lua"))
if not ok or type(example) ~= "table" or type(example.tools) ~= "table" then
  fail("local.example.lua must return a table containing a tools table")
end

for _, path in ipairs(tracked_files) do
  if path ~= "lazy-lock.json" then
    local file = vim.fs.joinpath(root, path)
    local content = table.concat(vim.fn.readfile(file), "\n")
    local drive_at_start = "^" .. "%a:" .. "[/\\]"
    local drive_after_separator = "[%s\"']" .. "%a:" .. "[/\\]"
    local unix_home = "/" .. "home/" .. "[^/<]+/"
    for line_number, line in ipairs(vim.split(content, "\n", { plain = true })) do
      if line:match(drive_at_start) or line:match(drive_after_separator) or line:match(unix_home) then
        fail(string.format("Machine-specific absolute path: %s:%d", path, line_number))
      end
    end

    if path:match("%.md$") then
      for target in content:gmatch("%[[^%]]+%]%(([^%)]+)%)") do
        if not target:match("^https?://") and not target:match("^#") then
          local clean_target = target:gsub("#.*$", "")
          local resolved = vim.fs.normalize(vim.fs.joinpath(vim.fs.dirname(file), clean_target))
          if clean_target ~= "" and vim.fn.filereadable(resolved) ~= 1 and vim.fn.isdirectory(resolved) ~= 1 then
            fail(string.format("Broken Markdown link in %s: %s", path, target))
          end
        end
      end
    end
  end
end

if #failures > 0 then
  error(table.concat(failures, "\n"))
end
print("Lua syntax check passed")
