#!/bin/bash
set -e

WIN_CONFIG="/mnt/c/Users/techjuice/Documents/dev/.claude-config"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_JSON="$HOME/.claude.json"

usage() {
  echo "Claude Code 설정 백업/복원 스크립트"
  echo ""
  echo "사용법:"
  echo "  bash claude-config.sh backup   — 설정을 Windows 호스트에 백업"
  echo "  bash claude-config.sh restore  — Windows 백업에서 설정 복원"
  echo ""
  echo "백업 대상:"
  echo "  ~/.claude/settings.json        — 전역 설정"
  echo "  ~/.claude/commands/            — SuperClaude 스킬 + 커스텀 명령어"
  echo "  ~/.claude/plugins/             — 스킬 마켓플레이스 + 설치된 스킬"
  echo "  ~/.claude.json (mcpServers)    — MCP 서버 설정만 추출"
  echo ""
  echo "백업 경로: $WIN_CONFIG"
  exit 1
}

if [ $# -eq 0 ]; then
  usage
fi

# Windows 공유 경로 확인
if [ ! -d "/mnt/c/Users/techjuice" ]; then
  echo "오류: Windows 공유 경로(/mnt/c/Users/techjuice)에 접근할 수 없습니다."
  exit 1
fi

backup() {
  echo "=== Claude Code 설정 백업 ==="

  mkdir -p "$WIN_CONFIG"

  local backed_up=false

  # settings.json 백업
  if [ -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$CLAUDE_DIR/settings.json" "$WIN_CONFIG/settings.json"
    echo "백업 완료: settings.json"
    backed_up=true
  else
    echo "건너뜀: ~/.claude/settings.json 없음"
  fi

  # commands/ 백업
  if [ -d "$CLAUDE_DIR/commands" ]; then
    rm -rf "$WIN_CONFIG/commands"
    cp -r "$CLAUDE_DIR/commands" "$WIN_CONFIG/commands"
    echo "백업 완료: commands/"
    backed_up=true
  else
    echo "건너뜀: ~/.claude/commands/ 없음"
  fi

  # plugins/ 백업 (마켓플레이스 + 설치된 스킬)
  if [ -d "$CLAUDE_DIR/plugins" ] && [ -f "$CLAUDE_DIR/plugins/installed_plugins.json" ]; then
    rm -rf "$WIN_CONFIG/plugins"
    cp -r "$CLAUDE_DIR/plugins" "$WIN_CONFIG/plugins"
    echo "백업 완료: plugins/ (마켓플레이스 + 설치된 스킬)"
    backed_up=true
  else
    echo "건너뜀: ~/.claude/plugins/ 없음 또는 설치된 스킬 없음"
  fi

  # MCP 서버 설정 백업 (mcpServers 키만 추출)
  if [ -f "$CLAUDE_JSON" ]; then
    if ! command -v jq &> /dev/null; then
      echo "경고: jq가 설치되지 않아 MCP 설정을 백업할 수 없습니다."
      echo "  sudo apt install -y jq 후 다시 시도하세요."
    else
      local mcp_servers
      mcp_servers=$(jq '.mcpServers // empty' "$CLAUDE_JSON" 2>/dev/null)
      if [ -n "$mcp_servers" ] && [ "$mcp_servers" != "null" ]; then
        jq '{mcpServers: .mcpServers}' "$CLAUDE_JSON" > "$WIN_CONFIG/mcp-servers.json"
        echo "백업 완료: mcp-servers.json (mcpServers만 추출)"
        backed_up=true
      else
        echo "건너뜀: ~/.claude.json에 mcpServers 없음"
      fi
    fi
  else
    echo "건너뜀: ~/.claude.json 없음"
  fi

  echo ""
  if [ "$backed_up" = true ]; then
    echo "백업 위치: $WIN_CONFIG"
    ls -la "$WIN_CONFIG"
  else
    echo "백업할 설정 파일이 없습니다. Claude Code를 먼저 설정하세요."
  fi
}

restore() {
  echo "=== Claude Code 설정 복원 ==="

  if [ ! -d "$WIN_CONFIG" ]; then
    echo "백업이 없습니다: $WIN_CONFIG"
    echo "먼저 'bash claude-config.sh backup'으로 백업하세요."
    exit 1
  fi

  local restored=false

  # settings.json 복원
  if [ -f "$WIN_CONFIG/settings.json" ]; then
    mkdir -p "$CLAUDE_DIR"
    cp "$WIN_CONFIG/settings.json" "$CLAUDE_DIR/settings.json"
    echo "복원 완료: settings.json → ~/.claude/settings.json"
    restored=true
  else
    echo "건너뜀: 백업에 settings.json 없음"
  fi

  # commands/ 복원
  if [ -d "$WIN_CONFIG/commands" ]; then
    mkdir -p "$CLAUDE_DIR"
    rm -rf "$CLAUDE_DIR/commands"
    cp -r "$WIN_CONFIG/commands" "$CLAUDE_DIR/commands"
    echo "복원 완료: commands/ → ~/.claude/commands/"
    restored=true
  else
    echo "건너뜀: 백업에 commands/ 없음"
  fi

  # plugins/ 복원 (마켓플레이스 + 설치된 스킬)
  if [ -d "$WIN_CONFIG/plugins" ]; then
    mkdir -p "$CLAUDE_DIR"
    rm -rf "$CLAUDE_DIR/plugins"
    cp -r "$WIN_CONFIG/plugins" "$CLAUDE_DIR/plugins"
    echo "복원 완료: plugins/ → ~/.claude/plugins/"
    restored=true
  else
    echo "건너뜀: 백업에 plugins/ 없음"
  fi

  # MCP 서버 설정 복원 (mcpServers 키만 merge)
  if [ -f "$WIN_CONFIG/mcp-servers.json" ]; then
    if ! command -v jq &> /dev/null; then
      echo "경고: jq가 설치되지 않아 MCP 설정을 복원할 수 없습니다."
      echo "  sudo apt install -y jq 후 다시 시도하세요."
    else
      if [ -f "$CLAUDE_JSON" ]; then
        # 기존 파일에 mcpServers 키만 merge (auth 데이터 보존)
        local backup_mcp
        backup_mcp=$(jq '.mcpServers' "$WIN_CONFIG/mcp-servers.json")
        jq --argjson mcp "$backup_mcp" '.mcpServers = $mcp' "$CLAUDE_JSON" > "${CLAUDE_JSON}.tmp"
        mv "${CLAUDE_JSON}.tmp" "$CLAUDE_JSON"
        echo "복원 완료: mcpServers → ~/.claude.json (기존 설정에 merge)"
      else
        # 파일이 없으면 새로 생성
        cp "$WIN_CONFIG/mcp-servers.json" "$CLAUDE_JSON"
        echo "복원 완료: mcp-servers.json → ~/.claude.json (새로 생성)"
      fi
      restored=true
    fi
  else
    echo "건너뜀: 백업에 mcp-servers.json 없음"
  fi

  echo ""
  if [ "$restored" = true ]; then
    echo "설정 복원이 완료되었습니다."
  else
    echo "복원할 설정 파일이 없습니다."
  fi
}

case "$1" in
  backup)
    backup
    ;;
  restore)
    restore
    ;;
  *)
    usage
    ;;
esac
