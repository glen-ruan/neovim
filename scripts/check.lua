local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local failures = {}

for path, type_ in vim.fs.dir(root .. "/lua", { depth = 20 }) do
  if type_ == "file" and path:sub(-4) == ".lua" then
    local file = vim.fs.joinpath(root, "lua", path)
    local chunk, error_message = loadfile(file)
    if not chunk then
      table.insert(failures, file .. ": " .. error_message)
    end
  end
end

if #failures > 0 then
  error(table.concat(failures, "\n"))
end
print("Lua syntax check passed")
