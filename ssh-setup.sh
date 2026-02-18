#!/bin/bash
set -e

WIN_SSH="/mnt/c/Users/techjuice/Documents/dev/.ssh"

echo "=== SSH 키 설정 ==="

# Windows 공유 경로 확인
if [ ! -d "/mnt/c/Users/techjuice" ]; then
  echo "오류: Windows 공유 경로(/mnt/c/Users/techjuice)에 접근할 수 없습니다."
  exit 1
fi

mkdir -p "$WIN_SSH"

NEW_KEY=false

if [ -f "$WIN_SSH/id_ed25519" ]; then
  echo "기존 SSH 키를 Windows 공유 경로에서 복원합니다..."
  mkdir -p ~/.ssh
  cp "$WIN_SSH/id_ed25519" ~/.ssh/
  cp "$WIN_SSH/id_ed25519.pub" ~/.ssh/
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/id_ed25519
  chmod 644 ~/.ssh/id_ed25519.pub
  echo "SSH 키 복원 완료: ~/.ssh/id_ed25519"
else
  echo "SSH 키가 없습니다. 새로 생성 후 Windows 공유 경로에 백업합니다..."
  ssh-keygen -t ed25519 -f "$WIN_SSH/id_ed25519" -N "" -C "wsl2@$(hostname)"
  mkdir -p ~/.ssh
  cp "$WIN_SSH/id_ed25519" ~/.ssh/
  cp "$WIN_SSH/id_ed25519.pub" ~/.ssh/
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/id_ed25519
  chmod 644 ~/.ssh/id_ed25519.pub
  NEW_KEY=true
  echo "SSH 키 생성 및 백업 완료: $WIN_SSH/id_ed25519"
  echo ""
  echo "GitHub 공개키 등록이 필요합니다:"
  echo "  https://github.com/settings/keys"
  echo ""
  echo "공개키:"
  cat "$WIN_SSH/id_ed25519.pub"
  echo ""
fi

echo ""
echo "=== dotfiles remote SSH 전환 ==="
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CURRENT_REMOTE=$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || true)
if echo "$CURRENT_REMOTE" | grep -q "^https://github.com/"; then
  SSH_REMOTE=$(echo "$CURRENT_REMOTE" | sed 's|https://github.com/|git@github.com:|')
  git -C "$DOTFILES_DIR" remote set-url origin "$SSH_REMOTE"
  echo "Remote 전환 완료: $SSH_REMOTE"
  if [ "$NEW_KEY" = true ]; then
    echo "※ 새 SSH 키를 생성했습니다. GitHub에 공개키를 등록한 후 git push가 가능합니다."
  fi
else
  echo "이미 SSH remote입니다: $CURRENT_REMOTE"
fi
