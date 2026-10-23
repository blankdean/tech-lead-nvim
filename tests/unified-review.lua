-- nvim --clean --headless -i NONE -l tests/unified-review.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
for _, name in ipairs({ "octo", "octo.utils", "octo.reviews", "octo.gh" }) do
    package.preload[name] = function() error("PR reading must not load " .. name) end
end
local review = require("unified-review")
local requests, opened, errors = {}, {}, {}
vim.notify = function(message) errors[#errors + 1] = message end
vim.api.nvim_create_user_command("CodeDiff", function(opts) opened[#opened + 1] = opts.args end, { nargs = "*" })
local url = "https://github.com/owner/repo/pull/42"
local response = { code = 0, stdout = vim.json.encode({ number = 42, url = url, headRefOid = string.rep("a", 40) }) }
local remote_output = "upstream\thttps://github.com/owner/repo.git (fetch)\norigin\tgit@github.com:owner/repo.git (fetch)\n"
local queued = {}
vim.system = function(args, opts, callback)
    requests[#requests + 1] = { args = args, cwd = opts.cwd }
    assert(callback, "Git and GitHub commands must run asynchronously")
    if args[1] == "gh" then
        queued[#queued + 1] = function() callback(response) end
    else
        assert(vim.deep_equal(args, { "git", "remote", "-v" }), "Unexpected Git command")
        callback({ code = 0, stdout = remote_output })
    end
end
local function finish()
    table.remove(queued, 1)()
    assert(vim.wait(1000, function() return #requests % 2 == 0 or #errors > 0 end, 5))
    vim.wait(20, function() return false end, 5)
end

review.open_pr()
assert(#opened == 0 and #queued == 1, "Opening a PR must return while GitHub is pending")
assert(vim.deep_equal(requests[1].args, { "gh", "pr", "view", "--json", "number,url,headRefOid" }))
finish()
assert(opened[1]:find("pr 42 --remote origin", 1, true), "Use matching origin, not another remote")
assert(opened[1]:find("--repo " .. vim.fn.fnameescape(vim.fn.getcwd()), 1, true), "Keep the originating repository")
assert(not package.loaded["octo.utils"] and not package.loaded["octo.gh"], "Default PR reading must leave Octo unloaded")

vim.t.unified_review_pr = { url = url }
review.open_pr()
assert(requests[#requests].args[4] == url, "Viewed PR context must override the checkout branch")
finish()
package.loaded["octo.utils"] = {
    get_current_buffer = function() return { isPullRequest = function() return true end, node = { url = url .. "0" } } end,
}
review.open_pr()
assert(requests[#requests].args[4] == url .. "0", "Selected Octo PR must take precedence")
finish()
package.loaded["octo.utils"].get_current_buffer = function() return nil end
package.loaded["octo.reviews"] = {
    get_current_review = function() return { pull_request = { number = 99, repo = "another/project" } } end,
}
review.open_pr()
assert(vim.deep_equal(vim.list_slice(requests[#requests].args, 4, 6), { "99", "--repo", "another/project" }))
finish()

local count = #opened
remote_output = "origin\tgit@github.com:unrelated/repository.git (fetch)\n"
review.open_pr()
finish()
assert(#opened == count and errors[#errors]:find("No local Git remote", 1, true), "Never fetch a PR from the wrong repository")
response = { code = 1, stderr = "GitHub unavailable" }
review.open_pr()
finish()
assert(#opened == count and errors[#errors] == "GitHub unavailable", "Report failed lookups without opening a viewer")
print("Unified PR: asynchronous lookup, no Octo load, PR context, remotes, and errors passed")
