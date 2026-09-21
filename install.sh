#!/usr/bin/env bash
# tech-lead-nvim installer — macOS + Linux (apt / dnf / pacman)
# Safe to re-run. Backs up any existing config before touching it.
set -euo pipefail

REPO="https://github.com/blankdean/tech-lead-nvim"
CONFIG_DIR="${HOME}/.config/nvim"
NVIM_MIN_MINOR=12 # nvim-treesitter main requires neovim >= 0.12

# Native binaries we drop in here must win over Intel Homebrew / distro copies.
export PATH="${HOME}/.local/bin:${PATH}"

bold() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[33mwarn:\033[0m %s\n' "$*"; }

# --- helpers ---------------------------------------------------------------

nvim_ok() {
    command -v nvim >/dev/null 2>&1 || return 1
    local v minor
    v="$(nvim --version 2>/dev/null | head -1 | sed 's/^NVIM v//')"
    [ -n "$v" ] || return 1
    minor="$(echo "$v" | cut -d. -f2)"
    [ "$(echo "$v" | cut -d. -f1)" -gt 0 ] || [ "$minor" -ge "$NVIM_MIN_MINOR" ]
}

# Intel Homebrew on Apple Silicon (or an x86 nvim under Rosetta) still reports
# a fine version. Parsers and fzf-native then compile for the wrong CPU.
nvim_arch_ok() {
    command -v nvim >/dev/null 2>&1 || return 1
    local bin info machine
    bin="$(command -v nvim)"
    info="$(file -b "$bin" 2>/dev/null || true)"
    machine="$(uname -m)"
    case "$machine" in
    arm64 | aarch64) echo "$info" | grep -qiE 'arm64|aarch64' ;;
    x86_64) echo "$info" | grep -qiE 'x86-64|x86_64' ;;
    *) return 0 ;;
    esac
}

install_nvim_tarball() {
    # Official release tarball into ~/.local — no sudo, native arch
    local tar dest
    case "$(uname -s)-$(uname -m)" in
    Darwin-arm64) tar="nvim-macos-arm64.tar.gz" dest="nvim-macos-arm64" ;;
    Darwin-x86_64) tar="nvim-macos-x86_64.tar.gz" dest="nvim-macos-x86_64" ;;
    Linux-x86_64) tar="nvim-linux-x86_64.tar.gz" dest="nvim-linux-x86_64" ;;
    Linux-aarch64 | Linux-arm64) tar="nvim-linux-arm64.tar.gz" dest="nvim-linux-arm64" ;;
    *)
        warn "unknown platform $(uname -s)/$(uname -m) — install neovim >= 0.${NVIM_MIN_MINOR} manually"
        return 1
        ;;
    esac
    bold "Installing Neovim (official tarball) to ~/.local/opt/${dest}"
    mkdir -p "${HOME}/.local/opt" "${HOME}/.local/bin"
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/${tar}" \
        -o "/tmp/${tar}"
    if [ "$(uname -s)" = Darwin ]; then
        xattr -c "/tmp/${tar}" 2>/dev/null || true
    fi
    rm -rf "${HOME}/.local/opt/${dest}"
    tar -xzf "/tmp/${tar}" -C "${HOME}/.local/opt"
    ln -sfn "${HOME}/.local/opt/${dest}/bin/nvim" "${HOME}/.local/bin/nvim"
    rm -f "/tmp/${tar}"
    hash -r 2>/dev/null || true
}

# nvim-treesitter (main) shells out to the native tree-sitter CLI. The npm
# package of the same name is a Node wrapper and builds the wrong arch.
tree_sitter_ok() {
    command -v tree-sitter >/dev/null 2>&1 || return 1
    local bin
    bin="$(command -v tree-sitter)"
    if head -n1 "$bin" 2>/dev/null | grep -qi node; then
        return 1
    fi
    tree-sitter --version >/dev/null 2>&1
}

install_tree_sitter_cli() {
    tree_sitter_ok && return 0
    local arch os asset
    case "$(uname -m)" in
    x86_64) arch="x64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)
        warn "unknown arch — install the native tree-sitter CLI (https://github.com/tree-sitter/tree-sitter/releases)"
        return 1
        ;;
    esac
    case "$(uname -s)" in
    Darwin) os="macos" ;;
    Linux) os="linux" ;;
    esac
    asset="tree-sitter-${os}-${arch}.gz"
    bold "Installing native tree-sitter CLI to ~/.local/bin"
    mkdir -p "${HOME}/.local/bin"
    curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/${asset}" |
        gunzip >"${HOME}/.local/bin/tree-sitter"
    chmod +x "${HOME}/.local/bin/tree-sitter"
    hash -r 2>/dev/null || true
}

install_nerd_font_linux() {
    if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then return 0; fi
    bold "Installing JetBrainsMono Nerd Font to ~/.local/share/fonts"
    mkdir -p "${HOME}/.local/share/fonts"
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" \
        -o /tmp/JetBrainsMono.tar.xz
    tar -xJf /tmp/JetBrainsMono.tar.xz -C "${HOME}/.local/share/fonts"
    rm -f /tmp/JetBrainsMono.tar.xz
    fc-cache -f >/dev/null 2>&1 || true
}

# Debian/Ubuntu ship the binary as fdfind; telescope looks for `fd`.
ensure_fd() {
    command -v fd >/dev/null 2>&1 && return 0
    if command -v fdfind >/dev/null 2>&1; then
        mkdir -p "${HOME}/.local/bin"
        ln -sfn "$(command -v fdfind)" "${HOME}/.local/bin/fd"
        hash -r 2>/dev/null || true
    fi
}

ensure_native_nvim() {
    if nvim_ok && nvim_arch_ok; then
        return 0
    fi
    install_nvim_tarball
}

# --- dependencies ----------------------------------------------------------

case "$(uname -s)" in
Darwin)
    command -v brew >/dev/null 2>&1 || {
        echo "Homebrew required on macOS: https://brew.sh"
        exit 1
    }
    xcode-select -p >/dev/null 2>&1 || {
        bold "Xcode Command Line Tools required (C compiler for treesitter)"
        xcode-select --install
        echo "Finish the CLT install dialog, then re-run this script."
        exit 1
    }
    bold "Installing dependencies (brew)"
    for pkg in neovim tree-sitter ripgrep fd node gh lazygit; do
        brew list "$pkg" >/dev/null 2>&1 || brew install "$pkg" || warn "$pkg failed — install manually"
    done
    brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1 ||
        brew install --cask font-jetbrains-mono-nerd-font || warn "font install failed"
    install_tree_sitter_cli
    ensure_native_nvim
    ;;
Linux)
    bold "Installing dependencies"
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -qq
        sudo apt-get install -y -qq git curl ripgrep fd-find nodejs npm gcc make unzip fontconfig xz-utils xclip wl-clipboard xdg-utils || true
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y -q git curl ripgrep fd-find nodejs gcc make unzip fontconfig xz xclip wl-clipboard xdg-utils || true
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm git curl ripgrep fd nodejs npm gcc make unzip fontconfig xz xclip wl-clipboard xdg-utils || true
    else
        warn "unknown package manager — ensure git, curl, ripgrep, node, gcc, xclip or wl-clipboard are installed"
    fi
    ensure_fd
    nvim_ok && nvim_arch_ok || install_nvim_tarball
    install_tree_sitter_cli
    install_nerd_font_linux
    command -v gh >/dev/null 2>&1 || warn "gh CLI not installed — needed only for :Octo PR review (https://cli.github.com)"
    command -v lazygit >/dev/null 2>&1 || warn "lazygit not installed — optional (https://github.com/jesseduffield/lazygit)"
    ;;
*)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

nvim_ok || {
    echo "neovim >= 0.${NVIM_MIN_MINOR} required — install it and re-run"
    exit 1
}
nvim_arch_ok || warn "nvim is not native $(uname -m) — parsers may fail to load. Re-run after installing a native build."

# --- preflight doctor -------------------------------------------------------
# Everything nvim needs at runtime: cc compiles treesitter parsers, node runs
# several LSP servers, curl+tar+gzip+unzip let mason download tool binaries.

bold "Preflight check"
missing=0
for tool in git curl tar gzip unzip cc make node npm rg fd; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf '  ok       %s\n' "$tool"
    else
        printf '  MISSING  %s\n' "$tool"
        missing=1
    fi
done
if tree_sitter_ok; then
    printf '  ok       tree-sitter (native CLI)\n'
else
    printf '  MISSING  tree-sitter native CLI (npm wrapper is not enough)\n'
    missing=1
fi
if [ "$missing" -eq 1 ]; then
    cat <<'EOF'

Missing tools above will cause exactly these failures later:
  - no cc / make     -> treesitter parsers and telescope-fzf-native fail to build
  - no tree-sitter   -> parser generation ENOENT (needs the native CLI, not npm)
  - no node/npm      -> pyright, ts_ls, bashls, jsonls, yamlls won't install
  - no unzip/tar     -> mason can't unpack stylua, shfmt, and other binaries
  - no fd            -> telescope find_files falls back to slow `find`
                        (Debian/Ubuntu: apt install fd-find)
Install them (apt/dnf/pacman/brew) and re-run.
EOF
    exit 1
fi

if ! curl -fsSL -m 10 https://api.github.com/zen >/dev/null 2>&1; then
    warn "cannot reach github.com — corporate proxy? Set proxy env vars first:"
    warn '  export HTTPS_PROXY=http://proxy.yourcompany.com:PORT'
    warn '  git config --global http.proxy $HTTPS_PROXY'
    warn "plugin and LSP downloads will fail until this works"
fi

# --- config ----------------------------------------------------------------

if [ -d "$CONFIG_DIR" ] && [ ! -f "$CONFIG_DIR/install.sh" ]; then
    backup="${CONFIG_DIR}.bak.$(date +%Y%m%d%H%M%S)"
    bold "Backing up existing config to ${backup}"
    mv "$CONFIG_DIR" "$backup"
fi

if [ ! -d "$CONFIG_DIR" ]; then
    bold "Cloning config"
    git clone --depth 1 "$REPO" "$CONFIG_DIR"
elif [ -d "${CONFIG_DIR}/.git" ]; then
    # Re-running the installer on a machine that already has the config has to
    # actually update it, otherwise you get "I ran install and my new keymaps
    # aren't there". The second pull covers clones whose origin is the SSH URL
    # on a machine with no key loaded.
    bold "Updating config"
    git -C "$CONFIG_DIR" pull --ff-only 2>/dev/null ||
        git -C "$CONFIG_DIR" pull --ff-only "$REPO" main ||
        warn "could not update ${CONFIG_DIR} — check: git -C ${CONFIG_DIR} status"
else
    warn "${CONFIG_DIR} exists but is not a git clone — delete it and re-run to get updates"
fi

bold "Installing plugins (headless)"
nvim --headless "+Lazy! sync" +qa

cat <<'EOF'

Done. Two manual steps:

1. Set your terminal font to "JetBrainsMono Nerd Font" (fixes broken icons):
     Terminal.app : Cmd+, -> Profiles -> Text -> Font Change... -> JetBrainsMono Nerd Font
     iTerm2       : Cmd+, -> Profiles -> Text -> Font -> JetBrainsMono Nerd Font
     Ghostty      : add `font-family = JetBrainsMono Nerd Font` to ~/.config/ghostty/config, restart
     GNOME/kitty/alacritty/VS Code: set the terminal font to the same name
   Verify (should print icons, not boxes):  echo "  "

2. Run: nvim   (first launch downloads the LSP servers — give it a minute)

Optional: gh auth login   (enables GitHub PR review via :Octo)
Health check any time: nvim then :checkhealth
EOF
