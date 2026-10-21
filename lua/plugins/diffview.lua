return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    opts = function()
        local actions = require("diffview.actions")
        return {
            keymaps = {
                file_panel = {
                    { "n", "<cr>", actions.focus_entry, { desc = "Open and focus the selected diff" } },
                    {
                        "n",
                        "<2-LeftMouse>",
                        function()
                            local view = require("diffview.lib").get_current_view()
                            local item = view and view.panel:get_item_at_cursor()
                            if item and type(item.collapsed) == "boolean" then
                                actions.select_entry()
                            elseif item then
                                actions.goto_file_edit()
                            end
                        end,
                        { desc = "Open the local file in the editor" },
                    },
                },
            },
        }
    end,
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff working tree" },
        { "<leader>gm", "<cmd>DiffviewOpen origin/main...HEAD<CR>", desc = "Diff branch vs main" },
        { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "File history (current file)" },
        { "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "Repo history" },
    },
}
