return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
        {
            "s",
            mode = { "n", "x", "o" },
            function() require("flash").jump() end,
            desc = "Flash jump",
        },
        {
            "S",
            -- n/o only: visual S belongs to nvim-surround (surround selection)
            mode = { "n", "o" },
            function() require("flash").treesitter() end,
            desc = "Flash treesitter select",
        },
        {
            "r",
            mode = "o",
            function() require("flash").remote() end,
            desc = "Remote flash",
        },
    },
}
