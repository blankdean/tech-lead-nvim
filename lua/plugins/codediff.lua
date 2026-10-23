return {
    "esmuellert/codediff.nvim",
    version = "v4.0.6",
    cmd = "CodeDiff",
    -- Install the native library during :Lazy sync/build, before UI modules load.
    build = function(plugin)
        vim.opt.rtp:append(plugin.dir)
        local ok, err = require("codediff.core.installer.libvscode_diff").install({ silent = true, force = true })
        if not ok then
            error(err)
        end
    end,
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
        -- A failed first-use download otherwise leaves a chain of failed Lua
        -- modules behind, causing misleading "loop or previous error" messages.
        local installer = require("codediff.core.installer.libvscode_diff")
        if installer.needs_update() then
            local ok, err = installer.install({ silent = false })
            if not ok then
                local message = "CodeDiff library installation failed: "
                    .. tostring(err)
                    .. "\nRun :Lazy build codediff.nvim with network access, then restart Neovim."
                vim.api.nvim_create_user_command("CodeDiff", function()
                    vim.notify(message, vim.log.levels.ERROR)
                end, { nargs = "*", bang = true, range = true, force = true })
                vim.notify(message, vim.log.levels.ERROR)
                return
            end
        end
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
