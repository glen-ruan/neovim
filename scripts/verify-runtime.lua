local failures = {}

local function fail(message)
  table.insert(failures, message)
end

local function has_mapping(mode, lhs, buffer)
  local mapping = vim.fn.maparg(lhs, mode, false, true)
  if type(mapping) ~= "table" or not mapping.lhs or mapping.lhs == "" then
    fail(string.format("missing %s-mode mapping: %s%s", mode, lhs, buffer and " (buffer-local)" or ""))
  elseif buffer and mapping.buffer ~= 1 then
    fail(string.format("mapping is not buffer-local: %s-mode %s", mode, lhs))
  end
end

local function has_command(name)
  if vim.fn.exists(":" .. name) ~= 2 then
    fail("missing command: " .. name)
  end
end

-- The file buffer named on the command line is the reference buffer for the
-- buffer-local contracts below; the sections in between switch the current
-- buffer to scratch buffers of their own.
local verification_buffer = vim.api.nvim_get_current_buf()

vim.wait(3000, function()
  return package.loaded["lazy.core.config"] ~= nil
end)

for _, name in ipairs({
  "ConfigVersion",
  "ConfigChangelog",
  "LspAvailability",
  "LspInfo",
  "Hv",
  "MarkdownPreviewToggle",
  "DiffviewClose",
  "ConformInfo",
  "TSInstallConfigured",
}) do
  has_command(name)
end
if vim.fn.has("win32") == 1 then
  has_command("IarClangd")
  has_command("KeilClangd")
end

for _, lhs in ipairs({
  "<leader>w",
  "<leader>q",
  "<leader>bd",
  "<leader><PageDown>",
  "<leader><PageUp>",
  "<leader>1",
  "<leader>9",
  "<leader><Left>",
  "<leader><Down>",
  "<leader><Up>",
  "<leader><Right>",
  "<leader>sv",
  "<leader>sh",
  "<leader>se",
  "<leader>sx",
  "<leader>vv",
  "<leader>vc",
  "<leader>vl",
  "<Esc>",
  "<leader>ft",
  "<leader>xx",
  "<leader>e",
  "<leader>tb",
  "<leader>fb",
  "<leader>ff",
  "<leader>fg",
  "<leader>fp",
  "<leader>fr",
  "<leader>:",
  "<leader>/",
  "<leader>sd",
  "gd",
  "gD",
  "grr",
  "gI",
  "gy",
  "gai",
  "gao",
  "<leader>gs",
  "<leader>gd",
  "<leader>ss",
  "<leader>sS",
  "<leader>nh",
  "<leader>ghr",
  "<leader>ghc",
  "<leader>ghi",
  "<leader>ghp",
  "<leader>ghd",
  "<leader>ghl",
  "<leader>ghn",
  "<leader>ghs",
  "<leader>o",
  "<leader>rn",
  "<leader>gv",
  "<leader>gq",
  "<leader>gf",
  "<leader>gl",
  "<leader>cf",
}) do
  has_mapping("n", lhs)
end

require("lazy").load({ plugins = { "octo.nvim" } })
has_command("Octo")
local octo_ok, octo_config = pcall(require, "octo.config")
if not octo_ok or not octo_config.values or octo_config.values.picker ~= "snacks" then
  fail("Octo did not load with the Snacks picker")
end

local github = require("nvim_config.features.github")
local repository_items = github._repository_items({
  {
    fullName = "neovim/neovim",
    description = "Vim-fork focused on extensibility and usability",
    stargazersCount = 100000,
    language = "Vim Script",
    visibility = "public",
  },
})
if #repository_items ~= 1 or repository_items[1].repo ~= "neovim/neovim" then
  fail("GitHub repository results were not converted for the Snacks picker")
end

local code_items = github._code_items({
  items = {
    {
      path = "runtime/plugin/man.lua",
      html_url = "https://github.com/neovim/neovim/blob/1234567890abcdef/runtime/plugin/man.lua",
      repository = { full_name = "neovim/neovim" },
      text_matches = { { fragment = "vim.api.nvim_create_user_command" } },
    },
  },
})
if #code_items ~= 1 or code_items[1].reference ~= "1234567890abcdef" then
  fail("GitHub code results were not converted for the Snacks picker")
end
if code_items[1].url ~= "https://github.com/neovim/neovim/blob/1234567890abcdef/runtime/plugin/man.lua" then
  fail("GitHub code results did not keep the result URL")
end

local collected_urls = github._item_urls({
  { url = "https://github.com/neovim/neovim" },
  { repo = "neovim/neovim" },
  { url = "https://github.com/folke/snacks.nvim" },
})
if #collected_urls ~= 2 or collected_urls[1] ~= "https://github.com/neovim/neovim" then
  fail("GitHub URL collection did not skip results without a URL")
end

local view_actions = github._view_actions()
local view_keys = github._view_keys()
for lhs, name in pairs({ ["<C-y>"] = "copy_url", ["<C-e>"] = "copy_reference", ["<C-b>"] = "open_in_browser" }) do
  if type(view_keys[lhs]) ~= "table" or view_keys[lhs][1] ~= name then
    fail("missing GitHub picker keymap: " .. lhs)
  end
  if type(view_actions[name]) ~= "table" or type(view_actions[name].action) ~= "function" then
    fail("missing GitHub picker action: " .. name)
  end
end

local single_picker = {
  selected = function()
    return {}
  end,
}
vim.fn.setreg('"', "")
view_actions.copy_url.action(single_picker, { url = "https://github.com/neovim/neovim" }, { reg = '"' })
if vim.fn.getreg('"') ~= "https://github.com/neovim/neovim" then
  fail("GitHub copy_url did not copy the result URL")
end

local multi_picker = {
  selected = function()
    return { { url = "https://github.com/a/b" }, { url = "https://github.com/c/d" } }
  end,
}
vim.fn.setreg('"', "")
view_actions.copy_url.action(multi_picker, nil, { reg = '"' })
local copied = vim.split(vim.fn.getreg('"'), "\n", { plain = true })
if copied[1] ~= "https://github.com/a/b" or copied[2] ~= "https://github.com/c/d" then
  fail("GitHub copy_url did not copy every selected result")
end

vim.fn.setreg('"', "")
view_actions.copy_reference.action(single_picker, { reference = "1234567890ab" }, { reg = '"' })
if vim.fn.getreg('"') ~= "1234567890ab" then
  fail("GitHub copy_reference did not copy the commit reference")
end

vim.fn.setreg('"', "")
view_actions.copy_url.action(single_picker, { repo = "neovim/neovim" }, { reg = '"' })
if vim.fn.getreg('"') ~= "" then
  fail("GitHub copy_url copied a result that has no URL")
end

local normal_buffer = vim.api.nvim_create_buf(true, false)
local octo_buffer = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(normal_buffer)
vim.api.nvim_set_current_buf(octo_buffer)
vim.bo[octo_buffer].buftype = "acwrite"
vim.bo[octo_buffer].filetype = "octo"
has_mapping("n", "q", true)
has_mapping("n", "<leader>q", true)
if not github.close_view() or vim.api.nvim_get_current_buf() ~= normal_buffer then
  fail("Octo safe close did not return to an editor buffer")
end
if vim.api.nvim_buf_is_valid(octo_buffer) then
  fail("Octo safe close did not delete the GitHub view buffer")
end

local windows = require("nvim_config.core.windows")
if not windows.is_editor_buffer() then
  fail("ordinary verification buffer was not recognized as an editor buffer")
end

local protected_buffer = vim.api.nvim_create_buf(false, true)
vim.bo[protected_buffer].buftype = "nofile"
vim.api.nvim_set_current_buf(protected_buffer)
if windows.is_editor_buffer() then
  fail("nofile buffer was incorrectly recognized as an editor buffer")
end
if windows.close() ~= false or vim.api.nvim_get_current_buf() ~= protected_buffer then
  fail("protected buffer was closed by the editor-only quit action")
end
vim.api.nvim_buf_delete(protected_buffer, { force = true })

for _, lhs in ipairs({ "<Tab>", "<S-Tab>" }) do
  has_mapping("v", lhs)
end
has_mapping("t", "<Esc><Esc>")

vim.api.nvim_set_current_buf(verification_buffer)
vim.wait(3000, function()
  return #vim.lsp.get_clients({ bufnr = verification_buffer }) > 0
end)
if #vim.lsp.get_clients({ bufnr = verification_buffer }) == 0 then
  fail("no LSP client attached to the verification buffer")
else
  has_mapping("n", "K", true)
  has_mapping("n", "<leader>ca", true)
  has_mapping("v", "<leader>ca", true)
  has_mapping("i", "<C-s>", true)
end

local original_buffer = vim.api.nvim_get_current_buf()

local python_buffer = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(python_buffer)
vim.bo[python_buffer].filetype = "python"
vim.wait(2000, function()
  return vim.fn.exists(":DebugPython") == 2
end)
has_command("DebugPython")
for _, lhs in ipairs({
  "<F5>",
  "<F6>",
  "<F9>",
  "<F10>",
  "<F11>",
  "<S-F11>",
  "<leader>du",
  "<leader>de",
  "<leader>db",
}) do
  has_mapping("n", lhs)
end
has_mapping("v", "<leader>de")
vim.api.nvim_set_current_buf(original_buffer)
vim.api.nvim_buf_delete(python_buffer, { force = true })

local quarto_buffer = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(quarto_buffer)
vim.bo[quarto_buffer].filetype = "quarto"
vim.wait(2000, function()
  return vim.fn.maparg("<leader>qp", "n", false, true).lhs ~= nil
end)
has_mapping("n", "<leader>qp", true)
has_mapping("n", "<leader>qc", true)
vim.api.nvim_set_current_buf(original_buffer)
vim.api.nvim_buf_delete(quarto_buffer, { force = true })

if #failures > 0 then
  error(table.concat(failures, "\n"))
end

print("Runtime command and keymap contracts passed")
