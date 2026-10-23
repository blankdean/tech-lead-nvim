local M = {}
local pull_requests = {}

local function error_message(message)
    vim.notify(message, vim.log.levels.ERROR, { title = "PR review" })
end

function M.open_pr()
    -- Reading a PR should not load Octo or run its blocking `gh auth status`.
    -- Reuse Octo's selected PR only when its UI is already loaded.
    local utils = package.loaded["octo.utils"]
    local reviews = package.loaded["octo.reviews"]
    local buffer = utils and utils.get_current_buffer()
    local review = reviews and reviews.get_current_review()
    local context = vim.t.unified_review_pr
    local cwd = vim.fn.getcwd()
    local args = { "gh", "pr", "view" }
    if buffer and buffer:isPullRequest() then
        table.insert(args, buffer.node.url)
    elseif review then
        vim.list_extend(args, { tostring(review.pull_request.number), "--repo", review.pull_request.repo })
    elseif context then
        table.insert(args, context.url)
    end
    vim.list_extend(args, { "--json", "number,url,headRefOid" })
    vim.system(
        args,
        { cwd = cwd, text = true },
        vim.schedule_wrap(function(result)
            if result.code ~= 0 then
                error_message(
                    vim.trim(result.stderr or "") ~= "" and vim.trim(result.stderr)
                        or "No PR found for the current branch"
                )
                return
            end
            local ok, pr = pcall(vim.json.decode, result.stdout or "")
            if not ok or type(pr) ~= "table" or not tonumber(pr.number) or not pr.url or not pr.headRefOid then
                error_message("GitHub did not return PR details")
                return
            end
            local host, repo = pr.url:match("^https?://([^/]+)/([^/]+/[^/]+)/pull/%d+$")
            vim.system(
                { "git", "remote", "-v" },
                { cwd = cwd, text = true },
                vim.schedule_wrap(function(remotes)
                    if remotes.code ~= 0 then
                        error_message(vim.trim(remotes.stderr or "Could not read Git remotes"))
                        return
                    end
                    local remote
                    for line in (remotes.stdout or ""):gmatch("[^\n]+") do
                        local name, url = line:match("^(%S+)%s+(%S+)%s+%(fetch%)")
                        if name then
                            url = url:gsub("%.git/?$", ""):gsub("/$", "")
                            url = url:gsub("^[%w+.-]+://", ""):gsub("^[^@/]+@", "")
                            local remote_host, remote_repo = url:match("^([^/:]+)[:/](.+)$")
                            -- Preserve configured SSH aliases when Octo is in use.
                            local config = package.loaded["octo.config"]
                            local aliases = config and config.values.ssh_aliases or {}
                            remote_host = aliases[remote_host] or remote_host
                            if repo and remote_repo and remote_repo:lower() == repo:lower() and remote_host == host then
                                remote = name
                                if name == "origin" then
                                    break
                                end
                            end
                        end
                    end
                    if not remote then
                        error_message("No local Git remote matches the PR repository: " .. pr.url)
                        return
                    end
                    pull_requests[pr.headRefOid] = pr
                    vim.cmd(
                        "CodeDiff pr "
                            .. tonumber(pr.number)
                            .. " --remote "
                            .. vim.fn.fnameescape(remote)
                            .. " --repo "
                            .. vim.fn.fnameescape(cwd)
                    )
                end)
            )
        end)
    )
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
