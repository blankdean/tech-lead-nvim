# Cheatsheet

Leader is `Space`. Press `Space` and wait — which-key pops up and shows everything.
This file covers the workflows, not every key.

## Moving between files (the core loop)

The fastest way to work in a big codebase is: **pin your hot files with Harpoon,
fuzzy-find everything else with Telescope.**

| Key | What it does |
|-----|--------------|
| `<Space>a` | Harpoon: pin the current file |
| `Ctrl-1` … `Ctrl-4` | Jump straight to pinned file 1–4 |
| `<Space>hh` | Harpoon menu (reorder / remove pins) |
| `<Space>ff` | Find file by name (fuzzy) |
| `<Space>fg` | Live grep — search file *contents* across the repo |
| `<Space>fc` | Grep the word under the cursor |
| `<Space>fb` | Switch between open buffers |
| `<Space>fr` | Recently opened files |
| `Shift-h` / `Shift-l` | Previous / next buffer |
| `Ctrl-o` / `Ctrl-i` | Jump back / forward through your jump history |
| `<Space>e` | File tree (for browsing structure; use `ff` for opening files) |

**Telescope tricks** (inside any picker):
- Type multiple words to narrow: `user auth` matches paths containing both.
- `Ctrl-q` sends all results to the quickfix list — then `:cdo s/old/new/g | update`
  does a project-wide edit.
- In live grep, ripgrep syntax works: `foo -- -g '*.py'` limits to Python files.

## Navigating inside a file

| Key | What it does |
|-----|--------------|
| `s` + 2 chars | Flash: jump to any visible text (type the label that appears) |
| `S` | Flash treesitter: select expanding syntax nodes |
| `gd` | Go to definition |
| `grr` | List all references (built-in nvim 0.11) |
| `K` | Hover docs |
| `]d` / `[d` | Next / previous diagnostic |
| `]h` / `[h` | Next / previous git hunk |
| `]t` / `[t` | Next / previous TODO comment |
| `Ctrl-d` / `Ctrl-u` | Half-page down / up (keeps cursor centered enough with scrolloff) |
| `%` | Jump between matching brackets |

## Working a large codebase

1. **Orient**: `<Space>fg` a distinctive string (an error message, a route path).
   That lands you in the right file faster than browsing ever will.
2. **Trace**: `gd` into definitions, `Ctrl-o` to walk back out. `grr` to see
   every caller before you change a signature.
3. **Pin**: the 3–4 files you're actively editing go in Harpoon (`<Space>a`),
   then `Ctrl-1..4` bounces between them with zero friction.
4. **Audit**: `<Space>xx` opens Trouble — every diagnostic in the workspace in
   one list. `<Space>ft` lists every TODO/FIXME.
5. **Bulk edit**: Telescope grep → `Ctrl-q` to quickfix → `:cdo s/old/new/gc | update`.

## Editing

| Key | What it does |
|-----|--------------|
| `grn` | Rename symbol project-wide (LSP) |
| `gra` | Code action (auto-import, fix, refactor) |
| `<Space>lf` | Format file (ruff / stylua / prettier — also runs on save) |
| `<Space>uf` | Toggle format-on-save |
| `gcc` / `gc` (visual) | Comment line / selection |
| `ysiw"` | Surround word with quotes (`cs"'` change, `ds"` delete) |
| `J` / `K` (visual) | Move selected lines down / up |
| `<` / `>` (visual) | Dedent / indent, stays selected |
| `Ctrl-n` / `Ctrl-p` | Next / previous completion; `Enter` accepts; `Ctrl-e` dismisses |

## Git: diffs, history, PRs

| Key | What it does |
|-----|--------------|
| `<Space>gd` | Diffview: every uncommitted change, side by side |
| `<Space>gm` | Diff your branch against `origin/main` — **self-review before pushing** |
| `<Space>gf` | Full history of the current file (each commit's diff) |
| `<Space>gh` | Browsable repo history |
| `<Space>gq` | Close diffview |
| `<Space>gp` | Preview the git hunk under the cursor |
| `<Space>gb` | Blame the current line |
| `<Space>gg` | Lazygit (stage, commit, push, rebase — full TUI) |

**Reviewing GitHub PRs** (octo.nvim, needs `gh auth login`):

```
:Octo pr list          " browse open PRs (or <Space>gP)
:Octo pr checkout 42   " check the PR out locally
<Space>gr              " start a review — files open as diffs
```

In a review: leave comments on lines with `ca` (comment add), navigate files in the
review panel, then `:Octo review submit` (approve / comment / request changes).
`:Octo pr create` opens a new PR without leaving nvim. For a quick look at a PR's
diff without a full review: `:Octo pr checkout 42` then `<Space>gm`.

## Terminal & tmux

| Key | What it does |
|-----|--------------|
| `Ctrl-h/j/k/l` | Move between nvim splits **and** tmux panes — one keybinding, no mental switch |
| `<Space>tt` | Floating terminal inside nvim (quick one-off commands) |
| `Ctrl-a \|` / `Ctrl-a -` | tmux: split vertical / horizontal |
| `Ctrl-a z` | tmux: zoom pane fullscreen (again to restore) |
| `Ctrl-a Tab` | tmux: toggle between last two panes |
| `Shift-←/→` | tmux: previous / next window |

**Suggested layout**: one tmux window per project; nvim in the main pane, a
slim bottom pane for the dev server / logs / tests. `Ctrl-j` down to check logs,
`Ctrl-k` back into the editor. Zoom (`Ctrl-a z`) when you want nvim fullscreen.

## Housekeeping

- `:Lazy` — plugin manager (update / profile startup)
- `:Mason` — LSP server / formatter installer
- `:checkhealth` — diagnose anything that feels broken
- `:ConformInfo` — see which formatter ran on this buffer
