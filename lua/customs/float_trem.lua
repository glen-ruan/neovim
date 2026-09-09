-- 文件名: float_term.lua
-- 路径建议放在: ~/.config/nvim/lua/float_term.lua

local M = {}

M.term_buf = nil
M.term_win = nil
M.term_chan = nil

local float_width = 0.75
local float_height = 0.75

function M.close()
  if M.term_win and vim.api.nvim_win_is_valid(M.term_win) then
    vim.api.nvim_win_close(M.term_win, true)
  end
  M.term_win = nil
end

function M.toggle()
  if M.term_win and vim.api.nvim_win_is_valid(M.term_win) then
    M.close()
    return
  end
  return M.open()
end

-- 打开或复用浮窗终端
function M.open()
  if M.term_buf and vim.api.nvim_buf_is_valid(M.term_buf) then
    if M.term_win and vim.api.nvim_win_is_valid(M.term_win) then
      vim.api.nvim_set_current_win(M.term_win)
    else
      -- 重新创建窗口
      local width = math.floor(vim.o.columns * float_width)
      local height = math.floor(vim.o.lines * float_height)
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)
      M.term_win = vim.api.nvim_open_win(M.term_buf, true, {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "rounded",
      })
    end
    vim.cmd("startinsert")
    return M.term_chan
  end

  -- 创建新的 buffer
  M.term_buf = vim.api.nvim_create_buf(false, true)

  local width = math.floor(vim.o.columns * float_width)
  local height = math.floor(vim.o.lines * float_height)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  M.term_win = vim.api.nvim_open_win(M.term_buf, true, {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
  })

  -- Windows 优先使用 PowerShell，与 :! 命令保持一致。
  local shell = "zsh"
  if vim.fn.has("win32") == 1 then
    local candidates = { "pwsh", "powershell", vim.env.SHELL, "bash", "cmd" }
    shell = nil
    for _, c in ipairs(candidates) do
      if c and c ~= "" and vim.fn.executable(c) == 1 then
        shell = c
        break
      end
    end
    shell = shell or "cmd"
  end
  local args = { shell }
  if shell == "zsh" or shell == "bash" then
    table.insert(args, "-i")
  end
  M.term_chan = vim.fn.termopen(args, { detach = 0 })

  vim.cmd("startinsert")

  return M.term_chan
end

-- 发送命令到浮窗终端
function M.send(cmd)
  local chan = M.open()
  vim.fn.chansend(chan, cmd .. "\n")
end

-- 清空浮窗终端
function M.clear()
  if M.term_buf and vim.api.nvim_buf_is_valid(M.term_buf) then
    vim.api.nvim_buf_set_lines(M.term_buf, 0, -1, false, {})
  end
end

-- 返回模块表
return M
