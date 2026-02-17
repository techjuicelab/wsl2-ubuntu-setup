#!/bin/bash
set -e

echo "=== 0. SSH 키 복사 ==="
WIN_SSH="/mnt/c/Users/techjuice/Documents/dev/.ssh"
if [ -f "$WIN_SSH/id_ed25519" ]; then
  mkdir -p ~/.ssh
  cp "$WIN_SSH/id_ed25519" ~/.ssh/
  cp "$WIN_SSH/id_ed25519.pub" ~/.ssh/
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/id_ed25519
  chmod 644 ~/.ssh/id_ed25519.pub
  echo "SSH 키 복사 완료"
else
  echo "Windows SSH 키가 없습니다. 나중에 수동 설정하세요."
fi

echo "=== 1. 패키지 업데이트 ==="
sudo apt update && sudo apt upgrade -y

echo "=== 2. 필수 패키지 설치 ==="
sudo apt install -y \
  git curl wget unzip \
  build-essential libssl-dev libffi-dev \
  zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
  libncurses5-dev libncursesw5-dev xz-utils tk-dev \
  libxml2-dev libxmlsec1-dev liblzma-dev \
  zsh

echo "=== 3. Zsh 기본 쉘 설정 ==="
sudo chsh -s $(which zsh) $(whoami)

echo "=== 4. Oh My Zsh 설치 ==="
RUNZSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "=== 5. Powerlevel10k 테마 ==="
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "=== 6. 플러그인 설치 ==="
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions

echo "=== 7. fzf 설치 ==="
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-bash --no-fish

echo "=== 8. asdf v0.18.0 설치 ==="
mkdir -p ~/.local/bin
curl -sSfL https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-linux-amd64.tar.gz \
  | tar xz -C ~/.local/bin/

echo "=== 9. .zshrc 설정 ==="
cat > ~/.zshrc << 'EOF'
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  fzf
  sudo
  history
  command-not-found
)

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.local/bin:$PATH"
export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"
autoload -Uz compinit && compinit

export EDITOR='vim'
export LANG=ko_KR.UTF-8
alias ll='ls -alF'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo "=== 셋업 완료! ==="
echo "zsh 를 입력하거나 터미널을 재시작하세요."
