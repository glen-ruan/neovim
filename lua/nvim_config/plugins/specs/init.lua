local specs = {}
local module = "nvim_config.plugins.specs."
local source = debug.getinfo(1, "S").source:sub(2)
local directory = vim.fs.dirname(source)
local files = {}

for name, type_ in vim.fs.dir(directory) do
  if type_ == "file" and name:sub(-4) == ".lua" and name ~= "init.lua" then
    table.insert(files, name:sub(1, -5))
  end
end

table.sort(files)
for _, name in ipairs(files) do
  local plugin_specs = require(module .. name)
  if type(plugin_specs[1]) == "string" then
    table.insert(specs, plugin_specs)
  else
    vim.list_extend(specs, plugin_specs)
  end
end

return specs
