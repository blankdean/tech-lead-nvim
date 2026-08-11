# Cheatsheet

Leader is `Space`. Press `Space` and wait — which-key pops up and shows everything.
This file covers the workflows, not every key.

**Mac**: `Ctrl` always means **Control (⌃)**, never Command (⌘). Command
belongs to your terminal app, not nvim.

## Moving between files (the core loop)

The fastest way to work in a big codebase is: **pin your hot files with Harpoon,
fuzzy-find everything else with Telescope.**

| Key | What it does |
|-----|--------------|
| `<Space>a` | Harpoon: pin the current file |
| `<Space>1` … `<Space>4` | Jump straight to pinned file 1–4 (`Ctrl-1..4` also works in Ghostty/kitty/WezTerm) |
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

**Live grep syntax** (`<Space>fg`):
- Case: lowercase query = case-insensitive; ANY capital letter = case-sensitive
  automatically (smart-case). So typing `GRPC` already matches only `GRPC`.
- Quote for exact phrases, add ripgrep flags after the quotes:

| Query | Finds |
|-------|-------|
| `handler` | `handler` anywhere, any case |
| `Handler` | case-sensitive (has a capital) |
| `"grpc" -s` | force case-sensitive even for lowercase |
| `"cache" -w` | whole word only — not `cached` or `precache` |
| `"def get" -t py` | phrase, Python files only |
| `"TODO" --iglob !tests/**` | exclude a directory |

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
| `Ctrl-d` / `Ctrl-u` | Half-page down / up, cursor auto-centered |
| `{` / `}` | Jump by paragraph / block |
| `12j` / `12k` | Jump N lines — read N off the relative line numbers |
| `%` | Jump between matching brackets |

## Folding — collapse functions/classes

Folds follow real code structure (treesitter), not indentation guesses.

| Key | What it does |
|-----|--------------|
| `zM` | Collapse everything — file becomes a table of contents of `def`s |
| `zR` | Expand everything back |
| `za` | Toggle the fold under the cursor |
| `zo` / `zc` | Open / close the fold under the cursor |
| `zj` / `zk` | Jump to next / previous fold |
| `:set foldlevel=1` | Keep top level (class) open, collapse its methods |

Skim-a-big-file recipe: `zM` to see just the function signatures, `zj` down the
list, `zo` open the one you care about.

## Splits & simultaneous editing

| Key | What it does |
|-----|--------------|
| `<Space>\|` | Vertical split (same key as tmux) |
| `<Space>-` | Horizontal split |
| `Ctrl-h/j/k/l` | Move between splits (and tmux panes) |
| `Ctrl-arrows` | Resize the current split |
| `:e file` | Open another file in this split |

Two files side by side: `<Space>|`, then `<Space>ff` in the new split.

## Marks — breadcrumbs

| Key | What it does |
|-----|--------------|
| `ma` | Drop mark `a` here (any letter) |
| `` `a `` | Jump back to mark `a` (exact position) |
| `'a` | Jump to mark `a`'s line (first character) |
| `mA` | Capital = global mark, works **across files** |
| `` ` ` `` | Bounce between your last two positions |
| `:marks` | List all marks |

Marks are for "check something over there, come right back." For files you
revisit all day, harpoon (`<Space>a`) is the better tool.

## Text objects — surgical edits

Pattern: `{operator}{i|a}{object}` — `i` = inside, `a` = around (includes delimiters).
Operators: `c` change, `d` delete, `y` yank, `v` select.

| Key | What it does |
|-----|--------------|
| `ci"` / `ci'` | Change inside quotes |
| `ci(` / `ci{` / `ci[` | Change inside brackets |
| `cit` | Change inside HTML/JSX tag |
| `ciw` | Change word under cursor |
| `caw` | Change word + surrounding space |
| `cip` / `dap` | Change / delete paragraph |
| `yi(` | Yank inside parens |
| `va{` | Select block including braces |

Replace a word everywhere, reviewed: `*` (search word) → `ciw` new word `Esc` →
`n` (next match) → `.` (repeat change) → keep going. For symbols, prefer
`grn` — LSP rename is scope-aware and project-wide in one shot.

Surround (nvim-surround): `ysiw"` wrap word in quotes · `ys$)` wrap to end of
line in parens · `cs"'` change `"` to `'` · `cst<div>` change tag · `ds(` delete
parens. Visual mode: select then `S"`.

## Visual mode & clipboard

| Key | What it does |
|-----|--------------|
| `v` | Character select |
| `V` | Line select |
| `Ctrl-v` | Block (column) select |
| `Ctrl-v` … `I` | Insert at start of every selected line (Esc to apply) |
| `Ctrl-v` … `$ A` | Append at end of every selected line |
| `J` / `K` (visual) | Move selection down / up |
| `gv` | Reselect last selection |
| `o` (in visual) | Jump to other end of selection |

Clipboard is system-wide (`unnamedplus`): `y` copies to your OS clipboard,
`p` pastes from it. `"0p` pastes the last *yank* even after a delete clobbered
the default register. `:reg` shows everything you've copied.

## Macros — record once, apply everywhere

| Key | What it does |
|-----|--------------|
| `.` | Repeat last edit (the most underrated key in vim) |
| `qq` | Start recording into register `q` |
| `q` | Stop recording |
| `@q` | Replay macro |
| `20@q` | Replay 20 times |
| `@@` | Replay the last-used macro |

Recipe: record one perfect line-transformation (`qq` … edits … `j0q` — end on
the next line so replays chain), then `20@q`.

## Snippets / templates

Type a prefix (`def`, `for`, `if`, `main`…) — snippets appear in the completion
menu with a snippet icon. `Enter` expands, `Tab` / `Shift-Tab` hop between
placeholders. friendly-snippets covers every major language. Custom ones:
VS Code-format JSON in `~/.config/nvim/snippets/`.

## Working a large codebase

1. **Orient**: `<Space>fg` a distinctive string (an error message, a route path).
   That lands you in the right file faster than browsing ever will.
2. **Trace**: `gd` into definitions, `Ctrl-o` to walk back out. `grr` to see
   every caller before you change a signature.
3. **Pin**: the 3–4 files you're actively editing go in Harpoon (`<Space>a`),
   then `<Space>1..4` bounces between them with zero friction.
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
