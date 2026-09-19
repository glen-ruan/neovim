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
for _, plugin in ipairs({
  "folke/snacks.nvim",
  "pwntester/octo.nvim",
  "stevearc/aerial.nvim",
  "smjonas/inc-rename.nvim",
}) do
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
assert(not windows.close(), "utility buffers should reject the editor-only quit action")
assert(vim.api.nvim_get_current_buf() == special, "the editor-only quit action closed a utility buffer")
vim.api.nvim_buf_delete(special, { force = true })

local github = require("nvim_config.features.github")
github.setup()
local github_view = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(github_view)
vim.bo[github_view].buftype = "acwrite"
vim.bo[github_view].filetype = "octo"
for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
  if buffer ~= github_view and vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == "" then
    vim.api.nvim_buf_delete(buffer, { force = true })
  end
end
assert(vim.fn.maparg("q", "n", false, true).buffer == 1, "Octo views must have a buffer-local safe close mapping")
assert(github.close_view(), "Octo views should close safely")
assert(windows.is_editor_buffer(), "safe GitHub view close should create a replacement editor buffer")
assert(vim.api.nvim_buf_is_valid(0), "safe GitHub view close should keep Neovim running")

local lsp_features = require("nvim_config.features.lsp")
local original_hover = vim.lsp.buf.hover
local original_signature_help = vim.lsp.buf.signature_help
local hover_options
local signature_options
vim.lsp.buf.hover = function(options)
  hover_options = options
end
vim.lsp.buf.signature_help = function(options)
  signature_options = options
end
lsp_features.hover()
lsp_features.signature_help()
vim.lsp.buf.hover = original_hover
vim.lsp.buf.signature_help = original_signature_help
assert(hover_options and hover_options.focusable == false, "hover must remain a passive floating window")
assert(
  signature_options and signature_options.focusable == false,
  "signature help must remain a passive floating window"
)

print("Startup smoke check passed")
