# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WSL2 Ubuntu 24.04 development environment setup toolkit (`wsl2-ubuntu-setup`). Automates installation of shell configuration, modern CLI tools, runtime managers, and AI coding agents for Windows 11 WSL2. Documentation (README.md) is written in Korean.

## Architecture

Two-stage sequential installation:

1. **setup.sh** — Base environment: system packages, zsh + Oh My Zsh + Powerlevel10k, modern CLI tools (eza, bat, fzf, zoxide), and asdf v0.18.0 runtime manager. Generates `~/.zshrc` with all plugin/alias/PATH configuration.
2. **dev-tools.sh** — Developer tools (requires setup.sh first): Node.js and Python via asdf, AI agents (Claude Code, OpenCode, Gemini CLI, SuperClaude), GitHub CLI, ripgrep, fd-find, jq, lazygit, delta (git diff pager). Appends additional config to `~/.zshrc`.
3. **claude-config.sh** — Standalone Claude Code settings backup/restore. Copies `settings.json`, `commands/`, and MCP server config (`mcpServers` key from `~/.claude.json`) to/from Windows host path for sharing across WSL instances.

Both scripts use `set -e` (exit on first error). dev-tools.sh uses colorized output for stage tracking.

## Key Design Decisions

- **asdf v0.18.0** (Go rewrite) for all runtime management — commands differ from older bash-based versions (uses `asdf set -u` instead of `asdf global`)
- **SSH keys restored from Windows host** (`/mnt/c/Users/techjuice/Documents/dev/.ssh/`) on fresh setup
- **Locale**: ko_KR.UTF-8 primary, en_US.UTF-8 fallback
- **npm global dir**: `~/.npm-global` (avoids sudo for `npm install -g`)
- **~/.local/bin** prioritized in PATH for user-installed tools to override system versions
- **WSL instance cloning** supported via `wsl --export` / `wsl --import`
- **Automatic SSH remote switch**: Both `setup.sh` (Stage 12) and `ssh-setup.sh` automatically convert the dotfiles git remote from HTTPS to SSH after SSH key setup. Uses `sed` to transform `https://github.com/` → `git@github.com:`. If a new key was generated, a warning is shown that GitHub registration is required before pushing.
- **Claude Code native installer**: Claude Code uses the official native binary installer (`curl -fsSL https://claude.ai/install.sh | bash`) instead of the deprecated npm shim. Binary installs to `~/.local/share/claude/versions/` with symlink at `~/.local/bin/claude` (already in PATH).
- **Claude Code config backup/restore**: `claude-config.sh` backs up `settings.json`, `commands/`, and MCP server settings to `/mnt/c/Users/techjuice/Documents/dev/.claude-config/` for sharing across WSL instances (same pattern as SSH key sharing). MCP restore uses `jq` to merge only the `mcpServers` key, preserving existing auth data.
- **OpenCode PATH fix**: OpenCode installs to `~/.opencode/bin/` and its installer uses `$SHELL` to detect which config file to update. When running under `#!/bin/bash`, it may write to `.bashrc` instead of `.zshrc`. dev-tools.sh explicitly appends `~/.opencode/bin` to `.zshrc` after installation to ensure it's always available in zsh.

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
