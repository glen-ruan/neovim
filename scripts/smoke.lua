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
for _, command in ipairs({ "ConfigVersion", "ConfigChangelog", "LspAvailability", "Hv" }) do
  assert(vim.fn.exists(":" .. command) == 2, "missing startup command: " .. command)
end

local mappings = {}
for _, mapping in ipairs(vim.api.nvim_get_keymap("n")) do
  mappings[mapping.lhs] = true
end
for _, lhs in ipairs({ " w", " q", " ft", " e" }) do
  assert(mappings[lhs], "missing startup mapping: " .. lhs)
end

print("Startup smoke check passed")
