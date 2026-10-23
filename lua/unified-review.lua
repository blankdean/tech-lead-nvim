local M = {}
local pull_requests = {}

function M.open_pr()
    local utils = require("octo.utils")
    local buffer = utils.get_current_buffer()
    local review = require("octo.reviews").get_current_review()
    local context = vim.t.unified_review_pr
    local args = { "pr", "view" }
    if buffer and buffer:isPullRequest() then
        table.insert(args, buffer.node.url)
    elseif review then
        vim.list_extend(args, { tostring(review.pull_request.number), "--repo", review.pull_request.repo })
    elseif context then
        table.insert(args, context.url)
    end
    vim.list_extend(args, { "--json", "number,url,headRefOid" })
    require("octo.gh").run({
        args = args,
        cb = function(stdout, stderr, status)
            if status ~= 0 then
                utils.error(vim.trim(stderr) ~= "" and vim.trim(stderr) or "No PR found for the current branch")
                return
            end
            local ok, pr = pcall(vim.json.decode, stdout)
            if not ok or type(pr) ~= "table" or not tonumber(pr.number) or not pr.url or not pr.headRefOid then
                utils.error("GitHub did not return PR details")
                return
            end
            local host, repo = pr.url:match("^https?://([^/]+)/([^/]+/[^/]+)/pull/%d+$")
            local remote
            for name, info in pairs(utils.parse_git_remote()) do
                if repo and info.repo and info.repo:lower() == repo:lower() and info.host == host then
                    remote = name
                    if name == "origin" then
                        break
                    end
                end
            end
            if not remote then
                utils.error("No local Git remote matches the PR repository: " .. pr.url)
                return
            end
            pull_requests[pr.headRefOid] = pr
            vim.cmd("CodeDiff pr " .. tonumber(pr.number) .. " --remote " .. vim.fn.fnameescape(remote))
        end,
    })
end

function M.open_octo()
    local context = vim.t.unified_review_pr
    if not context then
        vim.cmd("Octo review")
        return
    end
    local host, repo = context.url:match("^https?://([^/]+)/([^/]+/[^/]+)/pull/%d+$")
    require("octo").load(repo, "pull", context.number, host, function(node)
        require("octo.model.pull-request").create_with_merge_base(
            {
                repo = repo,
                head_repo = node.headRepository.nameWithOwner,
                head_ref_name = node.headRefName,
                number = context.number,
                id = node.id,
            },
            node,
            function(pr)
                require("octo.reviews").Review:new(pr):start_or_resume()
            end
        )
    end)
end

function M.setup()
    vim.api.nvim_create_autocmd("User", {
        pattern = "CodeDiffOpen",
        group = vim.api.nvim_create_augroup("UnifiedReview", { clear = true }),
        callback = function(event)
            local tab = event.data.tabpage
            local lifecycle = require("codediff.ui.lifecycle")
            local session = lifecycle.get_session(tab)
            if not session then
                return
            end
            local pr = pull_requests[session.modified_revision]
            if pr then
                vim.api.nvim_tabpage_set_var(tab, "unified_review_pr", pr)
            end
            if not session.panel or session.panel.name ~= "explorer" then
                return
            end
            local panel = lifecycle.get_panel_view(tab)
            if not panel or not panel.bufnr then
                return
            end
            vim.keymap.set("n", "<2-LeftMouse>", function()
                local node = panel.tree:get_node()
                if not node or not node.data then
                    return
                end
                local key = (node.data.type == "group" or node.data.type == "directory") and "<CR>" or "gf"
                local mapping = vim.fn.maparg(key, "n", false, true)
                if mapping.callback then
                    mapping.callback()
                end
            end, { buffer = panel.bufnr, desc = "Open the local file in the editor" })
        end,
    })
end

return M
