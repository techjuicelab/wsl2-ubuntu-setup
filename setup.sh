#!/bin/bash
set -e

echo "=== 0. SSH 키 설정 ==="
WIN_SSH="/mnt/c/Users/techjuice/Documents/dev/.ssh"
mkdir -p "$WIN_SSH"

if [ ! -f "$WIN_SSH/id_ed25519" ]; then
  echo "SSH 키가 없습니다. Windows 공유 경로에 생성합니다..."
  ssh-keygen -t ed25519 -f "$WIN_SSH/id_ed25519" -N "" -C "wsl2@$(hostname)"
  echo ""
  echo "GitHub 공개키 등록 필요:"
  echo "  https://github.com/settings/keys"
  echo ""
  cat "$WIN_SSH/id_ed25519.pub"
  echo ""
fi

mkdir -p ~/.ssh
cp "$WIN_SSH/id_ed25519" ~/.ssh/
cp "$WIN_SSH/id_ed25519.pub" ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
echo "SSH 키 복사 완료"

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

echo "=== 3. Modern Unix 도구 설치 ==="
# eza (아이콘 있는 ls 대체)
sudo apt install -y eza
# bat (구문 강조 cat 대체)
sudo apt install -y bat
mkdir -p ~/.local/bin
[ ! -L ~/.local/bin/bat ] && ln -s /usr/bin/batcat ~/.local/bin/bat

echo "=== 4. Zsh 기본 쉘 설정 ==="
sudo chsh -s $(which zsh) $(whoami)

echo "=== 5. Oh My Zsh 설치 ==="
RUNZSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "=== 6. Powerlevel10k 테마 ==="
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "=== 7. 플러그인 설치 ==="
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/Aloxaf/fzf-tab \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab

echo "=== 8. fzf 설치 ==="
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-bash --no-fish

echo "=== 9. zoxide 설치 ==="
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

echo "=== 10. asdf v0.18.0 설치 ==="
mkdir -p ~/.local/bin
curl -sSfL -L https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-v0.18.0-linux-amd64.tar.gz \
  | tar xz -C ~/.local/bin/

echo "=== 11. .zshrc 설정 ==="
cat > ~/.zshrc << 'EOF'
# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  sudo
  cp
  alias-finder
  gitignore
  colored-man-pages
  command-not-found
  copypath
  copyfile
  history
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  fzf
  fzf-tab
)

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

# === PATH 설정 ===
export PATH="$HOME/.local/bin:$PATH"

# asdf
export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
autoload -Uz compinit && compinit

# === 환경 설정 ===
export EDITOR='vim'
export LANG=ko_KR.UTF-8

# === fzf-tab 설정 ===
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'

if (( $+commands[bat] )); then
  zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 {}'
else
  zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
fi

zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

# === zoxide (스마트 디렉토리 이동) ===
eval "$(zoxide init zsh)"

# === eza aliases (아이콘 있는 ls) ===
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first --time-style=long-iso"
alias la="eza -la --icons --group-directories-first --time-style=long-iso"
alias tree="eza --tree --icons"

# === 일반 aliases ===
alias ..='cd ..'
alias ...='cd ../..'

# Powerlevel10k 설정
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo "=== 셋업 완료! ==="
echo "zsh 를 입력하거나 터미널을 재시작하세요."
echo "Powerlevel10k 설정 마법사가 자동으로 시작됩니다."
