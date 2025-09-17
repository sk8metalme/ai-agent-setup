#!/bin/bash

# Claude グローバル設定インストーラー
# ~/.claude/ にグローバル設定を配置

set -e

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# デフォルト値
REPO_URL="${REPO_URL:-https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main}"
CLAUDE_DIR="$HOME/.claude"

DRY_RUN=false
PLAN_MODE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --plan)
            DRY_RUN=true
            PLAN_MODE=true
            shift
            ;;
        *)
            echo "未対応のオプションです: $1" >&2
            exit 1
            ;;
    esac
done

PLAN_REPORT=()
PLAN_DIFFS=()

record_step() {
    if [[ "$DRY_RUN" == true ]]; then
        PLAN_REPORT+=("$1")
    fi
}

print_diff() {
    local target=$1
    local tmp=$2
    if [[ -f "$target" ]]; then
        diff_output=$(diff -u "$target" "$tmp" 2>/dev/null || true)
        if [[ -n "$diff_output" ]]; then
            PLAN_DIFFS+=("--- $target の差分 ---\n$diff_output")
        else
            PLAN_DIFFS+=("$target に変更はありません")
        fi
    else
        PLAN_DIFFS+=("新規作成予定: $target")
    fi
}

ensure_dir() {
    local dir=$1
    if [[ "$DRY_RUN" == true ]]; then
        record_step "ディレクトリ作成予定: $dir"
    else
        mkdir -p "$dir"
    fi
}

download_file() {
    local url=$1
    local dest=$2
    local label=$3

    record_step "$label を $dest に配置"

    if [[ "$DRY_RUN" == true ]]; then
        local tmp
        tmp=$(mktemp)
        if curl -fsSL "$url" -o "$tmp" 2>/dev/null; then
            print_diff "$dest" "$tmp"
            rm -f "$tmp"
        else
            PLAN_DIFFS+=("$label の取得に失敗しました: $url")
        fi
        return 0
    fi

    backup_if_exists "$dest"
    curl -fsSL "$url" -o "$dest" 2>/dev/null || {
        echo -e "${RED}❌ $label のダウンロードに失敗しました${NC}"
        exit 1
    }
}

# ロゴ表示
echo -e "${GREEN}"
cat << 'EOF'
  _____ _                 _        _____ _       _           _ 
 / ____| |               | |      / ____| |     | |         | |
| |    | | __ _ _   _  __| | ___ | |  __| | ___ | |__   __ _| |
| |    | |/ _` | | | |/ _` |/ _ \| | |_ | |/ _ \| '_ \ / _` | |
| |____| | (_| | |_| | (_| |  __/| |__| | | (_) | |_) | (_| | |
 \_____|_|\__,_|\__,_|\__,_|\___| \_____|_|\___/|_.__/ \__,_|_|
                                                              
EOF
echo -e "${NC}"

echo "🚀 Claude グローバル設定インストーラー"
echo ""

# バックアップ関数
backup_if_exists() {
    local file=$1
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        if [[ "$DRY_RUN" == true ]]; then
            record_step "バックアップ予定: $file -> $backup"
            return
        fi
        echo -e "${YELLOW}📋 既存ファイルをバックアップ: $backup${NC}"
        mv "$file" "$backup"
    fi
}

# ディレクトリ作成
echo "📁 ディレクトリ作成中..."
ensure_dir "$CLAUDE_DIR"
ensure_dir "$CLAUDE_DIR/base"
ensure_dir "$CLAUDE_DIR/team"
ensure_dir "$CLAUDE_DIR/security"
ensure_dir "$CLAUDE_DIR/languages"
ensure_dir "$CLAUDE_DIR/projects"

# 言語選択
echo ""
echo "📋 対応言語を選択してください:"
echo ""
echo "  1) Java + Spring Boot"
echo "  2) PHP"
echo "  3) Perl"
echo "  4) すべて"
echo ""

choice=${LANGUAGE_CHOICE:-}

if [[ -n "$choice" ]]; then
    echo "➡️  環境変数 LANGUAGE_CHOICE=$choice を使用します"
elif [[ -t 0 ]]; then
    read -rp "選択 (1-4) [デフォルト: 4]: " choice
fi

if [[ -z "$choice" ]]; then
    choice=4
    echo "ℹ️  非対話モードまたは未入力のため『すべて』を選択しました (LANGUAGE_CHOICE で変更可能)"
fi

# 基本設定のダウンロード
echo ""
echo "📥 基本設定をダウンロード中..."

# 基本設定
download_file "$REPO_URL/global-config/claude-import/base/CLAUDE-base.md" \
    "$CLAUDE_DIR/base/CLAUDE-base.md" "基本設定"

# チーム設定
download_file "$REPO_URL/global-config/claude-import/team/CLAUDE-team-standards.md" \
    "$CLAUDE_DIR/team/CLAUDE-team-standards.md" "チーム設定"

# セキュリティ設定
download_file "$REPO_URL/global-config/claude-import/security/CLAUDE-security-policy.md" \
    "$CLAUDE_DIR/security/CLAUDE-security-policy.md" "セキュリティ設定"

# 言語別設定のダウンロード
download_language_config() {
    local lang=$1
    local display_name=$2
    
    echo "📥 $display_name 設定をダウンロード中..."
    ensure_dir "$CLAUDE_DIR/languages/$lang"
    download_file "$REPO_URL/global-config/claude-import/languages/$lang/CLAUDE-$lang.md" \
        "$CLAUDE_DIR/languages/$lang/CLAUDE-$lang.md" "$display_name 設定"
}

generate_claude_main() {
cat <<'EOF'
# グローバルClaude設定

このファイルはグローバルなClaude設定です。

## 基本設定のインポート

@base/CLAUDE-base.md

## チーム標準のインポート

@team/CLAUDE-team-standards.md

## セキュリティポリシーのインポート

@security/CLAUDE-security-policy.md

## 言語別設定のインポート（必要に応じて選択）

<!-- 使用する言語のコメントを外してください -->

<!-- Java + Spring Boot -->
<!-- @languages/java-spring/CLAUDE-java-spring.md -->

<!-- PHP -->
<!-- @languages/php/CLAUDE-php.md -->

<!-- Perl -->
<!-- @languages/perl/CLAUDE-perl.md -->

---

注: このファイルは`@import`構文を使用して、複数の設定ファイルを組み合わせています。
プロジェクト固有の設定は、各プロジェクトのCLAUDE.mdファイルで定義してください。
EOF
}

case $choice in
    1)
        download_language_config "java-spring" "Java + Spring Boot"
        ;;
    2)
        download_language_config "php" "PHP"
        ;;
    3)
        download_language_config "perl" "Perl"
        ;;
    4)
        download_language_config "java-spring" "Java + Spring Boot"
        download_language_config "php" "PHP"
        download_language_config "perl" "Perl"
        ;;
    *)
        echo -e "${RED}無効な選択です${NC}"
        exit 1
        ;;
esac

# メインCLAUDE.mdファイルの作成
echo ""
echo "📝 メインCLAUDE.mdファイルを作成中..."

record_step "CLAUDE.md を $CLAUDE_DIR/CLAUDE.md に生成"

if [[ "$DRY_RUN" == true ]]; then
    tmp_main=$(mktemp)
    generate_claude_main > "$tmp_main"
    print_diff "$CLAUDE_DIR/CLAUDE.md" "$tmp_main"
    rm -f "$tmp_main"
else
    backup_if_exists "$CLAUDE_DIR/CLAUDE.md"
    generate_claude_main > "$CLAUDE_DIR/CLAUDE.md"
fi

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    echo "📝 プランモード: 以下の内容を実行予定です"
    printf ' - %s\n' "${PLAN_REPORT[@]}"
    if [[ ${#PLAN_DIFFS[@]} -gt 0 ]]; then
        echo ""
        for diff_entry in "${PLAN_DIFFS[@]}"; do
            echo -e "$diff_entry"
            echo ""
        done
    fi
    exit 0
fi

echo -e "${GREEN}✅ Claude グローバル設定のインストールが完了しました${NC}"
echo ""
echo "📍 インストール場所: $CLAUDE_DIR"
echo ""
echo "🚀 次のステップ:"
echo "   1. 必要に応じて言語設定のコメントを外す"
echo "   2. Claudeを再起動して設定を反映"
echo "   3. プロジェクト用設定は install-project.sh を使用"
echo ""
