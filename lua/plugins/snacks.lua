return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        quickfile = { enabled = true },
        indent = { enabled = true },
        notifier = { enabled = true, timeout = 3000 },
        terminal = { enabled = true },
        lazygit = { enabled = true },
        dashboard = {
            enabled = true,
            sections = {
                { section = "header" },
                { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 2 },
                { icon = " ", title = "Git Status", section = "terminal", enabled = function() return Snacks.git.get_root() ~= nil end, cmd = "git status --short --branch --renames", height = 5, padding = 2, ttl = 5 * 60, indent = 3 },
                { section = "startup" },
            },
        },
    },
    keys = {
        { "<leader>tt", function() Snacks.terminal.toggle() end, desc = "Toggle terminal" },
        -- Same toggle from inside the terminal too, where <leader> would just
        -- type a space into the shell. Most terminals send <C-_> for Ctrl-/.
        { "<c-/>", function() Snacks.terminal.toggle() end, mode = { "n", "t" }, desc = "Toggle terminal" },
        { "<c-_>", function() Snacks.terminal.toggle() end, mode = { "n", "t" }, desc = "which_key_ignore" },
        { "<leader>gg", function() Snacks.lazygit.open() end, desc = "Lazygit" },
        { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
    },
}
