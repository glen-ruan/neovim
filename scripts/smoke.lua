local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
vim.opt.runtimepath:prepend(root)

local captured
package.preload.lazy = function()
  return {
    setup = function(options)
      captured = options
    end,
  }
end

dofile(vim.fs.joinpath(root, "init.lua"))

assert(captured and type(captured.spec) == "table" and #captured.spec > 0, "plugin specifications were not loaded")

local plugin_specs = {}
for _, spec in ipairs(captured.spec) do
  if type(spec) == "table" and type(spec[1]) == "string" then
    plugin_specs[spec[1]] = spec
  end
end
for _, plugin in ipairs({ "folke/snacks.nvim", "stevearc/aerial.nvim", "smjonas/inc-rename.nvim" }) do
  local spec = plugin_specs[plugin]
  assert(spec, "missing plugin specification: " .. plugin)
  assert(type(spec.keys) == "table" and #spec.keys > 0, "plugin keymaps were dropped: " .. plugin)
end

for _, command in ipairs({ "ConfigVersion", "ConfigChangelog", "LspAvailability", "LspInfo", "Hv" }) do
  assert(vim.fn.exists(":" .. command) == 2, "missing startup command: " .. command)
end

local mappings = {}
for _, mapping in ipairs(vim.api.nvim_get_keymap("n")) do
  mappings[mapping.lhs] = true
end
for _, lhs in ipairs({ " w", " q", " ft", " e" }) do
  assert(mappings[lhs], "missing startup mapping: " .. lhs)
end

local windows = require("nvim_config.core.windows")
assert(windows.is_editor_buffer(0), "the initial buffer should be treated as an editor buffer")
local window_count = #vim.api.nvim_list_wins()
assert(windows.split("vsplit"), "editor buffers should allow manual splits")
assert(#vim.api.nvim_list_wins() == window_count + 1, "the editor split was not created")
vim.cmd.close()

local special = vim.api.nvim_create_buf(false, true)
assert(not windows.is_editor_buffer(special), "nofile buffers must not be treated as editor buffers")
vim.api.nvim_set_current_buf(special)
window_count = #vim.api.nvim_list_wins()
assert(not windows.split("vsplit"), "utility buffers should reject manual splits")
assert(#vim.api.nvim_list_wins() == window_count, "a utility-buffer split was created")
vim.api.nvim_buf_delete(special, { force = true })

print("Startup smoke check passed")
