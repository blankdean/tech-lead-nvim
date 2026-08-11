# ⚡ tech-lead-nvim

**A fast, complete Neovim setup for people who read more code than they write.**

Built for navigating large codebases, reviewing PRs without leaving the editor,
and making surgical edits at typing speed. ~100 ms startup. Works on any Mac or
Linux machine with one script.

![Neovim 0.11+](https://img.shields.io/badge/Neovim-0.11%2B-57A143?logo=neovim&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-blue)
![Lua](https://img.shields.io/badge/Lua-100%25-2C2D72?logo=lua)

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/blankdean/tech-lead-nvim/main/install.sh | bash
```

Or the cautious way (same result, and you can read it first):

```sh
git clone https://github.com/blankdean/tech-lead-nvim ~/.config/nvim
~/.config/nvim/install.sh
```

The script installs dependencies (ripgrep, node, a Nerd Font — even Neovim
itself if your distro's is too old), backs up any existing config, and
pre-installs every plugin. Then set your terminal font to **JetBrainsMono Nerd
Font** and run `nvim`. That's it.

## The greatest hits

Leader is `Space`. Press it and pause — which-key shows you everything.

| Key | Does |
|-----|------|
| `Space ff` / `Space fg` | Find file by name / grep entire repo |
| `Space a` → `Ctrl-1..4` | Pin file → jump to pin (harpoon) |
| `s` + two chars | Jump to any visible text (flash) |
| `gd` / `grr` / `Ctrl-o` | Definition / references / jump back |
| `grn` / `gra` | Rename symbol everywhere / code action |
| `Space gm` | Diff your branch against main |
| `Space gg` | Lazygit |
| `Ctrl-h/j/k/l` | Move between splits **and** tmux panes |
| `Space xx` | All diagnostics in one list |
| `Space e` | File tree |

Full reference: **[CHEATSHEET.md](CHEATSHEET.md)**

## Navigate like a tech lead

### Drop into unfamiliar code

Don't browse — search. `Space fg` and type an error message, a route path, a
distinctive string. You're in the right file in three seconds. Then `gd` to
chase definitions down, `Ctrl-o` to walk back up, `grr` to see every caller
before you touch a signature.

### Work several files at once

`Space |` and `Space -` split the window (same keys as tmux). `Ctrl-h/j/k/l`
moves between splits — and straight out into your tmux panes, one mental model.
Pin the 3–4 files you're living in with `Space a`, then `Ctrl-1..4` teleports
between them. Faster than any tab bar.

### Move fast inside a file

- `Ctrl-d` / `Ctrl-u` — half-page down/up, cursor stays centered
- `{` / `}` — jump by paragraph/block
- `s` + 2 chars — flash jump to anything you can see
- `12j` — relative line numbers are on: the number to jump is in the gutter
- `n`/`N` after a search stay centered too

### Marks: leave breadcrumbs

`ma` drops mark *a* on the current line, `` `a `` jumps back to it — perfect for
"I need to check something over there and come back." `` ` ` `` (backtick
backtick) bounces between your last two positions. Capital marks (`mA`) work
*across files*. For files you return to all day, harpoon pins beat marks.

### Surgical edits

Text objects are the whole game — `i` = inside, `a` = around:

| Type | Result |
|------|--------|
| `ci"` | Change inside the quotes |
| `ci(` `ci{` `ci[` | Change inside the brackets |
| `ciw` | Change the word under the cursor |
| `cit` | Change inside an HTML tag |
| `dap` | Delete the whole paragraph |
| `yi(` | Yank what's inside the parens |

Replace one word everywhere: `grn` (LSP rename — safe, project-wide).
Replace text everywhere: `*` to search the word, `ciw` new word `Esc`, then
`n` `.` `n` `.` — repeat-jump, repeat-edit, approving each change as you go.

Surround anything: `ysiw"` wraps the word in quotes, `cs"'` changes quotes to
single, `ds(` deletes the parens. Comment with `gcc`.

### Visual mode, three flavors

- `v` — character-wise: select, then `y` yank / `d` delete / `>` indent
- `V` — line-wise: grab whole lines, `J`/`K` moves them up and down
- `Ctrl-v` — block: column select, `I` to insert on every line at once
  (add a prefix to 20 lines in one motion)

Yanks go to the system clipboard automatically — copy in nvim, paste anywhere.

### Repeat yourself, mechanically

`.` repeats your last edit. For anything bigger: `qq` records a macro, `q`
stops, `@q` replays it, `20@q` replays it twenty times. Recorded a rename-and-
reformat on one line? Apply it to the whole file while you sip coffee.

### Templates and snippets

Type `def`, `for`, `if` in any language — snippet suggestions appear in the
completion menu (friendly-snippets ships hundreds, every major language).
`Enter` accepts, `Tab` hops between placeholder fields. Add your own in
`~/.config/nvim/snippets/`.

### Project-wide find & replace

1. `Space fg` — grep the thing
2. `Ctrl-q` — dump every match into the quickfix list
3. `:cdo s/old/new/gc | update` — apply across all files, confirming each

### Review PRs without leaving the editor

- `Space gm` — your branch vs main, side-by-side. Self-review before every push.
- `Space gf` — full history of the current file; answers "why is this like this?"
- `:Octo pr list` — browse PRs, check out, comment on lines, approve/request
  changes, all in-editor (needs `gh auth login`)
- `Space gp` / `Space gb` — preview hunk / blame line
- `Space gg` — lazygit for staging, committing, interactive rebase

## What's inside

[lazy.nvim](https://github.com/folke/lazy.nvim) ·
[telescope](https://github.com/nvim-telescope/telescope.nvim) + fzf-native ·
[harpoon2](https://github.com/ThePrimeagen/harpoon/tree/harpoon2) ·
[flash](https://github.com/folke/flash.nvim) ·
[blink.cmp](https://github.com/Saghen/blink.cmp) ·
[conform](https://github.com/stevearc/conform.nvim) ·
[gitsigns](https://github.com/lewis6991/gitsigns.nvim) ·
[diffview](https://github.com/sindrets/diffview.nvim) ·
[octo](https://github.com/pwntester/octo.nvim) ·
[trouble](https://github.com/folke/trouble.nvim) ·
[snacks](https://github.com/folke/snacks.nvim) ·
[which-key](https://github.com/folke/which-key.nvim) ·
[nvim-surround](https://github.com/kylechui/nvim-surround) ·
[vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) ·
[catppuccin](https://github.com/catppuccin/nvim)

**LSP** (auto-installed via mason): pyright + ruff, ts_ls, bashls, jsonls,
yamlls (with SchemaStore), dockerls, docker-compose, html, lua_ls.
**Formatting** on save: ruff, stylua, prettier, shfmt.

## tmux

Add [`tmux-navigator.snippet.conf`](tmux-navigator.snippet.conf) to your
`~/.tmux.conf` and `Ctrl-h/j/k/l` flows between nvim splits and tmux panes
seamlessly. Suggested layout: nvim in the main pane, a slim bottom pane for
server/tests — `Ctrl-j` to peek at logs, `Ctrl-k` back to code.

## Keeping everything up to date

| What | How | When |
|------|-----|------|
| Plugins | `:Lazy update` | Weekly-ish. Updates `lazy-lock.json` — commit it so other machines get the same versions |
| LSP servers & formatters | `:Mason`, then press `U` (update all) | When you notice a server lagging behind |
| Treesitter parsers | `:TSUpdate` | After plugin updates, and always after upgrading Neovim itself |
| Neovim | `brew upgrade neovim` (macOS) · re-run `install.sh` (Linux tarball installs) | When a new stable lands |
| This config | `cd ~/.config/nvim && git pull` | Whenever you've pushed changes from another machine |

If something breaks after an update: `:Lazy log` shows what changed, and
`git checkout lazy-lock.json && :Lazy restore` rolls every plugin back to the
last known-good commit. That's the whole point of committing the lock file.

## Troubleshooting

**Treesitter build fails with `ENOENT`** — no C compiler. Parsers compile
locally. macOS: `xcode-select --install`. Linux: `apt install gcc` (or dnf/pacman
equivalent). Then `:TSUpdate`.

**Mason can't install stylua / shfmt / servers** — three usual suspects:

1. Missing `unzip` or `tar` (mason unpacks release archives) — install them.
2. Missing `node`/`npm` (pyright, ts_ls, bashls, jsonls, yamlls are npm
   packages) — install node.
3. **Corporate proxy** blocking GitHub/npm downloads:
   ```sh
   export HTTPS_PROXY=http://proxy.yourcompany.com:PORT   # add to your shell rc
   git config --global http.proxy "$HTTPS_PROXY"
   npm config set proxy "$HTTPS_PROXY"
   ```

`:checkhealth mason` shows exactly what mason can and can't find.
Re-running `install.sh` prints a preflight report of every required tool.

**Diagnose anything**: `:checkhealth`, `:Lazy log`, `:messages`.

## Security posture

Built to be safe on a work machine:

- **Every plugin is a mainstream community standard** — 750 to 21k+ GitHub
  stars, most actively maintained (folke, telescope, treesitter core teams).
  No obscure or single-user dependencies.
- **Versions are pinned** — `lazy-lock.json` commits exact tested commits;
  a fresh install gets those, not whatever HEAD is that day.
- **No telemetry, no background network calls** — the update checker is
  disabled; nothing phones home. Network happens only when you run
  `:Lazy update` / `:Mason` yourself.
- **Binaries come from official sources only** — mason's registry pulls LSP
  servers and formatters from their official GitHub releases / npm packages.
  Same supply chain as `npm install` / `pip install`.
- Minimal plugin count: built-in features are preferred where they exist
  (native commenting, native LSP keymaps).

## Notes

- `lazy-lock.json` is committed — fresh installs get the exact tested plugin
  versions. `:Lazy update` when you want newer.
- Linux clipboard needs `xclip` (X11) or `wl-clipboard` (Wayland).
- `Ctrl-1..4` needs a modern terminal (Ghostty, kitty, WezTerm, iTerm2).
  Fallback: `Space hh` opens the harpoon menu.
- Broken icons? Your terminal font isn't the Nerd Font yet.
- `:checkhealth` diagnoses everything.

## License

[MIT](LICENSE)
