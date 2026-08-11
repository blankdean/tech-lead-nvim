return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        local map = vim.keymap.set
        map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: add file" })
        map("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: menu" })
        map("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Harpoon: prev file" })
        map("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Harpoon: next file" })
        for i = 1, 4 do
            -- <Space>1..4 works in EVERY terminal; Ctrl+digit only reaches
            -- nvim in kitty-protocol terminals (Ghostty/kitty/WezTerm) and
            -- dies silently in Terminal.app — keep it as a bonus binding
            map("n", "<leader>" .. i, function() harpoon:list():select(i) end, { desc = "Harpoon: file " .. i })
            map("n", "<C-" .. i .. ">", function() harpoon:list():select(i) end, { desc = "Harpoon: file " .. i })
        end
    end,
}
