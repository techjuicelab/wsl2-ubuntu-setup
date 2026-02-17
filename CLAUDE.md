# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WSL2 Ubuntu 24.04 development environment setup toolkit (`wsl2-ubuntu-setup`). Automates installation of shell configuration, modern CLI tools, runtime managers, and AI coding agents for Windows 11 WSL2. Documentation (README.md) is written in Korean.

## Architecture

Two-stage sequential installation:

1. **setup.sh** — Base environment: system packages, zsh + Oh My Zsh + Powerlevel10k, modern CLI tools (eza, bat, fzf, zoxide), and asdf v0.18.0 runtime manager. Generates `~/.zshrc` with all plugin/alias/PATH configuration.
2. **dev-tools.sh** — Developer tools (requires setup.sh first): Node.js and Python via asdf, AI agents (Claude Code, OpenCode, Gemini CLI, SuperClaude), GitHub CLI, ripgrep, fd-find, jq, lazygit, delta (git diff pager). Appends additional config to `~/.zshrc`.

Both scripts use `set -e` (exit on first error). dev-tools.sh uses colorized output for stage tracking.

## Key Design Decisions

- **asdf v0.18.0** (Go rewrite) for all runtime management — commands differ from older bash-based versions (uses `asdf set -u` instead of `asdf global`)
- **SSH keys restored from Windows host** (`/mnt/c/Users/techjuice/Documents/dev/.ssh/`) on fresh setup
- **Locale**: ko_KR.UTF-8 primary, en_US.UTF-8 fallback
- **npm global dir**: `~/.npm-global` (avoids sudo for `npm install -g`)
- **~/.local/bin** prioritized in PATH for user-installed tools to override system versions
- **WSL instance cloning** supported via `wsl --export` / `wsl --import`

## Verification Commands

```bash
# After setup.sh
zsh --version && asdf --version && fzf --version && eza --version && bat --version && zoxide --version

# After dev-tools.sh
node --version && python --version && claude --version && gh --version
rg --version && fd --version && jq --version && lazygit --version && delta --version
```

## Shell Aliases (configured in .zshrc)

- `ls`, `ll`, `la`, `tree` → eza variants
- `lg` → lazygit
- `rg` → ripgrep with `--smart-case`
- `bat` → batcat symlink

## When Editing Scripts

- Maintain the numbered stage pattern for consistent output
  - setup.sh: `echo "=== N. 제목 ==="`
  - dev-tools.sh: `print_header "N. Title"` (colorized helper functions)
- dev-tools.sh uses `|| true` on some commands (e.g., asdf plugin adds) to handle idempotent re-runs
- dev-tools.sh guards `.zshrc` appends with `grep -q` checks to avoid duplicates on re-run
- The .zshrc is **generated** by setup.sh (Stage 11) and **appended to** by dev-tools.sh — do not treat it as a standalone file to edit directly
- README.md is written in Korean — maintain Korean for all user-facing documentation
