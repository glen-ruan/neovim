return {
    {
        "quarto-dev/quarto-nvim",
        ft = "quarto",
        dependencies = {
            { "jmbuhr/otter.nvim", opts = { buffers = { set_filetype = true } } },
            "nvim-treesitter/nvim-treesitter",
            "neovim/nvim-lspconfig",
        },
        init = function()
            vim.filetype.add({ extension = { qmd = "quarto" } })
            vim.treesitter.language.register("markdown", "quarto")
        end,
        opts = {
            lspFeatures = {
                enabled = true,
                chunks = "curly",
                languages = { "python", "lua", "c", "cpp", "r" },
                diagnostics = { enabled = true },
                completion = { enabled = true },
            },
            -- Preview uses the installed Quarto CLI. No external REPL is configured.
            codeRunner = { enabled = false },
        },
        config = function(_, opts)
            require("quarto").setup(opts)
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("UserQuarto", { clear = true }),
                pattern = "quarto",
                callback = function(args)
                    vim.keymap.set("n", "<leader>qp", "<cmd>QuartoPreview<CR>",
                        { buffer = args.buf, desc = "Quarto preview" })
                    vim.keymap.set("n", "<leader>qc", "<cmd>QuartoClosePreview<CR>",
                        { buffer = args.buf, desc = "Close Quarto preview" })
                end,
            })
        end,
    },
}
