return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    -- main now targets nvim 0.12 (nightly); this commit is verified working
    -- on 0.11.6, so hold it here — remove `pin` after upgrading Neovim
    pin = true,
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")

        ts.setup({})

        -- The main branch has no ensure_installed; install() is async and
        -- skips parsers that are already present.
        ts.install({
            "lua", "python", "javascript", "typescript",
            "json", "yaml", "toml", "markdown", "markdown_inline",
            "bash", "html", "htmldjango", "css", "dockerfile",
            "vim", "vimdoc", "regex", "sql",
        })

        -- Highlighting/indent are no longer enabled by setup(); each buffer
        -- opts in via vim.treesitter.start (fails harmlessly if no parser).
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("TreesitterSetup", {}),
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(args.match)
                if lang and pcall(vim.treesitter.start, args.buf, lang) then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
