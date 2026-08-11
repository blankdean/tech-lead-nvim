return {
    "nvim-telescope/telescope.nvim",
    -- master, not 0.1.x: the release branch predates the nvim-treesitter
    -- main-branch rewrite and crashes previewers (ft_to_lang removed)
    cmd = "Telescope",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-telescope/telescope-live-grep-args.nvim",
    },
    config = function()
        require("telescope").setup({
            defaults = {
                file_ignore_patterns = {
                    "node_modules", "%.git/",
                    "%.venv/", "__pycache__/", "%.mypy_cache/", "%.pytest_cache/", "%.ruff_cache/",
                },
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = { preview_width = 0.55 },
                },
                path_display = { "truncate" },
            },
            pickers = {
                find_files = {
                    hidden = true,
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
            },
        })

        require("telescope").load_extension("fzf")
        require("telescope").load_extension("live_grep_args")
    end,
}
