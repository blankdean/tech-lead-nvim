return {
    "esmuellert/codediff.nvim",
    version = "v4.0.6",
    cmd = "CodeDiff",
    opts = {
        diff = { layout = "inline" },
        explorer = {
            width = 30,
            view_mode = "tree",
            initial_focus = "modified",
            focus_on_select = true,
        },
        history = { position = "left", width = 35 },
        keymaps = {
            view = {
                toggle_layout = false,
                open_in_prev_tab = "gf",
            },
        },
    },
    config = function(_, opts)
        require("codediff").setup(opts)
        require("unified-review").setup()
    end,
    keys = {
        { "<leader>gd", "<cmd>CodeDiff<CR>", desc = "Diff working tree (inline)" },
        { "<leader>gm", "<cmd>CodeDiff origin/main...HEAD<CR>", desc = "Diff branch vs main (inline)" },
        { "<leader>gf", "<cmd>CodeDiff history %<CR>", desc = "File history (inline)" },
        { "<leader>gh", "<cmd>CodeDiff history<CR>", desc = "Repo history (inline)" },
        {
            "<leader>gr",
            function()
                require("unified-review").open_pr()
            end,
            desc = "Review PR diff (inline)",
        },
    },
}
