# nvim config

Fast, batteries-included Neovim setup for Python / web / infra work.
~100 ms startup, everything lazy-loaded, servers and formatters auto-install.

- **Plugin manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) (auto-bootstraps on first launch)
- **LSP**: pyright + ruff, ts_ls, bashls, jsonls/yamlls (SchemaStore), dockerls, docker-compose, html, lua_ls — installed automatically via mason
- **Completion**: blink.cmp · **Formatting**: conform.nvim (ruff, stylua, prettier, shfmt) with format-on-save
- **Fuzzy finding**: telescope + fzf-native · **Pinned files**: harpoon2
- **Git**: gitsigns, diffview, octo (GitHub PRs in-editor), lazygit
- **tmux**: vim-tmux-navigator — `Ctrl-h/j/k/l` moves across nvim splits and tmux panes
- **Quality of life**: flash (2-key jumps), surround, trouble, todo-comments, which-key, snacks (dashboard, indent guides, floating terminal), catppuccin

See **[CHEATSHEET.md](CHEATSHEET.md)** for the actual workflows (navigation, fuzzy
finding, large-codebase editing, PR review, tmux).

## Install

Requires **Neovim ≥ 0.11**.

```sh
# 1. Dependencies (macOS)
brew install neovim ripgrep fd node gh lazygit
brew install --cask font-jetbrains-mono-nerd-font
xcode-select --install   # C compiler, for treesitter + fzf-native

# (Debian/Ubuntu: apt install ripgrep fd-find nodejs gh build-essential
#  and install a Nerd Font + recent neovim manually — apt's nvim is too old)

# 2. This config
git clone https://github.com/blankdean/nvim-config ~/.config/nvim

# 3. Launch — lazy.nvim bootstraps itself, installs all plugins,
#    mason pulls every LSP server and formatter. Wait for it to finish.
nvim
```

Then:

1. Set your terminal font to **JetBrainsMono Nerd Font** (icons are broken squares otherwise).
2. `gh auth login` — needed for GitHub PR review (`:Octo`).
3. `:checkhealth` — confirm everything is green.

### tmux integration

Add the snippet in [`tmux-navigator.snippet.conf`](tmux-navigator.snippet.conf) to
your `~/.tmux.conf` so `Ctrl-h/j/k/l` works from the tmux side too.

## Notes

- `lazy-lock.json` is committed — a fresh install gets the exact plugin
  versions this config was tested with. `:Lazy update` to move forward.
- First launch on a new machine needs network (plugins + mason downloads).
- On Linux, system clipboard needs `xclip` (X11) or `wl-clipboard` (Wayland).
- `Ctrl-1..4` (harpoon jumps) needs a terminal with the kitty keyboard
  protocol or CSI-u (Ghostty, kitty, WezTerm, iTerm2 with csi-u enabled).
  In a terminal without it, use `<Space>hh` and pick from the menu instead.
