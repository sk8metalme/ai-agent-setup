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

# バックアップディレクトリ初期化（一度だけ実行）
init_backup_dir() {
  if [[ ! -d "$BACKUP_DIR" ]]; then
    mkdir -p "$BACKUP_DIR"
  fi
}

# バックアップ関数
backup_file() {
  local file="$1"
  [[ ! -f "$file" ]] && return 0

  local basename=$(basename "$file")
  if cp "$file" "$BACKUP_DIR/${basename}.${TIMESTAMP}.bak"; then
    echo -e "${YELLOW}Backed up:${NC} $file → $BACKUP_DIR/${basename}.${TIMESTAMP}.bak"
  else
    echo -e "${YELLOW}Warning: バックアップに失敗: $file${NC}" >&2
    return 1
  fi
}

# 単一ファイルコピー（バックアップ付き）
copy_single_file() {
  local src="$1"
  local dest="$2"
  local display_name="$3"

  backup_file "$dest"
  cp "$src" "$dest"
  echo "✓ Copied $display_name"
}

# Markdownファイルをコピー
copy_md_files() {
  # CLAUDE.md
  copy_single_file "$GLOBAL_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" "CLAUDE.md"

  # サブディレクトリ内のCLAUDE-*.md
  for dir in base security team; do
    mkdir -p "$CLAUDE_DIR/$dir"
    for file in "$GLOBAL_DIR/$dir"/*.md; do
      [[ ! -f "$file" ]] && continue
      local basename=$(basename "$file")
      copy_single_file "$file" "$CLAUDE_DIR/$dir/$basename" "$dir/$basename"
    done
  done
}

# Hookファイルをコピー
copy_hook_files() {
  mkdir -p "$CLAUDE_DIR/hooks"

  for file in "$GLOBAL_DIR/hooks"/*; do
    [[ ! -f "$file" ]] && continue

    local basename=$(basename "$file")

    # 空ファイルはスキップ
    if [[ ! -s "$file" ]]; then
      echo -e "${YELLOW}Warning: 空ファイルをスキップ: $file${NC}" >&2
      continue
    fi

    if ! copy_single_file "$file" "$CLAUDE_DIR/hooks/$basename" "hooks/$basename" 2>/dev/null; then
      echo -e "${YELLOW}Warning: コピーに失敗: $file${NC}" >&2
      continue
    fi

    # シェルスクリプトに実行権限を付与
    if [[ "$file" == *.sh ]]; then
      chmod +x "$CLAUDE_DIR/hooks/$basename" 2>/dev/null || \
        echo -e "${YELLOW}Warning: 実行権限の付与に失敗: $basename${NC}" >&2
    fi
  done
}

# ファイルコピー（メイン）
copy_files() {
  echo -e "${GREEN}Copying files from $GLOBAL_DIR to $CLAUDE_DIR...${NC}"
  echo ""

  copy_md_files
  copy_hook_files
}

# statusLine 依存ツールの確認
check_statusline_deps() {
  local missing=0

  echo ""

  # ccstatusline の確認
  if ! command -v ccstatusline &> /dev/null && ! npm list -g ccstatusline &> /dev/null 2>&1; then
    echo "  - ccstatusline: npm install -g ccstatusline"
    missing=1
  fi

  if [ $missing -eq 1 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  上記ツールをインストールすると statusLine が有効になります${NC}"
  else
    echo -e "${GREEN}✓ statusLine 依存ツール確認完了${NC}"
  fi
}

# settings.json設定
setup_settings_json() {
  echo ""
  echo -e "${GREEN}Setting up settings.json...${NC}"

  local template="$GLOBAL_DIR/settings.template.json"
  local settings="$CLAUDE_DIR/settings.json"

  # settings.template.json が存在するか確認
  if [[ ! -f "$template" ]]; then
    echo -e "${YELLOW}Warning: settings.template.json が見つかりません${NC}"
    return 1
  fi

  if [[ -f "$settings" ]]; then
    # 既存ファイルにマージ
    if ! command -v jq &> /dev/null; then
      echo -e "${YELLOW}Warning: jq がインストールされていません。手動でマージしてください${NC}"
      return 1
    fi

    backup_file "$settings"

    local temp_file
    temp_file=$(mktemp) || { echo -e "${YELLOW}Error: 一時ファイル作成に失敗${NC}" >&2; return 1; }

    if jq -s '.[0] * .[1]' "$template" "$settings" > "$temp_file" 2>/dev/null && mv "$temp_file" "$settings"; then
      echo "✓ Merged common settings into settings.json"
    else
      rm -f "$temp_file"
      echo -e "${YELLOW}Error: マージに失敗しました${NC}" >&2
      return 1
    fi
  else
    # 新規作成
    cp "$template" "$settings"
    echo "✓ Created settings.json from settings.template.json"
  fi

  # settings.local.example.json を初回のみコピー
  local example="$GLOBAL_DIR/settings.local.example.json"
  if [[ -f "$example" && ! -f "$CLAUDE_DIR/settings.local.example.json" ]]; then
    cp "$example" "$CLAUDE_DIR/settings.local.example.json"
    echo "✓ Copied settings.local.example.json"
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
    echo -e "${YELLOW}Error: global/ ディレクトリが見つかりません${NC}"
    echo "ai-agent-setup リポジトリのルートから実行してください。"
    exit 1
  fi

  init_backup_dir
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
  echo "  - $CLAUDE_DIR/hooks/statusline.sh"
  echo "  - $CLAUDE_DIR/settings.json (共通設定をマージ)"
  echo "  - $CLAUDE_DIR/settings.local.example.json (環境依存設定サンプル)"
  echo "  - $CLAUDE_DIR/templates/ (テンプレート)"
  echo "  - $HOME/.secrets/ (秘密情報ディレクトリ)"
  echo ""
}

main "$@"
