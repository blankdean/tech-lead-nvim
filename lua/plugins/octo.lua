return {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    -- Requires the `gh` CLI, authenticated (`gh auth login`)
    opts = {
        enable_builtin = true,
        default_merge_method = "squash",
    },
    keys = {
        { "<leader>gP", "<cmd>Octo pr list<CR>", desc = "List GitHub PRs" },
        { "<leader>gr", "<cmd>Octo review<CR>", desc = "Review current PR" },
    },
}
