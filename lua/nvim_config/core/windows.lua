local M = {}

function M.is_editor_buffer(bufnr)
  bufnr = bufnr or 0
  return vim.bo[bufnr].buftype == ""
end

function M.split(command)
  if not M.is_editor_buffer() then
    vim.notify("只能在普通编辑窗口中创建分屏", vim.log.levels.WARN, { title = "Window" })
    return false
  end

  vim.cmd(command)
  return true
end

return M
