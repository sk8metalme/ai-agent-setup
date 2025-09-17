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

# バックアップ関数
backup_if_exists() {
    local file=$1
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}📋 既存ファイルをバックアップ: $backup${NC}"
        mv "$file" "$backup"
    fi
}

# ロゴ表示
echo -e "${GREEN}"
cat << 'EOF'
 _____           _           _     _____             __ _       
|  _  |___ ___  |_|___ ___ _| |_  |     |___ ___ ___|__|_|___   
|   __|  _| . | | | -_|  _|  _|  |   --| . |   |  _|  | | . |
|__|  |_| |___|_| |___|___|_|    |_____|___|_|_|_|  |__|_|_  |
                |___|                                    |___|
EOF
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

# Cursor Project Rules のインストール
install_cursor_rules() {
    echo ""
    echo "📥 Cursor Project Rules をインストール中..."
    
    mkdir -p "$PROJECT_ROOT/.cursor/rules"
    
    # 基本ルール
    backup_if_exists "$PROJECT_ROOT/.cursor/rules/general.mdc"
    curl -fsSL "$REPO_URL/project-config/cursor-rules/general.mdc" \
        -o "$PROJECT_ROOT/.cursor/rules/general.mdc" 2>/dev/null || {
        echo -e "${RED}❌ 基本ルールのダウンロードに失敗しました${NC}"
        return 1
    }
    
    # 言語別ルール
    download_language_rule() {
        local lang=$1
        local display_name=$2

        echo "📥 $display_name ルールをダウンロード中..."
        backup_if_exists "$PROJECT_ROOT/.cursor/rules/$lang.mdc"
        curl -fsSL "$REPO_URL/project-config/cursor-rules/$lang.mdc" \
            -o "$PROJECT_ROOT/.cursor/rules/$lang.mdc" 2>/dev/null || {
            echo -e "${YELLOW}⚠️  $display_name ルールが見つかりません${NC}"
        }
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
    
    echo -e "${GREEN}✅ Cursor Project Rules のインストールが完了しました${NC}"
}

# AGENTS.md のインストール
install_agents_md() {
    echo ""
    echo "📥 AGENTS.md をインストール中..."
    
    backup_if_exists "$PROJECT_ROOT/AGENTS.md"
    curl -fsSL "$REPO_URL/project-config/AGENTS.md" \
        -o "$PROJECT_ROOT/AGENTS.md" 2>/dev/null || {
        echo -e "${RED}❌ AGENTS.mdのダウンロードに失敗しました${NC}"
        return 1
    }
    
    echo -e "${GREEN}✅ AGENTS.md のインストールが完了しました${NC}"
}

# 設定タイプに応じてインストール
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
