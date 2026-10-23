local function copy_pr_url()
    local utils = require("octo.utils")
    if vim.t.unified_review_pr then
        utils.copy_url(vim.t.unified_review_pr.url)
        return
    end
    local buffer = utils.get_current_buffer()
    if buffer and buffer:isPullRequest() then
        utils.copy_url(buffer.node.url)
        return
    end

    -- Review panes are not PR overview buffers. Use the reviewed PR explicitly,
    -- since it may belong to a different branch or repository than the checkout.
    local review = require("octo.reviews").get_current_review()
    local args = { "pr", "view" }
    if review then
        vim.list_extend(args, { tostring(review.pull_request.number), "--repo", review.pull_request.repo })
    end
    vim.list_extend(args, { "--json", "url", "--jq", ".url" })
    require("octo.gh").run({
        args = args,
        cb = function(stdout, stderr, status)
            if status ~= 0 then
                utils.error(vim.trim(stderr) ~= "" and vim.trim(stderr) or "No PR found for the current branch")
                return
            end
            local url = vim.trim(stdout)
            if not url:match("^https?://.+/pull/%d+$") then
                utils.error("GitHub did not return a PR URL")
                return
            end
            utils.copy_url(url)
        end,
    })
end

return {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    -- Requires the `gh` CLI, authenticated (`gh auth login`)
    opts = {
        enable_builtin = true,
        default_merge_method = "squash",
        commands = {
            pr = { url = copy_pr_url },
        },
    },
    keys = {
        { "<leader>gP", "<cmd>Octo pr list<CR>", desc = "List GitHub PRs" },
        {
            "<leader>gR",
            function()
                require("unified-review").open_octo()
            end,
            desc = "Interactive PR review (Octo)",
        },
    },
}
