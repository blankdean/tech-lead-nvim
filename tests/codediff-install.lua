-- nvim --clean --headless -i NONE -l tests/codediff-install.lua
local root = vim.fn.getcwd()
local plugin = vim.env.CODEDIFF_TEST_PLUGIN or vim.fn.stdpath("data") .. "/lazy/codediff.nvim"
vim.opt.rtp:prepend(root)
vim.opt.rtp:append(plugin)
local spec = dofile(root .. "/lua/plugins/codediff.lua")
local installer = require("codediff.core.installer.libvscode_diff")
local needs_update, install = installer.needs_update, installer.install
installer.needs_update = function() return true end
installer.install = function() return false, "simulated download failure" end
local notifications = {}
vim.notify = function(message) notifications[#notifications + 1] = message end
vim.api.nvim_create_user_command("CodeDiff", function() error("UI must not load after installation failure") end, { nargs = "*" })

spec.config(nil, spec.opts)
for _ = 1, 3 do vim.cmd("CodeDiff main...HEAD") end
assert(#notifications == 4, "Failed install should explain recovery on every invocation")
for _, message in ipairs(notifications) do
    assert(message:find("Lazy build codediff.nvim", 1, true), "Recovery must be actionable")
end
for _, name in ipairs({ "codediff.ui.view", "codediff.core.diff", "codediff.ui" }) do
    assert(package.loaded[name] == nil, "Failed installation must not poison " .. name)
end
local ok, err = pcall(spec.build, { dir = plugin })
assert(not ok and tostring(err):find("simulated download failure", 1, true), "Lazy build must report download failures")

installer.install = function(opts)
    assert(opts.force, "Explicit rebuilds must replace incomplete or broken binaries")
    return true
end
spec.build({ dir = plugin })
installer.needs_update, installer.install = needs_update, install
spec.config(nil, spec.opts)
assert(type(require("codediff.ui.view")) == "table", "A successful build should load the view normally")
print("CodeDiff install: failed downloads stay recoverable; successful build loads the real UI")
