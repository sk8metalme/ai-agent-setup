#!/bin/bash

# プロジェクト用設定インストーラー
# Cursor Project Rules (.mdc) と AGENTS.md をプロジェクトに配置

set -e

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# デフォルト値
REPO_URL="${REPO_URL:-https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main}"
PROJECT_ROOT="${PROJECT_ROOT:-.}"

PLAN_MODE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --plan)
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
    if [[ "$PLAN_MODE" == true ]]; then
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

backup_if_exists() {
    local file=$1
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        if [[ "$PLAN_MODE" == true ]]; then
            record_step "バックアップ予定: $file -> $backup"
            return
        fi
        echo -e "${YELLOW}📋 既存ファイルをバックアップ: $backup${NC}"
        mv "$file" "$backup"
    fi
}

ensure_dir() {
    local dir=$1
    if [[ "$PLAN_MODE" == true ]]; then
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

    if [[ "$PLAN_MODE" == true ]]; then
        # PLAN_MODE: Download to temp file and show diff
        local tmp
        tmp=$(mktemp)
        # Ensure temp file is always cleaned up
        trap "rm -f '$tmp'" EXIT
        
        if curl -fsSL "$url" -o "$tmp" 2>/dev/null; then
            print_diff "$dest" "$tmp"
            rm -f "$tmp"
            trap - EXIT  # Remove trap after successful cleanup
        else
            PLAN_DIFFS+=("$label の取得に失敗しました: $url")
            rm -f "$tmp"
            trap - EXIT  # Remove trap after cleanup
        fi
        return 0
    fi

    # Real execution: backup and download
    backup_if_exists "$dest"
    curl -fsSL "$url" -o "$dest" 2>/dev/null || {
        echo -e "${RED}❌ $label のダウンロードに失敗しました${NC}"
        exit 1
    }
}

# ロゴ表示
echo -e "${GREEN}"
cat << 'EOF_BANNER'
 _____           _           _     _____             __ _       
|  _  |___ ___  |_|___ ___ _| |_  |     |___ ___ ___|__|_|___   
|   __|  _| . | | | -_|  _|  _|  |   --| . |   |  _|  | | . |
|__|  |_| |___|_| |___|___|_|    |_____|___|_|_|_|  |__|_|_  |
                |___|                                    |___|
EOF_BANNER
echo -e "${NC}"

echo "🚀 プロジェクト用設定インストーラー"
echo ""

# 設定タイプ選択
echo "📋 設定タイプを選択してください:"
echo ""
echo "  1) Cursor Project Rules (.mdc)"
echo "  2) AGENTS.md (シンプル)"
echo "  3) 両方"
echo ""

config_type=${PROJECT_CONFIG_TYPE:-}

if [[ -n "$config_type" ]]; then
    echo "➡️  環境変数 PROJECT_CONFIG_TYPE=$config_type を使用します"
elif [[ -t 0 ]]; then
    read -rp "選択 (1-3) [デフォルト: 3]: " config_type
fi

if [[ -z "$config_type" ]]; then
    config_type=3
    echo "ℹ️  非対話モードまたは未入力のため『両方』を選択しました (PROJECT_CONFIG_TYPE で変更可能)"
fi

# 言語選択
echo ""
echo "📋 対応言語を選択してください:"
echo ""
echo "  1) Java + Spring Boot"
echo "  2) PHP"
echo "  3) Perl"
echo "  4) すべて"
echo ""

lang_choice=${PROJECT_LANGUAGE_CHOICE:-}

if [[ -n "$lang_choice" ]]; then
    echo "➡️  環境変数 PROJECT_LANGUAGE_CHOICE=$lang_choice を使用します"
elif [[ -t 0 ]]; then
    read -rp "選択 (1-4) [デフォルト: 4]: " lang_choice
fi

if [[ -z "$lang_choice" ]]; then
    lang_choice=4
    echo "ℹ️  非対話モードまたは未入力のため『すべて』を選択しました (PROJECT_LANGUAGE_CHOICE で変更可能)"
fi

install_cursor_rules() {
    echo ""
    echo "📥 Cursor Project Rules をインストール中..."

    ensure_dir "$PROJECT_ROOT/.cursor/rules"

    download_file "$REPO_URL/project-config/cursor-rules/general.mdc" \
        "$PROJECT_ROOT/.cursor/rules/general.mdc" "基本ルール"

    download_language_rule() {
        local lang=$1
        local display_name=$2
        echo "📥 $display_name ルールをダウンロード中..."
        download_file "$REPO_URL/project-config/cursor-rules/$lang.mdc" \
            "$PROJECT_ROOT/.cursor/rules/$lang.mdc" "$display_name ルール"
    }

    case $lang_choice in
        1)
            download_language_rule "java-spring" "Java Spring Boot"
            ;;
        2)
            download_language_rule "php" "PHP"
            ;;
        3)
            download_language_rule "perl" "Perl"
            ;;
        4)
            download_language_rule "java-spring" "Java Spring Boot"
            download_language_rule "php" "PHP"
            download_language_rule "perl" "Perl"
            ;;
        *)
            echo -e "${RED}無効な選択です${NC}"
            return 1
            ;;
    esac

    if [[ "$PLAN_MODE" != true ]]; then
        echo -e "${GREEN}✅ Cursor Project Rules のインストールが完了しました${NC}"
    fi
}

install_agents_md() {
    echo ""
    echo "📥 AGENTS.md をインストール中..."
    download_file "$REPO_URL/project-config/AGENTS.md" "$PROJECT_ROOT/AGENTS.md" "AGENTS.md"
    if [[ "$PLAN_MODE" != true ]]; then
        echo -e "${GREEN}✅ AGENTS.md のインストールが完了しました${NC}"
    fi
}

case $config_type in
    1)
        install_cursor_rules
        ;;
    2)
        install_agents_md
        ;;
    3)
        install_cursor_rules
        install_agents_md
        ;;
    *)
        echo -e "${RED}無効な選択です${NC}"
        exit 1
        ;;
esac

if [[ "$PLAN_MODE" == true ]]; then
    echo ""
    echo "📝 プランモード: 実行内容のプレビュー"
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

echo ""
echo "🎉 プロジェクト用設定のインストールが完了しました！"
echo ""
echo "📍 インストール場所:"
if [[ $config_type == "1" ]] || [[ $config_type == "3" ]]; then
    echo "   - Cursor Rules: $PROJECT_ROOT/.cursor/rules/"
fi
if [[ $config_type == "2" ]] || [[ $config_type == "3" ]]; then
    echo "   - AGENTS.md: $PROJECT_ROOT/AGENTS.md"
fi
echo ""
echo "🚀 次のステップ:"
echo "   1. 必要に応じて設定ファイルをカスタマイズ"
echo "   2. Cursorを再起動して設定を反映"
echo "   3. グローバル設定は install-global.sh を使用"
echo ""
