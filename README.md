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

### ssh-setup.sh — SSH 키 설정 (독립 실행)

인스턴스 복제 후 SSH 키만 별도로 설정할 때 사용합니다.

| 상황 | 동작 |
|------|------|
| `C:\Users\techjuice\Documents\dev\.ssh\id_ed25519` 존재 | `~/.ssh/`에 복원 후 권한 설정 |
| `C:\Users\techjuice\Documents\dev\.ssh\id_ed25519` 없음 | 새 ed25519 키 생성 → Windows 경로에 백업 → `~/.ssh/`에 복사 → 공개키 출력 |

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

### MCP 서버 (Claude Code 확장)

dev-tools.sh 설치 후 `claude-config.sh backup`으로 백업하면 다른 인스턴스에서도 자동 복원됩니다.

| 서버 | 설명 |
|------|------|
| sequential-thinking | 다단계 문제 해결 및 체계적 분석 |
| context7 | 라이브러리 공식 문서 및 코드 예제 실시간 조회 |
| playwright | 크로스 브라우저 E2E 테스트 및 자동화 |

### Claude Code 스킬 (anthropics/skills)

Claude Code 내에서 `/스킬이름`으로 사용하는 전문 스킬입니다.

| 스킬 | 설명 |
|------|------|
| pdf | PDF 문서 생성 |
| docx | Word 문서 생성 |
| pptx | PowerPoint 프레젠테이션 생성 |
| xlsx | Excel 스프레드시트 생성 |
| doc-coauthoring | 문서 공동 작성 |
| frontend-design | 프론트엔드 UI 디자인 |
| canvas-design | 캔버스 기반 디자인 |
| web-artifacts-builder | 웹 아티팩트 빌더 |
| webapp-testing | 웹 애플리케이션 테스트 |
| mcp-builder | MCP 서버 생성 |
| skill-creator | 커스텀 스킬 생성 |
| algorithmic-art | 알고리즘 아트 생성 |
| theme-factory | 테마/스타일 시스템 생성 |
| brand-guidelines | 브랜드 가이드라인 작성 |
| internal-comms | 사내 커뮤니케이션 작성 |
| slack-gif-creator | Slack GIF 생성 |

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

### 3. SSH 키 준비

SSH 키는 `C:\Users\techjuice\Documents\dev\.ssh`에 저장되어 모든 WSL 인스턴스가 공유합니다.

- **최초 설치 시**: setup.sh가 자동으로 키를 생성하고 공개키를 출력합니다. 출력된 공개키를 GitHub에 등록하세요.
- **재설치 시**: Windows 경로에 키가 있으면 setup.sh가 자동으로 복원합니다. 별도 작업 불필요.
- **인스턴스 복제 시**: setup.sh는 이미 실행된 상태이므로 `ssh-setup.sh`로 SSH 키만 별도 설정합니다.

> **GitHub 공개키 등록**: https://github.com/settings/keys

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
```

dev-tools.sh는 다음 단계를 순서대로 실행합니다:

| 단계 | 내용 |
|------|------|
| Stage 0 | 로케일 설정 (ko_KR.UTF-8) |
| Stage 1 | 시스템 패키지 업데이트 |
| Stage 2 | Node.js 설치 (asdf + npm 글로벌 디렉토리 설정) |
| Stage 3 | Python 설치 (asdf, 소스 컴파일) |
| Stage 4 | pipx 설치 |
| Stage 5 | AI 코딩 에이전트 설치 (Claude Code, OpenCode, Gemini CLI) |
| Stage 6 | SuperClaude 프레임워크 설치 |
| Stage 7 | Claude Code 설정 복원 (Windows 백업에서) |
| Stage 8 | GitHub CLI 설치 |
| Stage 9 | 모던 CLI 도구 설치 (ripgrep, fd-find, jq) |
| Stage 10 | lazygit 설치 (GitHub 최신 릴리스) |
| Stage 11 | delta 설치 및 git 연동 설정 |
| Stage 12 | Shell alias 추가 (.zshrc에 lg, rg 등) |

> **참고**: Python 설치(Stage 3)는 소스 컴파일로 진행되어 수 분이 걸릴 수 있습니다.
> 이미 설치된 도구가 있어도 멱등성이 보장되어 재실행 가능합니다.

설치 완료 후 적용:

```bash
source ~/.zshrc
```

### 설치 후 인증

각 도구별 인증이 필요합니다:

```bash
# Claude Code — Anthropic 계정으로 인증
claude

# OpenCode — AI 서비스 선택 후 인증
opencode

# Gemini CLI — Google 계정으로 인증
gemini

# GitHub CLI — GitHub 계정 인증
gh auth login

# SuperClaude MCP 서버 설치 (선택)
superclaude mcp
```

모든 인증과 MCP 설정 완료 후, Claude Code 설정을 백업하세요:

```bash
bash claude-config.sh backup
```

그 후 WSL 이미지를 내보내면 동일한 환경을 복제할 수 있습니다:

```powershell
# PowerShell에서
wsl --export Ubuntu-24.04 "C:\Users\techjuice\Documents\dev\wsl-base.tar"
```

### 설치 확인

```bash
# 기본 환경 (setup.sh)
zsh --version && asdf --version && fzf --version && eza --version && bat --version && zoxide --version

# 개발 도구 (dev-tools.sh)
node --version && npm --version
python --version
claude --version
gh --version
rg --version && fd --version && jq --version
lazygit --version && delta --version
```

### 인스턴스 복제 후 SSH 설정하는 경우

`wsl --import`로 복제한 인스턴스는 setup.sh가 이미 실행된 상태입니다. SSH 키만 별도로 설정합니다.

```bash
cd ~/dotfiles
bash ssh-setup.sh
```

- Windows 경로(`C:\Users\techjuice\Documents\dev\.ssh`)에 키가 있으면 `~/.ssh/`에 복원합니다.
- 키가 없으면 새로 생성하고 Windows 경로에 백업한 뒤 공개키를 출력합니다. 출력된 공개키를 GitHub에 등록하세요.

ssh-setup.sh가 SSH 키 설정 후 자동으로 dotfiles remote를 SSH로 전환합니다.

### Claude Code 설정 백업/복원

Claude Code의 설정, 커스텀 명령어, MCP 서버 설정을 Windows 호스트에 백업하여 여러 WSL 인스턴스 간 공유할 수 있습니다.

```bash
cd ~/dotfiles

# 현재 설정을 Windows에 백업
bash claude-config.sh backup

# Windows 백업에서 설정 복원
bash claude-config.sh restore
```

백업 경로: `C:\Users\techjuice\Documents\dev\.claude-config\`

| 백업 대상 | 소스 | 설명 |
|-----------|------|------|
| `settings.json` | `~/.claude/settings.json` | 전역 설정 |
| `commands/` | `~/.claude/commands/` | SuperClaude 스킬 + 커스텀 명령어 |
| `plugins/` | `~/.claude/plugins/` | 스킬 마켓플레이스 + 설치된 스킬 |
| `mcp-servers.json` | `~/.claude.json`의 `mcpServers` 키 | MCP 서버 설정만 추출 |

> **참고**: 인증 정보(`.credentials.json`, `oauthAccount` 등)와 세션 데이터(`projects/`, `cache/` 등)는 백업에서 제외됩니다.

dev-tools.sh 실행 시 Windows 백업이 존재하면 자동으로 설정을 복원합니다(Stage 7).

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

### 4. 복제 인스턴스 SSH 키 설정

복제된 각 인스턴스에서 SSH 키를 설정합니다:

```bash
cd ~/dotfiles
bash ssh-setup.sh
```

Windows 경로에 키가 있으면 자동으로 복원됩니다. dotfiles remote도 자동으로 SSH로 전환됩니다.

SSH 연결 확인:

```bash
ssh -T git@github.com
```

### 5. 인스턴스 관리 명령어

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

### AI 코딩 에이전트

#### Claude Code

Anthropic의 공식 AI 코딩 에이전트입니다. 터미널에서 코드를 작성하고, 디버깅하고, 설명을 받을 수 있습니다.

```bash
# 인증 (최초 1회)
claude

# 현재 디렉토리에서 Claude 실행
claude

# 파일을 컨텍스트로 포함하여 질문
claude "이 코드에서 버그를 찾아줘"

# 특정 작업 지시
claude "README.md를 한국어로 번역해줘"
```

#### OpenCode

오픈소스 AI 코딩 에이전트로 여러 AI 모델을 선택할 수 있습니다.

```bash
# 실행 (첫 실행 시 AI 서비스 선택)
opencode
```

#### Gemini CLI

Google의 AI 코딩 에이전트입니다.

```bash
# 인증 후 실행
gemini

# 특정 파일 분석
gemini "이 함수를 최적화해줘"
```

#### SuperClaude

Claude Code에 추가 명령어와 워크플로우를 제공하는 프레임워크입니다.

```bash
# 설치된 명령어 목록 확인
superclaude --help

# MCP 서버 목록 확인
superclaude mcp --list

# MCP 서버 대화형 설치
superclaude mcp

# Claude Code 내에서 SuperClaude 명령어 사용
# /sc:implement  — 기능 구현
# /sc:analyze    — 코드 분석
# /sc:test       — 테스트 실행
# /sc:git        — Git 작업
# /sc:help       — 전체 명령어 목록
```

### MCP 서버

Claude Code에서 자동으로 활성화됩니다. `/mcp`로 상태를 확인할 수 있습니다.

#### sequential-thinking

복잡한 문제를 단계별로 분석합니다. Claude Code가 자동으로 사용합니다.

#### context7

라이브러리 문서를 실시간으로 조회합니다. Claude Code 내에서 자동으로 활용되어 최신 문서 기반의 정확한 코드를 생성합니다.

#### playwright

웹 브라우저를 자동화하여 E2E 테스트를 수행합니다.

```bash
# Claude Code 내에서 사용 예시
# "localhost:3000 페이지를 열어서 로그인 폼이 정상 동작하는지 테스트해줘"
# "이 웹페이지 스크린샷을 찍어서 레이아웃 확인해줘"
```

#### MCP 서버 관리

```bash
# 설치된 MCP 서버 목록 확인
superclaude mcp --list

# 추가 서버 설치 (예: tavily 웹 검색)
superclaude mcp --servers tavily

# Claude Code 내에서 MCP 상태 확인
# /mcp
```

### Claude Code 스킬

Claude Code 내에서 `/스킬이름`으로 전문 스킬을 호출합니다. anthropics/skills 마켓플레이스에서 설치됩니다.

```bash
# Claude Code 내에서 사용 예시

# PDF 문서 생성
# /pdf "프로젝트 기획서를 PDF로 만들어줘"

# Word 문서 생성
# /docx "회의록을 docx 형식으로 작성해줘"

# PowerPoint 생성
# /pptx "서비스 소개 발표자료를 만들어줘"

# Excel 스프레드시트 생성
# /xlsx "매출 데이터를 스프레드시트로 정리해줘"

# 프론트엔드 디자인
# /frontend-design "로그인 페이지를 디자인해줘"

# 웹 앱 테스트
# /webapp-testing "폼 유효성 검사를 테스트해줘"

# MCP 서버 생성
# /mcp-builder "GitHub 이슈를 관리하는 MCP 서버를 만들어줘"

# 커스텀 스킬 생성
# /skill-creator "코드 리뷰 자동화 스킬을 만들어줘"
```

#### 스킬 관리

```bash
# 설치된 스킬 목록 확인 (Claude Code 내에서)
# /plugin list

# 마켓플레이스 업데이트
# /plugin marketplace update
```

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
cd <Tab>             # 디렉토리 목록 + eza 미리보기
git checkout <Tab>   # 브랜치 목록
kill <Tab>           # 프로세스 목록 + 정보 미리보기
```

### lazygit

```bash
lg            # lazygit 실행 (alias)
```

터미널 기반 Git UI입니다. 스테이징, 커밋, 브랜치 관리, 리베이스 등을 키보드로 빠르게 수행할 수 있습니다.

| 키 | 동작 |
|----|------|
| `space` | 파일 스테이징/언스테이징 |
| `c` | 커밋 |
| `p` | push |
| `P` | pull |
| `b` | 브랜치 메뉴 |
| `?` | 도움말 |

### ripgrep (grep 대체)

```bash
rg "검색어"           # 현재 디렉토리에서 재귀 검색 (smart-case 기본)
rg "패턴" src/        # 특정 디렉토리에서 검색
rg -t py "import"     # 파일 타입 필터링
rg -l "TODO"          # 파일명만 출력
```

### fd (find 대체)

```bash
fd "패턴"             # 파일명 검색
fd -e js              # 확장자로 검색
fd -t d               # 디렉토리만 검색
fd -t f --changed-within 1d   # 하루 내 변경된 파일
```

### delta (git diff)

git diff, git log, git show 실행 시 자동으로 적용됩니다.

```bash
git diff              # side-by-side 컬러 diff
git log -p            # 커밋별 변경 내용 (구문 강조)
git show HEAD         # 최근 커밋 내용
```

### jq (JSON 처리)

```bash
cat data.json | jq '.'              # 예쁘게 출력 (pretty print)
cat data.json | jq '.name'          # 특정 필드 추출
cat data.json | jq '.items[]'       # 배열 펼치기
curl -s api/endpoint | jq '.data'   # API 응답 파싱
```

### GitHub CLI

```bash
gh repo clone owner/repo   # 레포지토리 클론
gh pr create               # Pull Request 생성
gh pr list                 # PR 목록 확인
gh pr checkout 123         # PR 체크아웃
gh issue list              # 이슈 목록 확인
gh issue create            # 이슈 생성
gh run list                # GitHub Actions 실행 목록
gh run watch               # Actions 실행 상태 모니터링
```

---

## 폴더 구조

```
Windows
└── C:\Users\techjuice\Documents\dev\
    ├── .ssh/                    # SSH 키 백업
    ├── .claude-config/          # Claude Code 설정 백업
    │   ├── settings.json
    │   ├── commands/
    │   ├── plugins/             # 스킬 마켓플레이스 + 설치된 스킬
    │   └── mcp-servers.json
    ├── wsl-base.tar             # 베이스 이미지
    └── wsl/
        ├── dev/                 # Ubuntu-Dev 디스크
        └── test/                # Ubuntu-Test 디스크

Ubuntu (각 인스턴스)
└── ~/
    ├── dotfiles/                # 이 레포지토리
    │   ├── setup.sh             # 기본 환경 셋업
    │   ├── dev-tools.sh         # 개발 도구 설치 (선택)
    │   ├── ssh-setup.sh         # SSH 키 설정 (복제 인스턴스용)
    │   ├── claude-config.sh     # Claude Code 설정 백업/복원
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
    ├── .opencode/               # OpenCode 바이너리 (~/.opencode/bin/opencode)
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

### Python 설치가 너무 오래 걸리는 경우

Python은 소스 컴파일 방식으로 설치됩니다. 컴파일 시간은 시스템 성능에 따라 5~15분이 소요될 수 있습니다. 진행 중인 출력이 멈춰 보여도 정상입니다.

### claude / gemini 명령어를 찾을 수 없는 경우

dev-tools.sh 실행 후 `.zshrc`를 새로 불러와야 합니다:

```bash
source ~/.zshrc
```

또는 터미널을 재시작하세요.

### opencode 명령어를 찾을 수 없는 경우

OpenCode 인스톨러는 `$SHELL` 환경변수로 셸을 감지해 PATH를 추가합니다. `dev-tools.sh`가 `#!/bin/bash`로 실행되면 `.bashrc`에 PATH가 추가되어 zsh에서 인식되지 않는 경우가 있습니다.

dev-tools.sh는 이 문제를 자동으로 수정합니다 (`~/.opencode/bin`을 `.zshrc`에 명시적으로 추가). 그래도 문제가 발생하면 수동으로 추가하세요:

```bash
echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
opencode
```

### Claude Code 설정이 복원되지 않는 경우

dev-tools.sh Stage 7에서 설정이 복원되려면 Windows 백업이 먼저 존재해야 합니다. 최초 설치 시에는 백업이 없으므로 설정 완료 후 수동으로 백업하세요:

```bash
bash claude-config.sh backup
```

MCP 서버 설정 복원에는 `jq`가 필요합니다. Stage 7에서 자동으로 설치하지만, 수동 복원 시에는 먼저 설치하세요:

```bash
sudo apt install -y jq
bash claude-config.sh restore
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
