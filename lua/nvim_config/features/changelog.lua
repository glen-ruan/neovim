local M = {}

local win

local function path()
  return vim.fs.joinpath(vim.fn.stdpath("config"), "CHANGELOG.md")
end

local function close()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  win = nil
end

--- Open this repository's CHANGELOG.md in a read-only floating window.
--- Run the command again or press q / Esc to close it.
function M.open()
  if win and vim.api.nvim_win_is_valid(win) then
    close()
    return
  end

  local file = path()
  if vim.fn.filereadable(file) ~= 1 then
    vim.notify("File not found: " .. file, vim.log.levels.ERROR)
    return
  end

  local width = math.min(110, math.max(40, math.floor(vim.o.columns * 0.8)))
  local height = math.max(10, math.floor(vim.o.lines * 0.8))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(file))
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    title = " CHANGELOG ",
    title_pos = "center",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
  })

  vim.keymap.set("n", "q", close, { buffer = buf, desc = "Close CHANGELOG" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, desc = "Close CHANGELOG" })
end

--- Register the :ConfigChangelog command.
function M.setup()
  vim.api.nvim_create_user_command("ConfigChangelog", M.open, {
    desc = "View the configuration changelog in a floating window",
  })
end

return M
