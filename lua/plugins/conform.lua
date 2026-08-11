return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        { "<leader>uf", "<cmd>FormatToggle<CR>", desc = "Toggle format on save" },
        {
            "<leader>lf",
            function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
            mode = { "n", "v" },
            desc = "Format buffer",
        },
    },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                python = { "ruff_organize_imports", "ruff_format" },
                lua = { "stylua" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                json = { "prettier" },
                jsonc = { "prettier" },
                yaml = { "prettier" },
                html = { "prettier" },
                htmldjango = { "prettier" },
                css = { "prettier" },
                markdown = { "prettier" },
                sh = { "shfmt" },
                bash = { "shfmt" },
            },
            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                return { timeout_ms = 1000, lsp_format = "fallback" }
            end,
        })

        vim.api.nvim_create_user_command("FormatToggle", function(args)
            if args.bang then
                vim.b.disable_autoformat = not vim.b.disable_autoformat
            else
                vim.g.disable_autoformat = not vim.g.disable_autoformat
            end
        end, { bang = true, desc = "Toggle autoformat-on-save (! = buffer-local)" })
    end,
}
