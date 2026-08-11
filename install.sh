#!/usr/bin/env bash
# tech-lead-nvim installer — macOS + Linux (apt / dnf / pacman)
# Safe to re-run. Backs up any existing config before touching it.
set -euo pipefail

REPO="https://github.com/blankdean/tech-lead-nvim"
CONFIG_DIR="${HOME}/.config/nvim"
NVIM_MIN_MINOR=11 # requires neovim >= 0.11

bold() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[33mwarn:\033[0m %s\n' "$*"; }

# --- helpers ---------------------------------------------------------------

nvim_ok() {
    command -v nvim >/dev/null 2>&1 || return 1
    local v minor
    v="$(nvim --version | head -1 | sed 's/^NVIM v//')"
    minor="$(echo "$v" | cut -d. -f2)"
    [ "$(echo "$v" | cut -d. -f1)" -gt 0 ] || [ "$minor" -ge "$NVIM_MIN_MINOR" ]
}

install_nvim_tarball() {
    # Official release tarball into ~/.local — no sudo, works on any distro
    local arch tar
    case "$(uname -m)" in
    x86_64) arch="linux-x86_64" ;;
    aarch64 | arm64) arch="linux-arm64" ;;
    *)
        warn "unknown arch $(uname -m) — install neovim >= 0.11 manually"
        return 1
        ;;
    esac
    tar="nvim-${arch}.tar.gz"
    bold "Installing Neovim (official tarball) to ~/.local/opt"
    mkdir -p "${HOME}/.local/opt" "${HOME}/.local/bin"
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/${tar}" \
        -o "/tmp/${tar}"
    tar -xzf "/tmp/${tar}" -C "${HOME}/.local/opt"
    ln -sf "${HOME}/.local/opt/nvim-${arch}/bin/nvim" "${HOME}/.local/bin/nvim"
    rm -f "/tmp/${tar}"
    case ":$PATH:" in
    *":${HOME}/.local/bin:"*) ;;
    *) warn 'add ~/.local/bin to your PATH (export PATH="$HOME/.local/bin:$PATH")' ;;
    esac
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

# --- dependencies ----------------------------------------------------------

case "$(uname -s)" in
Darwin)
    command -v brew >/dev/null 2>&1 || {
        echo "Homebrew required on macOS: https://brew.sh"
        exit 1
    }
    bold "Installing dependencies (brew)"
    for pkg in neovim ripgrep fd node gh lazygit; do
        brew list "$pkg" >/dev/null 2>&1 || brew install "$pkg" || warn "$pkg failed — install manually"
    done
    brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1 ||
        brew install --cask font-jetbrains-mono-nerd-font || warn "font install failed"
    ;;
Linux)
    bold "Installing dependencies"
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -qq
        sudo apt-get install -y -qq git curl ripgrep fd-find nodejs npm gcc make unzip fontconfig xz-utils || true
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y -q git curl ripgrep fd-find nodejs gcc make unzip fontconfig xz || true
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm git curl ripgrep fd nodejs npm gcc make unzip fontconfig xz || true
    else
        warn "unknown package manager — ensure git, curl, ripgrep, node, gcc are installed"
    fi
    nvim_ok || install_nvim_tarball
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

# --- config ----------------------------------------------------------------

if [ -d "$CONFIG_DIR" ] && [ ! -f "$CONFIG_DIR/install.sh" ]; then
    backup="${CONFIG_DIR}.bak.$(date +%Y%m%d%H%M%S)"
    bold "Backing up existing config to ${backup}"
    mv "$CONFIG_DIR" "$backup"
fi

if [ ! -d "$CONFIG_DIR" ]; then
    bold "Cloning config"
    git clone --depth 1 "$REPO" "$CONFIG_DIR"
fi

bold "Installing plugins (headless)"
nvim --headless "+Lazy! sync" +qa

cat <<'EOF'

Done. Two manual steps:
  1. Set your terminal font to "JetBrainsMono Nerd Font".
  2. Run: nvim   (first launch downloads the LSP servers — give it a minute)

Optional: gh auth login   (enables GitHub PR review via :Octo)
Health check any time: nvim then :checkhealth
EOF
