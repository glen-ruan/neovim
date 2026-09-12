local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local failures = {}

-- 同时检查 lua/ 和 scripts/：引导脚本不在 lua/ 下，不覆盖就只能等到运行时才暴露语法错误。
for _, dir in ipairs({ "lua", "scripts" }) do
  for path, type_ in vim.fs.dir(vim.fs.joinpath(root, dir), { depth = 20 }) do
    if type_ == "file" and path:sub(-4) == ".lua" then
      local file = vim.fs.joinpath(root, dir, path)
      local chunk, error_message = loadfile(file)
      if not chunk then
        table.insert(failures, file .. ": " .. error_message)
      end
    end
  end
end

if #failures > 0 then
  error(table.concat(failures, "\n"))
end
print("Lua syntax check passed")
