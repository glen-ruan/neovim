local M = {}

function M.is_editor_buffer(bufnr)
  bufnr = bufnr or 0
  return vim.bo[bufnr].buftype == ""
end

function M.split(command)
  if not M.is_editor_buffer() then
    vim.notify("Splits can only be created from a regular editor buffer", vim.log.levels.WARN, { title = "Window" })
    return false
  end

  vim.cmd(command)
  return true
end

function M.close()
  if not M.is_editor_buffer() then
    vim.notify("This quit mapping is only available in regular editor buffers", vim.log.levels.WARN, { title = "Window" })
    return false
  end

  vim.cmd("quit")
  return true
end

return M
