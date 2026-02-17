# WSL2 Ubuntu Setup

Windows 11 WSL2 환경에서 Ubuntu 개발 환경을 자동으로 구성하는 셋업 스크립트입니다.

## 포함 도구

### setup.sh — 기본 환경

| 도구 | 버전 | 설명 |
|------|------|------|
| Zsh | 최신 | 기본 쉘 |
| Oh My Zsh | 최신 | Zsh 프레임워크 |
| Powerlevel10k | 최신 | Zsh 테마 |
| zsh-autosuggestions | 최신 | 명령어 자동 제안 |
| zsh-syntax-highlighting | 최신 | 명령어 구문 강조 |
| zsh-completions | 최신 | 추가 자동완성 |
| fzf | 최신 | 퍼지 파인더 |
| fzf-tab | 최신 | fzf 기반 탭 자동완성 미리보기 |
| eza | 최신 | 아이콘 있는 ls 대체 |
| bat | 최신 | 구문 강조 cat 대체 |
| zoxide | 최신 | 스마트 디렉토리 이동 |
| asdf | v0.18.0 | 런타임 버전 관리자 |

### dev-tools.sh — 개발 도구 (선택)

| 도구 | 설명 |
|------|------|
| Node.js | asdf를 통해 최신 LTS 설치 |
| Python | asdf를 통해 최신 버전 설치 (컴파일) |
| pipx | Python 애플리케이션 격리 설치 |
| Claude Code | Anthropic AI 코딩 에이전트 |
| OpenCode | 오픈소스 AI 코딩 에이전트 |
| Gemini CLI | Google AI 코딩 에이전트 |
| SuperClaude | Claude Code 프레임워크 확장 |
| GitHub CLI (gh) | GitHub 공식 CLI |
| ripgrep (rg) | 빠른 정규식 검색 (grep 대체) |
| fd-find (fd) | 빠른 파일 검색 (find 대체) |
| jq | JSON 처리 도구 |
| lazygit | 터미널 Git UI |
| delta | Git diff 구문 강조 |

### Oh My Zsh 플러그인

| 플러그인 | 설명 |
|----------|------|
| git | Git 단축 명령어 및 alias |
| sudo | ESC 두 번 누르면 sudo 자동 추가 |
| cp | cp 진행률 표시 (cpv) |
| alias-finder | alias 검색 |
| gitignore | gitignore 템플릿 생성 |
| colored-man-pages | man 페이지 컬러 표시 |
| command-not-found | 미설치 명령어 패키지 안내 |
| copypath | 현재 경로 클립보드 복사 |
| copyfile | 파일 내용 클립보드 복사 |
| history | 명령어 히스토리 단축키 |

---

## 사전 준비

### 1. Windows Terminal 폰트 설정

Powerlevel10k와 eza 아이콘이 정상 표시되려면 Nerd Font가 필요합니다.

1. [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts) 4개 파일(Regular, Bold, Italic, Bold Italic) 다운로드 후 설치
2. Windows Terminal → 설정 → 프로필 → Ubuntu-24.04 → 모양 → 글꼴 → **MesloLGS NF** 선택

### 2. Windows에서 WSL2 설치

관리자 권한 PowerShell에서 실행:

```powershell
wsl --install -d Ubuntu-24.04
```

설치 중 Unix 사용자 이름과 비밀번호를 설정합니다.

### 3. SSH 키 준비 (최초 1회)

Ubuntu에 진입한 후 SSH 키를 생성하고 Windows에 백업합니다.
이미 SSH 키가 `C:\Users\techjuice\Documents\dev\.ssh`에 있다면 이 단계는 건너뜁니다.

```bash
# SSH 키 생성
ssh-keygen -t ed25519 -C "your-email@example.com"
# 엔터 3번 (기본 경로, 비밀번호 없이)

# GitHub에 공개키 등록
cat ~/.ssh/id_ed25519.pub
# 출력값 복사 → GitHub.com → Settings → SSH and GPG keys → New SSH key

# Windows에 백업
mkdir -p "/mnt/c/Users/techjuice/Documents/dev/.ssh"
cp ~/.ssh/id_ed25519* "/mnt/c/Users/techjuice/Documents/dev/.ssh/"
```

> **중요**: Windows에 백업해두면 Ubuntu를 삭제/재설치해도 SSH 키를 재사용할 수 있습니다.

---

## 설치 방법

### 처음 설치하는 경우

Ubuntu에 진입한 후:

```bash
# 1. Git 설정
git config --global user.email "your-email@example.com"
git config --global user.name "your-name"

# 2. 레포지토리 클론
cd ~
git clone https://github.com/techjuicelab/wsl2-ubuntu-setup.git dotfiles

# 3. 기본 환경 셋업
cd dotfiles
chmod +x setup.sh
./setup.sh

# 4. Zsh 진입 (Powerlevel10k 설정 마법사 시작)
zsh

# 5. 설치 확인
zsh --version
asdf --version
fzf --version
eza --version
bat --version
zoxide --version
```

### 개발 도구 설치 (선택)

setup.sh 완료 후, AI 에이전트와 추가 개발 도구를 설치하려면:

```bash
chmod +x dev-tools.sh
./dev-tools.sh

# 적용
source ~/.zshrc
```

설치 후 각 도구의 인증이 필요합니다:

```bash
claude          # Claude Code 인증
opencode        # OpenCode 인증
gemini          # Gemini CLI 인증
gh auth login   # GitHub CLI 인증
superclaude mcp # MCP 서버 설치 (선택)
```

### Ubuntu 삭제 후 재설치하는 경우

SSH 키가 이미 Windows에 백업되어 있으므로 setup.sh가 자동으로 복원합니다.

PowerShell에서:

```powershell
wsl --unregister Ubuntu-24.04
wsl --install -d Ubuntu-24.04
```

새 Ubuntu에서:

```bash
git config --global user.email "your-email@example.com"
git config --global user.name "your-name"

cd ~
git clone https://github.com/techjuicelab/wsl2-ubuntu-setup.git dotfiles
cd dotfiles
chmod +x setup.sh
./setup.sh

# SSH 복원 후 remote를 SSH로 변경
git remote set-url origin git@github.com:techjuicelab/wsl2-ubuntu-setup.git

zsh
```

---

## 여러 Ubuntu 인스턴스 만들기

베이스 Ubuntu 셋업이 완료되면 export/import로 동일한 환경을 복제할 수 있습니다.

### 1. 베이스 이미지 내보내기

PowerShell에서:

```powershell
wsl --shutdown
wsl --export Ubuntu-24.04 "C:\Users\techjuice\Documents\dev\wsl-base.tar"
```

### 2. 원하는 이름으로 복제

```powershell
mkdir "C:\Users\techjuice\Documents\dev\wsl"
wsl --import Ubuntu-Dev "C:\Users\techjuice\Documents\dev\wsl\dev" "C:\Users\techjuice\Documents\dev\wsl-base.tar"
wsl --import Ubuntu-Test "C:\Users\techjuice\Documents\dev\wsl\test" "C:\Users\techjuice\Documents\dev\wsl-base.tar"
```

### 3. import 후 기본 사용자 설정

import로 만든 인스턴스는 기본 사용자가 root입니다. 일반 사용자로 변경:

```bash
# 인스턴스 진입
wsl -d Ubuntu-Dev

# 기본 사용자 설정
sudo tee /etc/wsl.conf << EOF
[user]
default=techjuice
EOF

exit
```

PowerShell에서 재시작:

```powershell
wsl --shutdown
wsl -d Ubuntu-Dev

# 확인
whoami
# techjuice가 나오면 성공
```

각 인스턴스마다 반복합니다.

### 4. 인스턴스 관리 명령어

```powershell
# 목록 확인
wsl --list --verbose

# 특정 인스턴스 진입
wsl -d Ubuntu-Dev

# 인스턴스 삭제
wsl --unregister Ubuntu-Dev

# 전체 종료
wsl --shutdown
```

---

## 도구 사용법

### asdf (v0.18.0)

v0.16.0부터 Go로 재작성되어 일부 명령어가 변경되었습니다.

```bash
# 플러그인 추가
asdf plugin add nodejs
asdf plugin add python

# 설치 가능한 버전 확인
asdf list all nodejs

# 최신 버전 설치
asdf install nodejs latest
asdf install python latest

# 현재 디렉토리에 버전 설정
asdf set nodejs latest
asdf set python latest

# 홈 디렉토리 기본 버전 설정 (구 asdf global)
asdf set --home nodejs latest

# 설치된 버전 확인
asdf current
```

### eza (ls 대체)

setup.sh가 자동으로 alias를 설정합니다.

```bash
ls      # eza --icons (아이콘 있는 파일 목록)
ll      # eza -l (상세 목록)
la      # eza -la (숨김 파일 포함)
tree    # eza --tree (트리 구조)
```

### bat (cat 대체)

```bash
bat README.md          # 구문 강조된 파일 보기
bat -n README.md       # 줄번호만 표시
```

### zoxide (스마트 디렉토리 이동)

```bash
z dotfiles    # ~/dotfiles로 바로 이동 (이전에 방문한 적 있으면)
z dev         # 가장 자주 간 dev 관련 디렉토리로 이동
zi            # 대화형 디렉토리 선택
```

### fzf-tab

탭 자동완성 시 fzf 미리보기가 자동으로 작동합니다.

```bash
cd <Tab>      # 디렉토리 목록 + eza 미리보기
git checkout <Tab>   # 브랜치 목록
kill <Tab>    # 프로세스 목록 + 정보 미리보기
```

### lazygit

```bash
lg            # lazygit 실행 (alias)
```

터미널 기반 Git UI입니다. 스테이징, 커밋, 브랜치 관리, 리베이스 등을 키보드로 빠르게 수행할 수 있습니다.

### ripgrep (grep 대체)

```bash
rg "검색어"           # 현재 디렉토리에서 재귀 검색 (smart-case 기본)
rg "패턴" src/        # 특정 디렉토리에서 검색
rg -t py "import"     # 파일 타입 필터링
```

### fd (find 대체)

```bash
fd "패턴"             # 파일명 검색
fd -e js              # 확장자로 검색
fd -t d               # 디렉토리만 검색
```

### delta (git diff)

git diff, git log, git show 실행 시 자동으로 적용됩니다.

```bash
git diff              # side-by-side 컬러 diff
git log -p            # 커밋별 변경 내용 (구문 강조)
```

### GitHub CLI

```bash
gh repo clone owner/repo   # 레포지토리 클론
gh pr create               # Pull Request 생성
gh pr list                 # PR 목록 확인
gh issue list              # 이슈 목록 확인
```

---

## 폴더 구조

```
Windows
└── C:\Users\techjuice\Documents\dev\
    ├── .ssh/                    # SSH 키 백업
    ├── wsl-base.tar             # 베이스 이미지
    └── wsl/
        ├── dev/                 # Ubuntu-Dev 디스크
        └── test/                # Ubuntu-Test 디스크

Ubuntu (각 인스턴스)
└── ~/
    ├── dotfiles/                # 이 레포지토리
    │   ├── setup.sh             # 기본 환경 셋업
    │   ├── dev-tools.sh         # 개발 도구 설치 (선택)
    │   └── README.md
    ├── .oh-my-zsh/              # Oh My Zsh
    │   └── custom/
    │       ├── themes/
    │       │   └── powerlevel10k/
    │       └── plugins/
    │           ├── zsh-autosuggestions/
    │           ├── zsh-syntax-highlighting/
    │           ├── zsh-completions/
    │           └── fzf-tab/
    ├── .ssh/                    # SSH 키 (setup.sh가 자동 복원)
    ├── .local/bin/
    │   ├── asdf                 # asdf 바이너리
    │   ├── bat                  # bat 심볼릭 링크
    │   └── fd                   # fd 심볼릭 링크
    ├── .asdf/                   # asdf 데이터 (플러그인, 버전)
    ├── .npm-global/             # npm 글로벌 패키지
    ├── .tool-versions           # asdf 글로벌 런타임 버전
    ├── .zshrc                   # Zsh 설정
    ├── .p10k.zsh                # Powerlevel10k 설정
    └── .fzf/                    # fzf
```

---

## 문제 해결

### Powerlevel10k 아이콘이 깨져 보이는 경우

Windows Terminal에서 Nerd Font를 설정해야 합니다:

1. [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts) 폰트 다운로드 및 설치
2. Windows Terminal → 설정 → 프로필 → Ubuntu → 모양 → 글꼴 → **MesloLGS NF** 선택

### eza 아이콘이 깨져 보이는 경우

MesloLGS NF 폰트가 설정되어 있으면 정상 작동합니다. 위 폰트 설정을 확인하세요.

### setup.sh 실행 중 에러가 나는 경우

```bash
# 로그 확인 후 실패 지점부터 다시 실행
./setup.sh
```

이미 설치된 항목은 git clone이 실패할 수 있습니다. 완전히 초기화하려면:

```bash
rm -rf ~/.oh-my-zsh ~/.fzf ~/.asdf ~/.local/bin/asdf ~/.local/bin/bat
./setup.sh
```

### dev-tools.sh 실행 중 에러가 나는 경우

대부분의 Stage는 멱등성을 가지고 있어 재실행이 가능합니다. asdf 플러그인 추가는 이미 있으면 자동으로 건너뜁니다.

```bash
./dev-tools.sh
```

### p10k 설정 마법사 다시 실행

```bash
p10k configure
```

### 전체 설치 확인

```bash
# 기본 환경 (setup.sh)
zsh --version
asdf --version
fzf --version
eza --version
bat --version
zoxide --version
ls ~/.oh-my-zsh/custom/plugins/
ssh -T git@github.com

# 개발 도구 (dev-tools.sh)
node --version && npm --version
python --version
claude --version
gh --version
rg --version
fd --version
jq --version
lazygit --version
delta --version
```
