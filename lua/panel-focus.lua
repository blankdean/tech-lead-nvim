local M = {}

local function window_kind(win)
    if
        not win
        or not vim.api.nvim_win_is_valid(win)
        or vim.api.nvim_win_get_tabpage(win) ~= vim.api.nvim_get_current_tabpage()
        or vim.api.nvim_win_get_config(win).relative ~= ""
    then
        return nil
    end

    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == "NvimTree" or ft == "octo_panel" or ft == "DiffviewFiles" then
        return "panel"
    end
    -- Octo and Diffview revision buffers are read-only, but still code windows.
    local name = vim.api.nvim_buf_get_name(buf)
    if
        vim.bo[buf].buftype == ""
        or name:match("^octo://.*/review/.*/file/")
        or (vim.bo[buf].buftype == "nowrite" and name:match("^diffview://"))
    then
        return "editor"
    end
end

local function remember_window()
    local win = vim.api.nvim_get_current_win()
    local kind = window_kind(win)
    if kind then
        vim.t["panel_focus_" .. kind] = win
    end
end

function M.toggle()
    local current = window_kind(vim.api.nvim_get_current_win())
    if not current then
        return
    end
    remember_window()
    local target_kind = current == "panel" and "editor" or "panel"
    local target = vim.t["panel_focus_" .. target_kind]
    if window_kind(target) ~= target_kind then
        target = nil
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if window_kind(win) == target_kind then
                target = win
                break
            end
        end
    end

    if target then
        vim.api.nvim_set_current_win(target)
    elseif target_kind == "panel" then
        -- Keep Space o's original behavior when no panel is open.
        vim.cmd.NvimTreeFocus()
    end
end

function M.setup()
    vim.api.nvim_create_autocmd("WinLeave", {
        group = vim.api.nvim_create_augroup("PanelFocus", { clear = true }),
        callback = remember_window,
    })
end

return M
