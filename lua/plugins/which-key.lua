return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        local wk = require("which-key")
        wk.setup({
            delay = 300,
        })
        wk.add({
            { "<leader>f", group = "Find (Telescope)" },
            { "<leader>g", group = "Git" },
            { "<leader>b", group = "Buffer" },
            { "<leader>l", group = "LSP" },
            { "<leader>x", group = "Diagnostics (Trouble)" },
            { "<leader>h", group = "Harpoon" },
            { "<leader>u", group = "UI toggles" },
            { "<leader>t", group = "Terminal" },
        })
    end,
}
