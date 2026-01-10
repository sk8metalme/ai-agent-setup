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
    if ! cp "$file" "$BACKUP_DIR/${basename}.${TIMESTAMP}.bak"; then
      echo -e "${YELLOW}Warning: Failed to backup $file${NC}" >&2
      return 1
    fi
    echo -e "${YELLOW}Backed up:${NC} $file → $BACKUP_DIR/${basename}.${TIMESTAMP}.bak"
  fi
  return 0
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

      # ファイルの整合性を確認（空ファイルでないこと）
      if [[ ! -s "$file" ]]; then
        echo -e "${YELLOW}Warning: Skipping empty file $file${NC}" >&2
        continue
      fi

      backup_file "$CLAUDE_DIR/hooks/$basename"

      if ! cp "$file" "$CLAUDE_DIR/hooks/"; then
        echo -e "${YELLOW}Warning: Failed to copy $file${NC}" >&2
        continue
      fi

      # .shファイルのみchmod +xを実行（検証済み）
      if [[ "$file" == *.sh ]]; then
        if ! chmod +x "$CLAUDE_DIR/hooks/$basename"; then
          echo -e "${YELLOW}Warning: Failed to make $basename executable${NC}" >&2
        fi
      fi

      echo "✓ Copied hooks/$basename"
    fi
  done
}

# statusLine 依存ツールの確認
check_statusline_deps() {
  local missing_deps=()

  # bun の確認
  if ! command -v bun &> /dev/null; then
    missing_deps+=("bun")
  fi

  # ccusage の確認
  if ! command -v ccusage &> /dev/null && ! npm list -g ccusage &> /dev/null 2>&1; then
    missing_deps+=("ccusage")
  fi

  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  statusLine に必要なツールがインストールされていません:${NC}"
    for dep in "${missing_deps[@]}"; do
      case $dep in
        bun)
          echo "  - bun: curl -fsSL https://bun.sh/install | bash"
          ;;
        ccusage)
          echo "  - ccusage: npm install -g ccusage"
          ;;
      esac
    done
    echo ""
    echo "インストール後、statusLine が正常に動作します。"
    echo "スキップする場合、statusLine は無効になります。"
  else
    echo -e "${GREEN}✓ statusLine 依存ツール確認完了${NC}"
  fi
}

# settings.json設定
setup_settings_json() {
  echo ""
  echo -e "${GREEN}Setting up settings.json...${NC}"
  backup_file "$CLAUDE_DIR/settings.json"

  # settings.template.json が存在するか確認
  if [[ ! -f "$GLOBAL_DIR/settings.template.json" ]]; then
    echo -e "${YELLOW}Warning: settings.template.json not found. Skipping common settings merge.${NC}"
    return 1
  fi

  if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
    # jqでマージ
    if command -v jq &> /dev/null; then
      # 安全な一時ファイルを作成
      local temp_file
      temp_file=$(mktemp) || {
        echo -e "${YELLOW}Error: Failed to create temporary file${NC}" >&2
        return 1
      }

      # settings.template.json を既存の settings.json にマージ（深いマージ）
      if jq -s '.[0] * .[1]' "$CLAUDE_DIR/settings.json" "$GLOBAL_DIR/settings.template.json" > "$temp_file" 2>/dev/null; then
        # マージ成功：元のファイルを置き換え
        if mv "$temp_file" "$CLAUDE_DIR/settings.json"; then
          echo "✓ Merged common settings into settings.json"
        else
          echo -e "${YELLOW}Error: Failed to update settings.json${NC}" >&2
          rm -f "$temp_file"
          return 1
        fi
      else
        # jqマージ失敗：一時ファイルを削除
        echo -e "${YELLOW}Error: jq merge failed. settings.json was not modified${NC}" >&2
        rm -f "$temp_file"
        return 1
      fi
    else
      echo -e "${YELLOW}Warning: jq not found. Please manually merge settings.template.json${NC}"
      return 1
    fi
  else
    # settings.json が存在しない場合は template.json をコピー
    cp "$GLOBAL_DIR/settings.template.json" "$CLAUDE_DIR/settings.json"
    echo "✓ Created settings.json from settings.template.json"
  fi

  # settings.local.example.json を初回のみコピー（上書きしない）
  if [[ -f "$GLOBAL_DIR/settings.local.example.json" ]] && [[ ! -f "$CLAUDE_DIR/settings.local.example.json" ]]; then
    cp "$GLOBAL_DIR/settings.local.example.json" "$CLAUDE_DIR/settings.local.example.json"
    echo "✓ Copied settings.local.example.json (customize as needed)"
  fi
}

# 秘密情報セットアップ
setup_secrets() {
  echo ""
  echo -e "${GREEN}Setting up secrets management...${NC}"

  # ~/.secrets/ ディレクトリ作成
  if [[ ! -d "$HOME/.secrets" ]]; then
    mkdir -p "$HOME/.secrets"
    chmod 700 "$HOME/.secrets"
    echo "✓ Created ~/.secrets/ directory (permission: 700)"
  else
    echo "✓ ~/.secrets/ directory already exists"
    # パーミッション確認と修正
    local current_perm=$(stat -f "%p" "$HOME/.secrets" 2>/dev/null || stat -c "%a" "$HOME/.secrets" 2>/dev/null)
    if [[ "${current_perm: -3}" != "700" ]]; then
      chmod 700 "$HOME/.secrets"
      echo "✓ Fixed ~/.secrets/ permission to 700"
    fi
  fi

  # templates/ ディレクトリコピー（オプション）
  if [[ -d "$GLOBAL_DIR/templates" ]]; then
    mkdir -p "$CLAUDE_DIR/templates"
    cp -r "$GLOBAL_DIR/templates/"* "$CLAUDE_DIR/templates/" 2>/dev/null || true
    echo "✓ Copied templates to ~/.claude/templates/"
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
  check_statusline_deps
  setup_settings_json
  setup_secrets

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
  echo "  - $CLAUDE_DIR/hooks/protect-secrets.sh (秘密情報保護)"
  echo "  - $CLAUDE_DIR/hooks/protect-secrets.conf"
  echo "  - $CLAUDE_DIR/settings.json (共通設定をマージ)"
  echo "  - $CLAUDE_DIR/settings.local.example.json (環境依存設定サンプル)"
  echo "  - $CLAUDE_DIR/templates/ (テンプレート)"
  echo "  - $HOME/.secrets/ (秘密情報ディレクトリ)"
  echo ""
}

main "$@"
