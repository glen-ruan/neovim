return -- 使用 lazy.nvim 安装示例
{
  "stevearc/aerial.nvim",
  config = function()
    local aerial = require("aerial")
    local layout_before_aerial

    local function content_windows()
      local windows = {}
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local config = vim.api.nvim_win_get_config(win)
        local bufnr = vim.api.nvim_win_get_buf(win)
        if config.relative == "" and vim.bo[bufnr].filetype ~= "aerial" then
          windows[win] = true
        end
      end
      return windows
    end

    local function same_windows(expected)
      local current = content_windows()
      for win in pairs(expected) do
        if not current[win] then
          return false
        end
        current[win] = nil
      end
      return next(current) == nil
    end

    local function save_layout()
      if layout_before_aerial then
        return
      end
      layout_before_aerial = {
        restore = vim.fn.winrestcmd(),
        win = vim.api.nvim_get_current_win(),
        windows = content_windows(),
      }
    end

    local function restore_layout()
      local layout = layout_before_aerial
      layout_before_aerial = nil
      local topology_unchanged = layout and same_windows(layout.windows)
      aerial.close()
      if not topology_unchanged then
        return
      end
      vim.schedule(function()
        if layout.restore ~= "" then
          pcall(vim.cmd, layout.restore)
        end
        if vim.api.nvim_win_is_valid(layout.win) then
          vim.api.nvim_set_current_win(layout.win)
        end
      end)
    end

    local function aerial_is_visible()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "aerial" then
          return true
        end
      end
      return false
    end

    local function toggle_aerial()
      if aerial_is_visible() then
        restore_layout()
      else
        save_layout()
        aerial.open({ focus = true, direction = "right" })
      end
    end

    aerial.setup({
      backends = { "lsp", "treesitter" }, -- 优先 Treesitter，回退 LSP
      -- filter_kind = {
      --   "Class",
      --   "Constructor",
      --   "Enum",
      --   "Function",
      --   "Interface",
      --   "Module",
      --   "Method",
      --   "Struct",
      --   "Variable", -- 👈 添加变量
      --   "Constant", -- 👈 添加常量
      --   "Property", -- 👈 属性（如 JS/TS 中的 class 属性）
      --   "Field", -- 👈 字段（如 struct/class 成员）
      -- },

      filter_kind = false,

      keymaps = {
        q = { callback = restore_layout, desc = "关闭大纲并恢复布局" },
      },

      layout = {
        resize_to_content = false,
        min_width = 0.15,
        width = 0.15,
        placement = "edge",
        default_direction = "prefer_right",
      },
      show_guides = true, -- 👈 启用缩进引导线（分割线）
      guide_chars = "│ ─├─└", -- 默认值，可自定义
      autojump = true,
    })
    vim.keymap.set("n", "<leader>o", toggle_aerial, { desc = "右侧代码大纲" })
  end,
  -- 如果使用懒加载
  keys = { "<leader>o" },
}
