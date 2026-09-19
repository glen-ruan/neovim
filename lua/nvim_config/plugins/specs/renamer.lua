return {
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  keys = {
    { "<leader>rn", ":IncRename ", desc = "LSP：重命名符号" },
  },
  opts = {
    input_buffer_type = "snacks",
  },
}
