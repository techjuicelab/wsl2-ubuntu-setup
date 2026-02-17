# WSL2 Ubuntu Setup

Windows 11 WSL2 환경에서 Ubuntu 개발 환경을 자동으로 구성하는 셋업 스크립트입니다.

## 포함 도구

| 도구 | 버전 | 설명 |
|------|------|------|
| Zsh | 최신 | 기본 쉘 |
| Oh My Zsh | 최신 | Zsh 프레임워크 |
| Powerlevel10k | 최신 | Zsh 테마 |
| zsh-autosuggestions | 최신 | 명령어 자동 제안 |
| zsh-syntax-highlighting | 최신 | 명령어 구문 강조 |
| zsh-completions | 최신 | 추가 자동완성 |
| fzf | 최신 | 퍼지 파인더 |
| asdf | v0.18.0 | 런타임 버전 관리자 |

---

## 사전 준비

### 1. Windows에서 WSL2 설치

관리자 권한 PowerShell에서 실행:

```powershell
wsl --install -d Ubuntu-24.04
```

설치 중 Unix 사용자 이름과 비밀번호를 설정합니다.

### 2. SSH 키 준비 (최초 1회)

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

# 3. 셋업 스크립트 실행
cd dotfiles
chmod +x setup.sh
./setup.sh

# 4. Zsh 진입 (Powerlevel10k 설정 마법사 시작)
zsh

# 5. 설치 확인
asdf --version   # v0.18.0
fzf --version
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
wsl --export Ubuntu-24.04 "C:\Users\techjuice\Documents\dev\wsl-base.tar"
```

### 2. 원하는 이름으로 복제

```powershell
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
```

PowerShell에서 재시작:

```powershell
wsl --shutdown
wsl -d Ubuntu-Dev
```

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

## asdf 사용법 (v0.18.0)

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
    │   ├── setup.sh
    │   └── README.md
    ├── .oh-my-zsh/              # Oh My Zsh
    ├── .ssh/                    # SSH 키 (setup.sh가 자동 복원)
    ├── .local/bin/asdf          # asdf 바이너리
    ├── .asdf/                   # asdf 데이터 (플러그인, 버전)
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

### setup.sh 실행 중 에러가 나는 경우

```bash
# 로그 확인 후 실패 지점부터 다시 실행
./setup.sh
```

이미 설치된 항목은 git clone이 실패할 수 있습니다. 완전히 초기화하려면:

```bash
rm -rf ~/.oh-my-zsh ~/.fzf ~/.asdf ~/.local/bin/asdf
./setup.sh
```

### p10k 설정 마법사 다시 실행

```bash
p10k configure
```
