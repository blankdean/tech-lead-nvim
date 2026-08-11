return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            integrations = {
                gitsigns = true,
                nvimtree = true,
                telescope = { enabled = true },
                treesitter = true,
                which_key = true,
                flash = true,
                mason = true,
                harpoon = true,
                lsp_trouble = true,
                nvim_surround = true,
                snacks = true,
            },
        })
        vim.cmd.colorscheme("catppuccin")
    end,
}
