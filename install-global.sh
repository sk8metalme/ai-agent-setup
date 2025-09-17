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
REPO_URL="https://raw.githubusercontent.com/arigatatsuya/ai-agent-setup/main"
CLAUDE_DIR="$HOME/.claude"

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
        echo -e "${YELLOW}📋 既存ファイルをバックアップ: $backup${NC}"
        mv "$file" "$backup"
    fi
}

# ディレクトリ作成
echo "📁 ディレクトリ作成中..."
mkdir -p "$CLAUDE_DIR"/{base,team,security,languages,projects}

# 言語選択
echo ""
echo "📋 対応言語を選択してください:"
echo ""
echo "  1) Java + Spring Boot"
echo "  2) PHP"
echo "  3) Perl"
echo "  4) すべて"
echo ""
read -p "選択 (1-4): " choice

# 基本設定のダウンロード
echo ""
echo "📥 基本設定をダウンロード中..."

# 基本設定
curl -fsSL "$REPO_URL/global-config/claude-import/base/CLAUDE-base.md" \
    -o "$CLAUDE_DIR/base/CLAUDE-base.md" 2>/dev/null || {
    echo -e "${RED}❌ 基本設定のダウンロードに失敗しました${NC}"
    exit 1
}

# チーム設定
curl -fsSL "$REPO_URL/global-config/claude-import/team/CLAUDE-team-standards.md" \
    -o "$CLAUDE_DIR/team/CLAUDE-team-standards.md" 2>/dev/null || {
    echo -e "${RED}❌ チーム設定のダウンロードに失敗しました${NC}"
    exit 1
}

# セキュリティ設定
curl -fsSL "$REPO_URL/global-config/claude-import/security/CLAUDE-security-policy.md" \
    -o "$CLAUDE_DIR/security/CLAUDE-security-policy.md" 2>/dev/null || {
    echo -e "${RED}❌ セキュリティ設定のダウンロードに失敗しました${NC}"
    exit 1
}

# 言語別設定のダウンロード
download_language_config() {
    local lang=$1
    local display_name=$2
    
    echo "📥 $display_name 設定をダウンロード中..."
    mkdir -p "$CLAUDE_DIR/languages/$lang"
    
    curl -fsSL "$REPO_URL/global-config/claude-import/languages/$lang/CLAUDE-$lang.md" \
        -o "$CLAUDE_DIR/languages/$lang/CLAUDE-$lang.md" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  $display_name 設定のダウンロードに失敗しました${NC}"
    }
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

cat > "$CLAUDE_DIR/CLAUDE.md" << 'EOF'
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

echo -e "${GREEN}✅ Claude グローバル設定のインストールが完了しました${NC}"
echo ""
echo "📍 インストール場所: $CLAUDE_DIR"
echo ""
echo "🚀 次のステップ:"
echo "   1. 必要に応じて言語設定のコメントを外す"
echo "   2. Claudeを再起動して設定を反映"
echo "   3. プロジェクト用設定は install-project.sh を使用"
echo ""
