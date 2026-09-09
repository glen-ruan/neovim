local function close_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if vim.bo[bufnr].modified then
    vim.notify("文件尚未保存，请先保存或使用 :bd! 强制关闭", vim.log.levels.WARN)
    return
  end

  local listed = vim.tbl_filter(function(buf)
    return vim.bo[buf.bufnr].buflisted and vim.bo[buf.bufnr].buftype == ""
  end, vim.fn.getbufinfo({ buflisted = 1 }))

  if #listed <= 1 then
    vim.cmd("enew")
  end
  vim.api.nvim_buf_delete(bufnr, { force = false })
end

return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",

  init = function()
    vim.api.nvim_create_autocmd("BufReadPost", {
      group = vim.api.nvim_create_augroup("RemoveInitialEmptyBuffer", { clear = true }),
      callback = function(args)
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if bufnr ~= args.buf
            and vim.api.nvim_buf_is_loaded(bufnr)
            and vim.bo[bufnr].buflisted
            and vim.bo[bufnr].buftype == ""
            and vim.api.nvim_buf_get_name(bufnr) == ""
            and not vim.bo[bufnr].modified
            and vim.api.nvim_buf_line_count(bufnr) == 1
            and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == ""
          then
            vim.api.nvim_buf_delete(bufnr, { force = false })
          end
        end
      end,
    })
  end,

  opts = {
    options = {
      numbers = "ordinal",
      themable = true,
      close_command = close_buffer,
      right_mouse_command = close_buffer,
      left_mouse_command = "buffer %d",
      middle_mouse_command = nil,
      indicator_icon = "",
      buffer_close_icon = "✖",
      close_icon = "",
      modified_icon = "●",
      show_buffer_close_icons = false,
      show_close_icon = false,
      separator_style = "thin",
      always_show_bufferline = true,
      tab_size = 16,
      show_tab_indicators = false,
      diagnostics = "nvim_lsp",
      offsets = {
        {
          filetype = "neo-tree",
          text = "📂 Files",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
}
