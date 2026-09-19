local M = {}

function M.hover()
  vim.lsp.buf.hover({
    border = "rounded",
    max_width = 100,
    max_height = 24,
    focusable = false,
  })
end

function M.signature_help()
  vim.lsp.buf.signature_help({
    border = "rounded",
    max_width = 100,
    max_height = 12,
    focusable = false,
  })
end

function M.show_availability()
  local servers = require("nvim_config.dependencies").lsp
  local lines = {}
  for name, command in pairs(servers) do
    local path = vim.fn.exepath(command)
    table.insert(lines, string.format("%-10s %s", name, path ~= "" and path or "missing"))
  end
  table.sort(lines)
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LSP availability" })
end

function M.setup()
  vim.api.nvim_create_user_command("LspAvailability", M.show_availability, {
    desc = "显示语言服务器可用状态",
  })

  if vim.fn.exists(":LspInfo") == 0 then
    vim.api.nvim_create_user_command("LspInfo", function()
      vim.cmd("checkhealth vim.lsp")
    end, { desc = "显示当前 Buffer 的 LSP 配置和客户端状态" })
  end
end

return M
