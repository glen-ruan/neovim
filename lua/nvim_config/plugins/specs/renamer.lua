return {
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  keys = {
    { "<leader>rn", ":IncRename ", desc = "LSP: rename symbol" },
  },
  opts = {
    input_buffer_type = "snacks",
  },
}
