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

# Claude設定選択
echo ""
echo "🤖 Claude設定を含めますか？:"
echo ""
echo "  1) Claude設定を含める（推奨）"
echo "  2) Cursor設定のみ"
echo ""

claude_choice=${PROJECT_CLAUDE_CHOICE:-}

if [[ -n "$claude_choice" ]]; then
    echo "➡️  環境変数 PROJECT_CLAUDE_CHOICE=$claude_choice を使用します"
elif [[ -t 0 ]]; then
    read -p "選択してください (1-2) [1]: " claude_choice
    claude_choice=${claude_choice:-1}
else
    claude_choice=1
    echo "ℹ️  非対話モードまたは未入力のため『Claude設定を含める』を選択しました (PROJECT_CLAUDE_CHOICE で変更可能)"
fi

# 言語選択
echo ""
echo "📋 対応言語を選択してください:"
echo ""
echo "  1) Java + Spring Boot"
echo "  2) PHP"
echo "  3) Perl"
echo "  4) Python"
echo "  5) すべて"
echo ""

lang_choice=${PROJECT_LANGUAGE_CHOICE:-}

if [[ -n "$lang_choice" ]]; then
    echo "➡️  環境変数 PROJECT_LANGUAGE_CHOICE=$lang_choice を使用します"
elif [[ -t 0 ]]; then
    read -rp "選択 (1-5) [デフォルト: 5]: " lang_choice
fi

if [[ -z "$lang_choice" ]]; then
    lang_choice=5
    echo "ℹ️  非対話モードまたは未入力のため『すべて』を選択しました (PROJECT_LANGUAGE_CHOICE で変更可能)"
fi

install_cursor_rules() {
    echo ""
    echo "📥 Cursor Project Rules をインストール中..."

    ensure_dir "$PROJECT_ROOT/.cursor/rules"

    download_file "$REPO_URL/.cursor/rules/general.mdc" \
        "$PROJECT_ROOT/.cursor/rules/general.mdc" "基本ルール"

    download_language_rule() {
        local lang=$1
        local display_name=$2
        echo "📥 $display_name ルールをダウンロード中..."
        download_file "$REPO_URL/.cursor/rules/$lang.mdc" \
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
            download_language_rule "python" "Python"
            ;;
        5)
            download_language_rule "java-spring" "Java Spring Boot"
            download_language_rule "php" "PHP"
            download_language_rule "perl" "Perl"
            download_language_rule "python" "Python"
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
    download_file "$REPO_URL/AGENTS.md" "$PROJECT_ROOT/AGENTS.md" "AGENTS.md"
    if [[ "$PLAN_MODE" != true ]]; then
        echo -e "${GREEN}✅ AGENTS.md のインストールが完了しました${NC}"
    fi
}

install_claude_settings() {
    echo ""
    echo "🤖 Claude設定をインストール中..."
    
    # .claudeディレクトリ作成
    mkdir -p "$PROJECT_ROOT/.claude"
    
    # Claude settings.json
    echo "📥 Claude settings.json をダウンロード中..."
    download_file "$REPO_URL/project-config/claude-settings/settings.json" "$PROJECT_ROOT/.claude/settings.json" "Claude settings.json"
    
    # Claude import設定
    echo "📥 Claude import設定をダウンロード中..."
    download_file "$REPO_URL/project-config/claude-import/CLAUDE.md" "$PROJECT_ROOT/.claude/CLAUDE.md" "Claude CLAUDE.md"
    
    # 基本設定
    mkdir -p "$PROJECT_ROOT/.claude/base"
    download_file "$REPO_URL/project-config/claude-import/base/CLAUDE-base.md" "$PROJECT_ROOT/.claude/base/CLAUDE-base.md" "Claude base設定"
    
    # セキュリティ・チーム設定
    mkdir -p "$PROJECT_ROOT/.claude/security" "$PROJECT_ROOT/.claude/team"
    download_file "$REPO_URL/project-config/claude-import/security/CLAUDE-security-policy.md" "$PROJECT_ROOT/.claude/security/CLAUDE-security-policy.md" "Claude セキュリティポリシー"
    download_file "$REPO_URL/project-config/claude-import/team/CLAUDE-team-standards.md" "$PROJECT_ROOT/.claude/team/CLAUDE-team-standards.md" "Claude チーム標準"
    
    # Jujutsu Skill
    echo "📥 Jujutsu Skillをダウンロード中..."
    mkdir -p "$PROJECT_ROOT/.claude/skills/jujutsu"
    download_file "$REPO_URL/.claude/skills/jujutsu/SKILL.md" "$PROJECT_ROOT/.claude/skills/jujutsu/SKILL.md" "Jujutsu Skill"
    
    # 言語Skills
    mkdir -p "$PROJECT_ROOT/.claude/skills"
    case $lang_choice in
        1)
            mkdir -p "$PROJECT_ROOT/.claude/skills/java-spring"
            download_file "$REPO_URL/.claude/skills/java-spring/SKILL.md" "$PROJECT_ROOT/.claude/skills/java-spring/SKILL.md" "Java Spring Boot Skill"
            ;;
        2)
            mkdir -p "$PROJECT_ROOT/.claude/skills/php"
            download_file "$REPO_URL/.claude/skills/php/SKILL.md" "$PROJECT_ROOT/.claude/skills/php/SKILL.md" "PHP Skill"
            ;;
        3)
            mkdir -p "$PROJECT_ROOT/.claude/skills/perl"
            download_file "$REPO_URL/.claude/skills/perl/SKILL.md" "$PROJECT_ROOT/.claude/skills/perl/SKILL.md" "Perl Skill"
            ;;
        4)
            mkdir -p "$PROJECT_ROOT/.claude/skills/python"
            download_file "$REPO_URL/.claude/skills/python/SKILL.md" "$PROJECT_ROOT/.claude/skills/python/SKILL.md" "Python Skill"
            ;;
        5)
            mkdir -p "$PROJECT_ROOT/.claude/skills/java-spring" "$PROJECT_ROOT/.claude/skills/php" "$PROJECT_ROOT/.claude/skills/perl" "$PROJECT_ROOT/.claude/skills/python"
            download_file "$REPO_URL/.claude/skills/java-spring/SKILL.md" "$PROJECT_ROOT/.claude/skills/java-spring/SKILL.md" "Java Spring Boot Skill"
            download_file "$REPO_URL/.claude/skills/php/SKILL.md" "$PROJECT_ROOT/.claude/skills/php/SKILL.md" "PHP Skill"
            download_file "$REPO_URL/.claude/skills/perl/SKILL.md" "$PROJECT_ROOT/.claude/skills/perl/SKILL.md" "Perl Skill"
            download_file "$REPO_URL/.claude/skills/python/SKILL.md" "$PROJECT_ROOT/.claude/skills/python/SKILL.md" "Python Skill"
            ;;
    esac
    
    if [[ "$PLAN_MODE" != true ]]; then
        echo -e "${GREEN}✅ Claude設定のインストールが完了しました${NC}"
        echo -e "${YELLOW}💡 設定ファイルの場所: $PROJECT_ROOT/.claude/${NC}"
        echo -e "${YELLOW}💡 チーム設定（reviewers, codeOwners）は実際の環境に合わせて調整してください${NC}"
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

# Claude設定インストール
if [[ "$claude_choice" == "1" ]]; then
    install_claude_settings
fi

# .gitignore設定チェック・追加
setup_gitignore_backup_exclusion() {
    echo ""
    echo "🔍 .gitignore設定をチェック中..."
    
    local gitignore_file="$PROJECT_ROOT/.gitignore"
    local backup_patterns_exist=false
    
    # .gitignoreファイルの存在確認
    if [[ -f "$gitignore_file" ]]; then
        # バックアップファイル除外設定の存在確認
        if grep -q "^\*\.backup\.\*" "$gitignore_file" 2>/dev/null; then
            backup_patterns_exist=true
            record_step ".gitignoreにバックアップファイル除外設定が既に存在"
            if [[ "$PLAN_MODE" != true ]]; then
                echo -e "${GREEN}✅ .gitignoreにバックアップファイル除外設定が既に存在します${NC}"
            fi
        fi
    fi
    
    # バックアップファイル除外設定が存在しない場合は追加
    if [[ "$backup_patterns_exist" == false ]]; then
        record_step ".gitignoreにバックアップファイル除外設定を追加"
        
        if [[ "$PLAN_MODE" == true ]]; then
            local tmp_gitignore=$(mktemp)
            if [[ -f "$gitignore_file" ]]; then
                cp "$gitignore_file" "$tmp_gitignore"
            fi
            
            cat >> "$tmp_gitignore" << 'EOF'

# Backup Files
# Exclude backup files created by install scripts
*.backup.*
*.bak
*~
.#*
#*#
EOF
            print_diff "$gitignore_file" "$tmp_gitignore"
            rm -f "$tmp_gitignore"
        else
            # .gitignoreファイルが存在しない場合は作成
            if [[ ! -f "$gitignore_file" ]]; then
                echo "📝 .gitignoreファイルを作成中..."
            else
                echo "📝 .gitignoreにバックアップファイル除外設定を追加中..."
            fi
            
            cat >> "$gitignore_file" << 'EOF'

# Backup Files
# Exclude backup files created by ai-agent-setup scripts
*.backup.*
*.bak
*~
.#*
#*#
EOF
            echo -e "${GREEN}✅ .gitignoreにバックアップファイル除外設定を追加しました${NC}"
            echo -e "${YELLOW}💡 以下のパターンが除外されます:${NC}"
            echo -e "${YELLOW}   - *.backup.* (インストールスクリプトのバックアップ)${NC}"
            echo -e "${YELLOW}   - *.bak (一般的なバックアップファイル)${NC}"
            echo -e "${YELLOW}   - *~ (エディタの一時ファイル)${NC}"
        fi
    fi
}

setup_gitignore_backup_exclusion

# プロジェクト用コマンドファイルのインストール
install_project_commands() {
    echo ""
    echo "📋 プロジェクト用コマンドファイルをインストール中..."
    
    # Claude用コマンドファイル
    local claude_commands_dir="$PROJECT_ROOT/.claude/commands"
    ensure_dir "$claude_commands_dir"
    
    record_step "Claudeコマンドファイルを $claude_commands_dir にダウンロード"
    
    local commands=("dev.md" "documentation.md" "plan.md" "suggest-claude-md.md")
    
    for cmd in "${commands[@]}"; do
        local cmd_url="$REPO_URL/.claude/commands/$cmd"
        local target_file="$claude_commands_dir/$cmd"
        
        if [[ "$PLAN_MODE" == true ]]; then
            tmp_cmd=$(mktemp)
            if curl -fsSL "$cmd_url" -o "$tmp_cmd" 2>/dev/null; then
                print_diff "$target_file" "$tmp_cmd"
            else
                echo "# $cmd（ダウンロード予定）" > "$tmp_cmd"
                print_diff "$target_file" "$tmp_cmd"
            fi
            rm -f "$tmp_cmd"
        else
            backup_if_exists "$target_file"
            download_file "$cmd_url" "$target_file" "$cmd"
        fi
    done
    
    # Cursor用コマンドファイル
    local cursor_commands_dir="$PROJECT_ROOT/.cursor/commands"
    ensure_dir "$cursor_commands_dir"
    
    record_step "Cursorコマンドファイルを $cursor_commands_dir にダウンロード"
    
    for cmd in "${commands[@]}"; do
        local cmd_url="$REPO_URL/.claude/commands/$cmd"
        local target_file="$cursor_commands_dir/$cmd"
        
        if [[ "$PLAN_MODE" == true ]]; then
            tmp_cmd=$(mktemp)
            if curl -fsSL "$cmd_url" -o "$tmp_cmd" 2>/dev/null; then
                print_diff "$target_file" "$tmp_cmd"
            else
                echo "# $cmd（ダウンロード予定）" > "$tmp_cmd"
                print_diff "$target_file" "$tmp_cmd"
            fi
            rm -f "$tmp_cmd"
        else
            backup_if_exists "$target_file"
            download_file "$cmd_url" "$target_file" "$cmd"
        fi
    done
    
    if [[ "$PLAN_MODE" != true ]]; then
        echo -e "${GREEN}✅ プロジェクト用コマンドファイルのインストールが完了しました${NC}"
        echo -e "${YELLOW}💡 Claudeコマンドファイル: $claude_commands_dir${NC}"
        echo -e "${YELLOW}💡 Cursorコマンドファイル: $cursor_commands_dir${NC}"
    fi
}

install_project_commands

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
if [[ "$claude_choice" == "1" ]]; then
    echo "   - Claude設定: $PROJECT_ROOT/.claude/"
    echo "     ├── settings.json          # Claude Desktop/Web設定"
    echo "     ├── CLAUDE.md              # Claude import設定"
    echo "     ├── commands/              # コマンドファイル"
    echo "     ├── base/                  # 基本設定"
    echo "     ├── skills/                # Skills（言語別・jujutsu）"
    echo "     ├── security/              # セキュリティポリシー"
    echo "     └── team/                  # チーム標準"
fi
echo "   - コマンドファイル:"
echo "     ├── $PROJECT_ROOT/.claude/commands/    # Claude用"
echo "     └── $PROJECT_ROOT/.cursor/commands/    # Cursor用"
echo ""
echo "🚀 次のステップ:"
echo "   1. 必要に応じて設定ファイルをカスタマイズ"
echo "   2. コマンドファイル（@dev, @documentation, @plan）を活用"
if [[ "$claude_choice" == "1" ]]; then
    echo "   3. Claude設定のチーム設定（reviewers, codeOwners）を調整"
    echo "   4. .gitignoreでバックアップファイルが除外されることを確認"
    echo "   5. Claudeを再起動して設定を反映"
    echo "   6. Cursorを再起動して設定を反映"
    echo "   7. グローバル設定は install-global.sh を使用"
else
    echo "   3. .gitignoreでバックアップファイルが除外されることを確認"
    echo "   4. Cursorを再起動して設定を反映"
    echo "   5. グローバル設定は install-global.sh を使用"
fi
echo ""
