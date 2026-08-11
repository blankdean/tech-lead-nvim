return {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
        -- <CR> accepts, <C-n>/<C-p> or arrows select, <C-e> dismisses
        keymap = { preset = "enter" },
        completion = {
            documentation = { auto_show = true },
        },
        -- Uses the prebuilt Rust matcher when available, pure-Lua otherwise
        fuzzy = { implementation = "prefer_rust_with_warning" },
    },
}
