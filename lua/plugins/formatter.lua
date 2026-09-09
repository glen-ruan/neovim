return {
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "格式化当前文件",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "jq" },
        jsonc = { "prettier" },
        sh = { "shfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        html = { "prettier" },
        css = { "prettier" },
        tex = { "tex-fmt" },
      },
      notify_on_error = true,
    },
  },
}
