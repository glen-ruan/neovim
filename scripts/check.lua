local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local failures = {}

local function fail(message)
  table.insert(failures, message)
end

-- 同时检查 lua/ 和 scripts/：引导脚本不在 lua/ 下，不覆盖就只能等到运行时才暴露语法错误。
for _, dir in ipairs({ "lua", "scripts" }) do
  for path, type_ in vim.fs.dir(vim.fs.joinpath(root, dir), { depth = 20 }) do
    if type_ == "file" and path:sub(-4) == ".lua" then
      local file = vim.fs.joinpath(root, dir, path)
      local chunk, error_message = loadfile(file)
      if not chunk then
        fail(file .. ": " .. error_message)
      end
    end
  end
end

local required_files = {
  "README.md",
  "local.example.lua",
  "lua/nvim_config/init.lua",
  "lua/nvim_config/dependencies.lua",
  "lua/nvim_config/health.lua",
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

for path, type_ in vim.fs.dir(root, { depth = 20 }) do
  if type_ == "file" and path ~= ".git" and not path:match("%.log$") and path ~= "lazy-lock.json" then
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
