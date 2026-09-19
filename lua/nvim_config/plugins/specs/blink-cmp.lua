-- 光标是否位于 fenced code block（``` ... ```）内部：
-- .qmd 的正文保持安静，只有代码块里才自动弹补全。
local function in_code_fence()
  local ok, node = pcall(vim.treesitter.get_node)
  while ok and node do
    local kind = node:type()
    if kind == "fenced_code_block" or kind == "code_fence_content" or kind == "code_fence_span" then
      return true
    end
    node = node:parent()
  end
  return false
end

return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  -- optional: provides snippets for the snippet source
  dependencies = {
    "rafamadriz/friendly-snippets",
    "onsails/lspkind-nvim",
    "nvim-tree/nvim-web-devicons",
    "L3MON4D3/LuaSnip",
  },

  -- use a release tag to download pre-built binaries
  version = "1.*",
  opts = {
    -- markdown (.md) 里没有值得补全的正文内容，整体关闭：
    -- 关闭后 blink 的键位映射也不生效，<Tab> 回到普通的缩进行为。
    -- quarto (.qmd) 保持启用，以便代码块内的补全可用（弹窗策略见下面的 auto_show）。
    enabled = function()
      return vim.bo.filetype ~= "markdown"
    end,

    keymap = {
      preset = "none",

      ["<Tab>"] = {
        function(cmp)
          -- 1. 如果补全菜单可见，选择下一项（不自动插入）
          if cmp.is_visible() then
            return cmp.select_next()
          end

          -- 2. 如果处于 snippet 编辑状态，跳转到下一个占位符
          if cmp.snippet_active({ direction = 1 }) then
            return cmp.snippet_forward()
          end

          -- 3. 否则，交还给 fallback（比如插入 <Tab> 字符）
          return false -- 等价于触发 'fallback'
        end,
        "fallback", -- 安全兜底（虽然函数已处理，但保留更健壮）
      },

      -- 可选：Shift+Tab 处理上一个
      ["<S-Tab>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_prev()
          end
          if cmp.snippet_active({ direction = -1 }) then
            return cmp.snippet_backward()
          end
          return false
        end,
        "fallback",
      },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Esc>"] = { "hide", "fallback" },
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = {
      list = {
        selection = {
          preselect = false,
        },
      },
      menu = {
        -- .qmd 正文里不自动弹窗，只在围栏代码块内自动补全；
        -- 任何位置都可以用 <C-space> 手动触发。markdown 已整体关闭，这里也返回 false。
        auto_show = function()
          return vim.bo.filetype ~= "markdown" and (vim.bo.filetype ~= "quarto" or in_code_fence())
        end,
        scrollbar = false,
        border = "rounded",
        winhighlight = "Normal:BlinkCmpMenu,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",

        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                local icon = ctx.kind_icon
                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                  if dev_icon then
                    icon = dev_icon
                  end
                else
                  icon = require("lspkind").symbol_map[ctx.kind] or ""
                end

                return icon .. ctx.icon_gap
              end,

              -- Optionally, use the highlight groups from nvim-web-devicons
              -- You can also add the same function for `kind.highlight` if you want to
              -- keep the highlight groups in sync with the icons.
              highlight = function(ctx)
                local hl = ctx.kind_hl
                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                  if dev_icon then
                    hl = dev_hl
                  end
                end
                return hl
              end,
            },

            source_name = {
              text = function(ctx)
                return "[" .. ctx.source_name .. "]"
              end,
              highlight = "Comment",
              width = { fill = true },
            },
          },
          columns = {
            { "kind_icon", "kind", gap = 1 },
            { "label", "label_description", gap = 1 },
            { "source_name" },
          },
        },
      },
      documentation = {
        auto_show = false,
        window = {
          border = "rounded",
          scrollbar = false,
          winhighlight = "Normal:BlinkCmpDoc,FloatBorder:FloatBorder,EndOfBuffer:BlinkCmpDoc",
        },
      },
    },

    -- 使用 Neovim 原生 LSP 签名窗口，避免部分 clangd 返回值使 Blink
    -- 的活动参数高亮错误扩展到整个浮动窗口。
    signature = { enabled = false },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}

-- return {}
