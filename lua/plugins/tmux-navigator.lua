return {
    "christoomey/vim-tmux-navigator",
    cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
    },
    keys = {
        { "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Navigate left (win/pane)" },
        { "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Navigate down (win/pane)" },
        { "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Navigate up (win/pane)" },
        { "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Navigate right (win/pane)" },
    },
}
