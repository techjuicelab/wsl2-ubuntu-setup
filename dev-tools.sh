#!/bin/bash
# =============================================================================
# dev-tools.sh - Development Tools Installer for WSL2 Ubuntu
# =============================================================================
# Installs AI coding agents, modern CLI tools, and development utilities
# Run after setup.sh (which installs zsh, oh-my-zsh, asdf, etc.)
#
# Usage:
#   chmod +x dev-tools.sh
#   ./dev-tools.sh
#
# Prerequisites:
#   - setup.sh already executed (asdf, zsh, oh-my-zsh installed)
#   - Internet connection
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo -e "${GREEN}▶ $1${NC}"
}

print_info() {
    echo -e "${BLUE}  ℹ $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}  ⚠ $1${NC}"
}

print_done() {
    echo -e "${GREEN}  ✔ $1${NC}"
}

print_error() {
    echo -e "${RED}  ✖ $1${NC}"
}

# =============================================================================
# 0. Locale Fix
# =============================================================================
print_header "0. Fixing Locale Settings"

print_step "Generating ko_KR.UTF-8 and en_US.UTF-8 locales..."
sudo locale-gen ko_KR.UTF-8 en_US.UTF-8
sudo update-locale LANG=ko_KR.UTF-8 LC_ALL=ko_KR.UTF-8 LANGUAGE=ko_KR:en

print_done "Locale configured"

# =============================================================================
# 1. System Update
# =============================================================================
print_header "1. System Update"

print_step "Updating package lists..."
sudo apt update && sudo apt upgrade -y

print_done "System updated"

# =============================================================================
# 2. Node.js via asdf
# =============================================================================
print_header "2. Node.js (via asdf)"

# Ensure asdf is available
export PATH="$HOME/.local/bin:$PATH"
export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"

# Check asdf exists
if ! command -v asdf &> /dev/null; then
    print_error "asdf not found. Run setup.sh first!"
    exit 1
fi

print_step "Adding Node.js plugin..."
asdf plugin add nodejs 2>/dev/null || true

print_step "Installing latest Node.js..."
asdf install nodejs latest

print_step "Setting Node.js as global default (asdf set -u)..."
touch ~/.tool-versions
asdf set -u nodejs latest

# npm global directory setup (avoid permission issues)
print_step "Configuring npm global directory..."
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# Add to .zshrc if not already present
if ! grep -q 'npm-global' ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc << 'NPMEOF'

# npm global directory
export PATH="$HOME/.npm-global/bin:$PATH"
NPMEOF
fi

export PATH="$HOME/.npm-global/bin:$PATH"

print_done "Node.js $(node --version) installed"
print_done "npm $(npm --version) installed"

# =============================================================================
# 3. Python via asdf
# =============================================================================
print_header "3. Python (via asdf)"

print_step "Adding Python plugin..."
asdf plugin add python 2>/dev/null || true

print_step "Installing latest Python (this may take a few minutes)..."
asdf install python latest

print_step "Setting Python as global default..."
asdf set -u python latest

print_done "Python $(python --version 2>&1) installed"

# =============================================================================
# 4. pipx
# =============================================================================
print_header "4. pipx"

print_step "Installing pipx..."
python -m pip install --user pipx 2>/dev/null || pip install --user pipx

# Ensure pipx is in PATH
python -m pipx ensurepath 2>/dev/null || true

# Add to PATH for current session
export PATH="$HOME/.local/bin:$PATH"

print_done "pipx installed"

# =============================================================================
# 5. AI Coding Agents
# =============================================================================
print_header "5. AI Coding Agents"

# --- Claude Code ---
print_step "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code
print_done "Claude Code $(claude --version 2>/dev/null || echo '(installed)') installed"

# --- OpenCode ---
print_step "Installing OpenCode..."
curl -fsSL https://opencode.ai/install | bash
# Installer detects shell from $SHELL — when running as bash script, it may
# write to .bashrc instead of .zshrc. Explicitly ensure .zshrc has the PATH.
if ! grep -q '\.opencode/bin' ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc << 'OPENCODEEOF'

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
OPENCODEEOF
fi
export PATH="$HOME/.opencode/bin:$PATH"
print_done "OpenCode installed"

# --- Gemini CLI ---
print_step "Installing Gemini CLI..."
npm install -g @google/gemini-cli
print_done "Gemini CLI installed"

# =============================================================================
# 6. SuperClaude Framework
# =============================================================================
print_header "6. SuperClaude Framework"

print_step "Installing SuperClaude via pipx..."
pipx install superclaude

print_step "Installing SuperClaude commands..."
superclaude install

print_done "SuperClaude installed"
print_info "Run 'superclaude mcp --list' to see available MCP servers"
print_info "Run 'superclaude mcp' for interactive MCP installation"

# =============================================================================
# 7. GitHub CLI (gh)
# =============================================================================
print_header "7. GitHub CLI (gh)"

print_step "Installing GitHub CLI..."
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && rm -f "$out" \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y

print_done "GitHub CLI $(gh --version 2>/dev/null | head -1) installed"

# =============================================================================
# 8. Modern CLI Tools (apt)
# =============================================================================
print_header "8. Modern CLI Tools"

# --- ripgrep ---
print_step "Installing ripgrep (rg)..."
sudo apt install -y ripgrep
print_done "ripgrep $(rg --version | head -1) installed"

# --- fd-find ---
print_step "Installing fd-find..."
sudo apt install -y fd-find

# Create symlink: fdfind → fd
if [ ! -L ~/.local/bin/fd ]; then
    mkdir -p ~/.local/bin
    ln -sf "$(which fdfind)" ~/.local/bin/fd
fi
print_done "fd-find installed (use 'fd' command)"

# --- jq ---
print_step "Installing jq..."
sudo apt install -y jq
print_done "jq $(jq --version) installed"

# =============================================================================
# 9. lazygit (latest from GitHub)
# =============================================================================
print_header "9. lazygit"

print_step "Installing lazygit (latest release)..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit -D -t /usr/local/bin/
rm -f /tmp/lazygit /tmp/lazygit.tar.gz

print_done "lazygit v${LAZYGIT_VERSION} installed"

# =============================================================================
# 10. delta (git diff highlighter)
# =============================================================================
print_header "10. delta (git diff pager)"

print_step "Installing delta (latest release)..."
DELTA_VERSION=$(curl -sL "https://api.github.com/repos/dandavison/delta/releases/latest" | awk -F\" '/"tag_name":/{print $(NF-1)}')
curl -Lo /tmp/git-delta.deb "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb"
sudo apt install -y /tmp/git-delta.deb
rm -f /tmp/git-delta.deb

# Configure git to use delta
print_step "Configuring git to use delta..."
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.dark true
git config --global delta.side-by-side true
git config --global delta.line-numbers true
git config --global merge.conflictStyle zdiff3

print_done "delta ${DELTA_VERSION} installed and configured with git"

# =============================================================================
# 11. Add aliases to .zshrc
# =============================================================================
print_header "11. Shell Aliases & Configuration"

if ! grep -q '# dev-tools aliases' ~/.zshrc 2>/dev/null; then
    print_step "Adding aliases to .zshrc..."
    cat >> ~/.zshrc << 'ALIASEOF'

# dev-tools aliases
alias lg="lazygit"
alias rg="rg --smart-case"
ALIASEOF
    print_done "Aliases added"
else
    print_info "Aliases already exist in .zshrc, skipping"
fi

# =============================================================================
# Summary
# =============================================================================
print_header "Installation Complete! 🎉"

echo ""
echo -e "${GREEN}  ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}  │  Installed Tools Summary                           │${NC}"
echo -e "${GREEN}  ├─────────────────────────────────────────────────────┤${NC}"
echo -e "${GREEN}  │  Runtime & Package Managers                        │${NC}"
echo -e "${GREEN}  │    Node.js ......... $(node --version 2>/dev/null || echo 'N/A')                          │${NC}"
echo -e "${GREEN}  │    npm ............. $(npm --version 2>/dev/null || echo 'N/A')                           │${NC}"
echo -e "${GREEN}  │    Python .......... $(python --version 2>&1 | awk '{print $2}')                        │${NC}"
echo -e "${GREEN}  │    pipx ............ $(pipx --version 2>/dev/null || echo 'N/A')                          │${NC}"
echo -e "${GREEN}  │                                                     │${NC}"
echo -e "${GREEN}  │  AI Coding Agents                                  │${NC}"
echo -e "${GREEN}  │    Claude Code ..... ✔                              │${NC}"
echo -e "${GREEN}  │    OpenCode ........ ✔                              │${NC}"
echo -e "${GREEN}  │    Gemini CLI ...... ✔                              │${NC}"
echo -e "${GREEN}  │    SuperClaude ..... ✔                              │${NC}"
echo -e "${GREEN}  │                                                     │${NC}"
echo -e "${GREEN}  │  Developer Tools                                   │${NC}"
echo -e "${GREEN}  │    GitHub CLI ...... ✔                              │${NC}"
echo -e "${GREEN}  │    ripgrep ......... ✔                              │${NC}"
echo -e "${GREEN}  │    fd-find ......... ✔                              │${NC}"
echo -e "${GREEN}  │    jq .............. ✔                              │${NC}"
echo -e "${GREEN}  │    lazygit ......... v${LAZYGIT_VERSION:-N/A}                          │${NC}"
echo -e "${GREEN}  │    delta ........... ${DELTA_VERSION:-N/A}                          │${NC}"
echo -e "${GREEN}  └─────────────────────────────────────────────────────┘${NC}"
echo ""

echo -e "${YELLOW}  Next Steps:${NC}"
echo -e "${YELLOW}  1. source ~/.zshrc (or restart terminal)${NC}"
echo -e "${YELLOW}  2. claude        → authenticate Claude Code${NC}"
echo -e "${YELLOW}  3. opencode      → authenticate OpenCode${NC}"
echo -e "${YELLOW}  4. gemini        → authenticate Gemini CLI${NC}"
echo -e "${YELLOW}  5. gh auth login → authenticate GitHub CLI${NC}"
echo -e "${YELLOW}  6. superclaude mcp → install MCP servers (optional)${NC}"
echo ""
echo -e "${CYAN}  After all authentication is done:${NC}"
echo -e "${CYAN}  PowerShell> wsl --export Ubuntu-24.04 \"path\\to\\wsl-base.tar\"${NC}"
echo -e "${CYAN}  Then import as Ubuntu-Dev, Ubuntu-Test, etc.${NC}"
echo ""
