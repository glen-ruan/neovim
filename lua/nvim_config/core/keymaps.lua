local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key.
vim.g.mapleader = " "

-- Next / previous buffer tab.
map("n", "<leader><PageDown>", ":BufferLineCycleNext<CR>", opts)
map("n", "<leader><PageUp>", ":BufferLineCyclePrev<CR>", opts)

-- Jump directly to buffer tabs 1-9.
for i = 1, 9 do
  map("n", "<leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", opts)
end

-- Window operations.
local windows = require("nvim_config.core.windows")
map("n", "<leader><Left>", "<C-w>h", opts)
map("n", "<leader><Down>", "<C-w>j", opts)
map("n", "<leader><Up>", "<C-w>k", opts)
map("n", "<leader><Right>", "<C-w>l", opts)
map("n", "<leader>sv", function()
  windows.split("vsplit")
end, { desc = "Split vertically (editor buffers only)" })
map("n", "<leader>sh", function()
  windows.split("split")
end, { desc = "Split horizontally (editor buffers only)" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize window sizes" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- File operations.
map("n", "<leader>w", ":w<CR>", opts)
map("n", "<leader>q", windows.close, { desc = "Quit current window (editor buffers only)" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close current file" })

-- Press Esc twice to leave terminal mode. A single Esc remains available to terminal programs.
map("t", "<Esc><Esc>", [[<C-\><C-n>]], opts)

-- Selection mappings use a leader prefix to preserve native v-prefixed motions.
map("n", "<leader>vv", "v%", { desc = "Select through matching bracket" })
map("n", "<leader>vc", "viw", { desc = "Select current word" })
map("n", "<leader>vl", "V", { desc = "Select current line" })

-- Clear search highlights.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- Floating terminal.
local float_term = require("nvim_config.features.terminal")
map("n", "<leader>ft", float_term.toggle, { desc = "Toggle floating terminal" })

-- Diagnostics.
map("n", "<leader>xx", ":Trouble diagnostics toggle<CR>", opts)

map("v", "<Tab>", ">gv", opts)
map("v", "<S-Tab>", "<gv", opts)

map("n", "<leader>e", ":Neotree toggle<CR>", opts)

-- Toggle the buffer tab line.
vim.keymap.set("n", "<leader>tb", function()
  if vim.o.showtabline == 0 then
    vim.o.showtabline = 2
  else
    vim.o.showtabline = 0
  end
end, { desc = "Toggle Bufferline" })
