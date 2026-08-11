-- =============================================================
-- Dean's Neovim Config
-- =============================================================

-- Leader key (must be set before lazy.nvim loads plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable unused remote-plugin providers (only needed for legacy
-- python/ruby/perl/node remote plugins; silences :checkhealth warnings)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- =============================================================
-- Options
-- =============================================================
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.splitbelow = true
opt.splitright = true

opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.termguicolors = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.undofile = true
opt.swapfile = false

-- =============================================================
-- Key Mappings
-- =============================================================
local map = vim.keymap.set

-- Window navigation: <C-h/j/k/l> come from vim-tmux-navigator
-- (lua/plugins/tmux-navigator.lua) — seamless across nvim splits AND tmux panes

-- Resize windows
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer navigation
map("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Clear search highlights
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Stay in visual mode when indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- NvimTree
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>o", ":NvimTreeFocus<CR>", { desc = "Focus file explorer" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fc", "<cmd>Telescope grep_string<CR>", { desc = "Find word under cursor" })

-- Git (gitsigns)
map("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
map("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = "Blame line" })
map("n", "]h", ":Gitsigns next_hunk<CR>", { desc = "Next hunk" })
map("n", "[h", ":Gitsigns prev_hunk<CR>", { desc = "Previous hunk" })

-- =============================================================
-- Filetype detection
-- =============================================================
-- admin/ and dashboard/ templates are Jinja2, not plain HTML
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*/templates/*.html",
    group = vim.api.nvim_create_augroup("JinjaTemplates", { clear = true }),
    callback = function(args)
        vim.bo[args.buf].filetype = "htmldjango"
    end,
})

-- =============================================================
-- Bootstrap lazy.nvim
-- =============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins/
require("lazy").setup("plugins", {
    checker = { enabled = true, notify = false },
    change_detection = { notify = false },
    -- No installed plugin needs luarocks; disabling avoids the hererocks
    -- bootstrap and its :checkhealth errors
    rocks = { enabled = false },
})
