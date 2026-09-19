-- Detect whether the cursor is inside a fenced code block. Keep prose in .qmd
-- quiet while allowing automatic completion inside code fences.
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
    -- Disable completion for Markdown prose so Tab keeps its normal indentation
    -- behavior. Keep Quarto enabled for fenced code blocks.
    enabled = function()
      return vim.bo.filetype ~= "markdown"
    end,

    keymap = {
      preset = "none",

      ["<Tab>"] = {
        function(cmp)
        -- Select the next item when the completion menu is visible.
          if cmp.is_visible() then
            return cmp.select_next()
          end

        -- Otherwise jump to the next snippet placeholder when possible.
          if cmp.snippet_active({ direction = 1 }) then
            return cmp.snippet_forward()
          end

        -- Otherwise delegate to the normal Tab behavior.
        return false
        end,
      "fallback",
      },

    -- Previous item / snippet placeholder.
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
        -- Auto-show only inside Quarto code fences. Manual <C-space> remains
        -- available wherever completion is enabled.
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

      -- Use Neovim's native signature window. Some clangd responses can make
      -- Blink extend active-parameter highlighting across the entire float.
    signature = { enabled = false },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}

-- return {}
