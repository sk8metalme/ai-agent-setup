#!/bin/bash

# グローバル設定（CLAUDE.md、hooks）をインストールするスクリプト
# プラグインで配布できない設定をリポジトリから ~/.claude/ へコピーします

set -e

BACKUP_DIR="$HOME/.claude_backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GLOBAL_DIR="$SCRIPT_DIR/global"

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# バックアップ関数
backup_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    mkdir -p "$BACKUP_DIR"
    local basename=$(basename "$file")
    cp "$file" "$BACKUP_DIR/${basename}.${TIMESTAMP}.bak"
    echo -e "${YELLOW}Backed up:${NC} $file → $BACKUP_DIR/${basename}.${TIMESTAMP}.bak"
  fi
}

# ファイルコピー
copy_files() {
  echo -e "${GREEN}Copying files from $GLOBAL_DIR to $CLAUDE_DIR...${NC}"
  echo ""

  # CLAUDE.md
  backup_file "$CLAUDE_DIR/CLAUDE.md"
  cp "$GLOBAL_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
  echo "✓ Copied CLAUDE.md"

  # CLAUDE-*.md
  for dir in base security team; do
    mkdir -p "$CLAUDE_DIR/$dir"
    for file in "$GLOBAL_DIR/$dir"/*.md; do
      if [[ -f "$file" ]]; then
        local basename=$(basename "$file")
        backup_file "$CLAUDE_DIR/$dir/$basename"
        cp "$file" "$CLAUDE_DIR/$dir/"
        echo "✓ Copied $dir/$basename"
      fi
    done
  done

  # hooks
  mkdir -p "$CLAUDE_DIR/hooks"
  for file in "$GLOBAL_DIR/hooks"/*; do
    if [[ -f "$file" ]]; then
      local basename=$(basename "$file")
      backup_file "$CLAUDE_DIR/hooks/$basename"
      cp "$file" "$CLAUDE_DIR/hooks/"
      [[ "$file" == *.sh ]] && chmod +x "$CLAUDE_DIR/hooks/$basename"
      echo "✓ Copied hooks/$basename"
    fi
  done
}

# settings.json設定
setup_settings_json() {
  echo ""
  echo -e "${GREEN}Setting up settings.json...${NC}"
  backup_file "$CLAUDE_DIR/settings.json"

  local hooks_config='{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/notify.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/protect-branch.sh"
          }
        ]
      }
    ]
  }
}'

  if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
    # jqでマージ
    if command -v jq &> /dev/null; then
      echo "$hooks_config" | jq -s '.[0] * .[1]' "$CLAUDE_DIR/settings.json" - > /tmp/settings_merged.json
      mv /tmp/settings_merged.json "$CLAUDE_DIR/settings.json"
      echo "✓ Merged hooks configuration into settings.json"
    else
      echo -e "${YELLOW}Warning: jq not found. Please manually add hooks to settings.json${NC}"
      echo "Hooks configuration:"
      echo "$hooks_config"
    fi
  else
    echo "$hooks_config" > "$CLAUDE_DIR/settings.json"
    echo "✓ Created settings.json with hooks configuration"
  fi
}

# メイン処理
main() {
  echo ""
  echo "==================================="
  echo "  グローバル設定セットアップ"
  echo "==================================="
  echo ""

  if [[ ! -d "$GLOBAL_DIR" ]]; then
    echo -e "${YELLOW}Error: global/ directory not found${NC}"
    echo "Please run this script from the ai-agent-setup repository root."
    exit 1
  fi

  copy_files
  setup_settings_json

  echo ""
  echo "==================================="
  echo "  セットアップ完了"
  echo "==================================="
  echo ""
  if [[ -d "$BACKUP_DIR" ]]; then
    echo -e "${YELLOW}Backups:${NC} $BACKUP_DIR/"
    echo ""
  fi
  echo -e "${GREEN}インストールされたファイル:${NC}"
  echo "  - $CLAUDE_DIR/CLAUDE.md"
  echo "  - $CLAUDE_DIR/base/CLAUDE-base.md"
  echo "  - $CLAUDE_DIR/security/CLAUDE-security-policy.md"
  echo "  - $CLAUDE_DIR/team/CLAUDE-team-standards.md"
  echo "  - $CLAUDE_DIR/hooks/notify.sh"
  echo "  - $CLAUDE_DIR/hooks/protect-branch.sh"
  echo "  - $CLAUDE_DIR/hooks/protect-branch.conf"
  echo "  - $CLAUDE_DIR/settings.json (hooks設定追加)"
  echo ""
}

main "$@"
