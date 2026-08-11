return {
    {
        "mason-org/mason.nvim",
        opts = {},
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            -- Formatters conform.nvim shells out to (not LSP servers, so
            -- mason-lspconfig below won't install them)
            ensure_installed = { "stylua", "prettier", "shfmt" },
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "b0o/schemastore.nvim",
        },
        config = function()
            -- mason-lspconfig installs these and auto-enables them via vim.lsp.enable
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls", "pyright", "ruff", "ts_ls",
                    "bashls", "jsonls", "yamlls",
                    "dockerls", "docker_compose_language_service",
                    "html",
                },
            })

            -- Teach lua_ls about the Neovim runtime so editing this config
            -- doesn't flag `vim` as undefined
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                    },
                },
            })

            -- ruff handles lint/quickfix/import-sort; pyright stays the one
            -- source of hover/type info so they don't fight over it
            vim.lsp.config("ruff", {
                on_attach = function(client)
                    client.server_capabilities.hoverProvider = false
                end,
            })

            -- Jinja2 templates get filetype "htmldjango" (see init.lua) —
            -- teach the html server to still attach there
            vim.lsp.config("html", {
                filetypes = { "html", "htmldjango" },
            })

            vim.lsp.config("jsonls", {
                settings = {
                    json = {
                        schemas = require("schemastore").json.schemas(),
                        validate = { enable = true },
                    },
                },
            })

            vim.lsp.config("yamlls", {
                settings = {
                    yaml = {
                        schemaStore = { enable = false, url = "" },
                        schemas = require("schemastore").yaml.schemas(),
                    },
                },
            })

            vim.diagnostic.config({
                virtual_text = true,
                severity_sort = true,
                float = { border = "rounded" },
            })

            -- Buffer-local maps on attach (nvim 0.11 also ships defaults:
            -- grn rename, gra code action, grr references, K hover)
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("LspKeymaps", {}),
                callback = function(args)
                    local function bmap(lhs, rhs, desc)
                        vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
                    end
                    bmap("gd", vim.lsp.buf.definition, "Go to definition")
                    bmap("gD", vim.lsp.buf.declaration, "Go to declaration")
                    bmap("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
                    bmap("<leader>la", vim.lsp.buf.code_action, "Code action")
                    bmap("<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
                end,
            })
        end,
    },
}
