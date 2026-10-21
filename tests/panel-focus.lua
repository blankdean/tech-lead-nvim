-- Run from the repo: nvim --clean --headless -i NONE -l tests/panel-focus.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
package.loaded.lazy = { setup = function() end }
dofile("init.lua")

local function focus(win)
    vim.api.nvim_set_current_win(win)
end

local function expect_focus(win, message)
    assert(vim.api.nvim_get_current_win() == win, message)
end

local function toggle()
    vim.api.nvim_feedkeys(" o", "xt", false)
end

local function split(command, filetype, name, buftype)
    vim.cmd(command)
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.bo[buf].filetype = filetype
    vim.bo[buf].buftype = buftype or "nofile"
    if name then
        vim.api.nvim_buf_set_name(buf, name)
    end
    return win
end

local editor = vim.api.nvim_get_current_win()
local tree = split("topleft vsplit", "NvimTree")
local pr_url_called = false
vim.api.nvim_create_user_command("Octo", function(args)
    pr_url_called = args.args == "pr url"
end, { nargs = "*" })
focus(tree)
vim.api.nvim_feedkeys(" gy", "xt", false)
assert(pr_url_called, "Space gy should invoke the PR URL command from NvimTree")
focus(editor)
for _ = 1, 4 do
    toggle()
    expect_focus(tree, "Space o should focus the file tree")
    toggle()
    expect_focus(editor, "Space o should return to the editor")
end
vim.api.nvim_win_close(tree, true)

-- Branch comparisons use read-only revision buffers on both sides.
vim.cmd("tabnew")
local branch_left = vim.api.nvim_get_current_win()
vim.api.nvim_buf_set_name(0, "diffview:///repo/.git/base/example.lua")
vim.bo.buftype = "nowrite"
local branch_right = split("rightbelow vsplit", "lua", "diffview:///repo/.git/head/example.lua", "nowrite")
local branch_panel = split("topleft vsplit", "DiffviewFiles")
for _, code in ipairs({ branch_left, branch_right }) do
    focus(code)
    for _ = 1, 3 do
        toggle()
        expect_focus(branch_panel, "Space o should focus the Diffview file panel")
        toggle()
        expect_focus(code, "Space o should return to the same branch diff window")
    end
end
vim.cmd("tabclose")
focus(editor)

-- Octo has two code windows and a bottom panel; the old-code buffer is nofile.
vim.api.nvim_buf_set_name(0, "octo://owner/repo/review/1/file/LEFT/example.lua")
vim.bo.buftype = "nofile"
local left = editor
local right = split("rightbelow vsplit", "lua", "octo://owner/repo/review/1/file/RIGHT/example.lua", "")
local panel = split("botright split", "octo_panel")
for _, code in ipairs({ right, left, right }) do
    focus(code)
    for _ = 1, 3 do
        toggle()
        expect_focus(panel, "Space o should focus the bottom review panel")
        toggle()
        expect_focus(code, "Space o should return to the same diff side")
    end
end

-- Both panels can be open: use whichever was last visited.
tree = split("topleft vsplit", "NvimTree")
toggle()
expect_focus(right, "A newly opened tree should return to the code window")
toggle()
expect_focus(tree, "The most recently visited panel should win")
focus(panel)
toggle()
expect_focus(right, "The review panel should remember the code window")
toggle()
expect_focus(panel, "Repeated presses should stay paired with the review panel")

-- Closing a remembered target must fall back to another visible target.
focus(tree)
toggle()
vim.api.nvim_win_close(tree, true)
toggle()
expect_focus(panel, "A closed tree should fall back to the visible review panel")
vim.api.nvim_win_close(right, true)
toggle()
expect_focus(left, "A closed code window should fall back to the old-code diff")

-- Tabs keep independent targets.
local review_tab = vim.api.nvim_get_current_tabpage()
vim.cmd("tabnew")
local other_editor = vim.api.nvim_get_current_win()
local other_tree = split("topleft vsplit", "NvimTree")
toggle()
expect_focus(other_editor, "Another tab should use its own editor")
toggle()
expect_focus(other_tree, "Another tab should use its own panel")
vim.api.nvim_set_current_tabpage(review_tab)
toggle()
expect_focus(panel, "Returning to the review tab should preserve its panel")
toggle()
expect_focus(left, "Returning to the review tab should preserve its editor")

-- A floating dialog should not become the editor or steal the remembered pair.
local floating = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
    relative = "editor",
    row = 1,
    col = 1,
    width = 20,
    height = 3,
})
toggle()
expect_focus(floating, "Space o should leave floating dialogs alone")
vim.api.nvim_win_close(floating, true)
focus(left)
toggle()
expect_focus(panel, "Floating dialogs should not overwrite focus targets")
toggle()
expect_focus(left, "The editor should remain the return target")

-- Preserve the old shortcut's open-and-focus behavior when no panel is visible.
vim.api.nvim_win_close(panel, true)
local opened = false
vim.api.nvim_create_user_command("NvimTreeFocus", function()
    opened = true
end, {})
toggle()
assert(opened, "With no panel open, Space o should still open the file tree")
print("Panel focus: all checks passed")
