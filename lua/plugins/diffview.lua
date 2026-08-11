return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    opts = {},
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff working tree" },
        { "<leader>gm", "<cmd>DiffviewOpen origin/main...HEAD<CR>", desc = "Diff branch vs main" },
        { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "File history (current file)" },
        { "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "Repo history" },
        { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Close diffview" },
    },
}
