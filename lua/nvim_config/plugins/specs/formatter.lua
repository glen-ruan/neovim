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
        json = { "prettier" },
        jsonc = { "prettier" },
        sh = { "shfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        html = { "prettier" },
        css = { "prettier" },
        tex = { "tex-fmt", "latexindent", stop_after_first = true },
      },
      notify_on_error = true,
      -- latexindent 默认把 indent.log 和备份文件写进当前工作目录，
      -- 这里显式指定 cruft 目录（-c），避免污染项目目录。
      formatters = {
        latexindent = {
          args = { "-c=" .. vim.fn.stdpath("state"), "-" },
        },
      },
    },
  },
}
