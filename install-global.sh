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
        if [[ "$PLAN_MODE" == true ]]; then
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
ensure_dir "$CLAUDE_DIR/skills"
ensure_dir "$CLAUDE_DIR/agents"
ensure_dir "$CLAUDE_DIR/projects"

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

choice=${LANGUAGE_CHOICE:-}

if [[ -n "$choice" ]]; then
    echo "➡️  環境変数 LANGUAGE_CHOICE=$choice を使用します"
elif [[ -t 0 ]]; then
    read -rp "選択 (1-5) [デフォルト: 5]: " choice
fi

if [[ -z "$choice" ]]; then
    choice=5
    echo "ℹ️  非対話モードまたは未入力のため『すべて』を選択しました (LANGUAGE_CHOICE で変更可能)"
fi

# 基本設定のダウンロード
echo ""
echo "📥 基本設定をダウンロード中..."

# 基本設定
download_file "$REPO_URL/.claude/base/CLAUDE-base.md" \
    "$CLAUDE_DIR/base/CLAUDE-base.md" "基本設定"

# チーム設定
download_file "$REPO_URL/.claude/team/CLAUDE-team-standards.md" \
    "$CLAUDE_DIR/team/CLAUDE-team-standards.md" "チーム設定"

# セキュリティ設定
download_file "$REPO_URL/.claude/security/CLAUDE-security-policy.md" \
    "$CLAUDE_DIR/security/CLAUDE-security-policy.md" "セキュリティ設定"

# Jujutsu Skill
echo "📥 Jujutsu Skillをダウンロード中..."
ensure_dir "$CLAUDE_DIR/skills/jujutsu"
download_file "$REPO_URL/.claude/skills/jujutsu/SKILL.md" \
    "$CLAUDE_DIR/skills/jujutsu/SKILL.md" "Jujutsu Skill"

# CI/CD Skill
echo "📥 CI/CD Skillをダウンロード中..."
ensure_dir "$CLAUDE_DIR/skills/ci-cd"
download_file "$REPO_URL/.claude/skills/ci-cd/SKILL.md" \
    "$CLAUDE_DIR/skills/ci-cd/SKILL.md" "CI/CD Skill"

# OSS License Skill
echo "📥 OSS License Skillをダウンロード中..."
ensure_dir "$CLAUDE_DIR/skills/oss-license"
download_file "$REPO_URL/.claude/skills/oss-license/SKILL.md" \
    "$CLAUDE_DIR/skills/oss-license/SKILL.md" "OSS License Skill"

# Stable Version Skill
echo "📥 Stable Version Skillをダウンロード中..."
ensure_dir "$CLAUDE_DIR/skills/stable-version"
download_file "$REPO_URL/.claude/skills/stable-version/SKILL.md" \
    "$CLAUDE_DIR/skills/stable-version/SKILL.md" "Stable Version Skill"

# E2E First Planning Skill
echo "📥 E2E First Planning Skillをダウンロード中..."
ensure_dir "$CLAUDE_DIR/skills/e2e-first-planning"
download_file "$REPO_URL/.claude/skills/e2e-first-planning/SKILL.md" \
    "$CLAUDE_DIR/skills/e2e-first-planning/SKILL.md" "E2E First Planning Skill"

# Design Review Skill
echo "📥 Design Review Skillをダウンロード中..."
ensure_dir "$CLAUDE_DIR/skills/design-review"
download_file "$REPO_URL/.claude/skills/design-review/SKILL.md" \
    "$CLAUDE_DIR/skills/design-review/SKILL.md" "Design Review Skill"

# サブエージェントのダウンロード
download_agent() {
    local agent=$1
    local display_name=$2

    echo "📥 $display_name エージェントをダウンロード中..."
    ensure_dir "$CLAUDE_DIR/agents/$agent"
    download_file "$REPO_URL/.claude/agents/$agent/AGENT.md" \
        "$CLAUDE_DIR/agents/$agent/AGENT.md" "$display_name Agent"
}

# PR Resolver エージェント
download_agent "pr-resolver" "PR Resolver"

# OSS License Checker エージェント
download_agent "oss-license-checker" "OSS License Checker"

# Stable Version Auditor エージェント
download_agent "stable-version-auditor" "Stable Version Auditor"

# E2E First Planner エージェント
download_agent "e2e-first-planner" "E2E First Planner"

# Design Reviewer エージェント
download_agent "design-reviewer" "Design Reviewer"

# 言語別Skillsのダウンロード
download_skill() {
    local lang=$1
    local display_name=$2

    echo "📥 $display_name Skillをダウンロード中..."
    ensure_dir "$CLAUDE_DIR/skills/$lang"
    download_file "$REPO_URL/.claude/skills/$lang/SKILL.md" \
        "$CLAUDE_DIR/skills/$lang/SKILL.md" "$display_name Skill"
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

## バージョン管理

### Jujutsuプロジェクトの場合

以下の条件でjujutsu-workflowスキルを使用してください：
- `.jj/` ディレクトリが存在する場合
- `jj` コマンドを使用する場合
- PR作成やブックマーク管理を行う場合

スキル呼び出し: `/jujutsu-workflow`

## 言語別開発支援

### Java + Spring Boot開発の場合

以下の条件でjava-springスキルを使用してください：
- `.java` ファイルが存在する場合
- `pom.xml` または `build.gradle` が存在する場合
- Spring Boot関連の実装を行う場合

スキル呼び出し: `/java-spring`

### Python開発の場合

以下の条件でpython-devスキルを使用してください：
- `.py` ファイルが存在する場合
- `requirements.txt` または `pyproject.toml` が存在する場合
- Python関連の実装を行う場合

スキル呼び出し: `/python-dev`

### PHP開発の場合

以下の条件でphp-devスキルを使用してください：
- `.php` ファイルが存在する場合
- `composer.json` が存在する場合
- PHP関連の実装を行う場合

スキル呼び出し: `/php-dev`

### Perl開発の場合

以下の条件でperl-devスキルを使用してください：
- `.pl` または `.pm` ファイルが存在する場合
- Perl関連の実装を行う場合

スキル呼び出し: `/perl-dev`

---

注: このファイルは`@import`構文を使用して、複数の設定ファイルを組み合わせています。
プロジェクト固有の設定は、各プロジェクトのCLAUDE.mdファイルで定義してください。
EOF
}

case $choice in
    1)
        download_skill "java-spring" "Java + Spring Boot"
        ;;
    2)
        download_skill "php" "PHP"
        ;;
    3)
        download_skill "perl" "Perl"
        ;;
    4)
        download_skill "python" "Python"
        ;;
    5)
        download_skill "java-spring" "Java + Spring Boot"
        download_skill "php" "PHP"
        download_skill "perl" "Perl"
        download_skill "python" "Python"
        ;;
    *)
        echo -e "${RED}無効な選択です${NC}"
        exit 1
        ;;
esac

# Claude設定ファイルのインストール
echo ""
echo "⚙️ Claude設定ファイルをインストール中..."

install_claude_settings() {
    local settings_url="$REPO_URL/.claude/settings.json"
    local target_file="$CLAUDE_DIR/settings.json"
    
    record_step "Claude設定ファイルを $target_file にダウンロード"
    
    if [[ "$PLAN_MODE" == true ]]; then
        tmp_settings=$(mktemp)
        if curl -fsSL "$settings_url" -o "$tmp_settings" 2>/dev/null; then
            print_diff "$target_file" "$tmp_settings"
        else
            echo "# Claude設定ファイル（ダウンロード予定）" > "$tmp_settings"
            print_diff "$target_file" "$tmp_settings"
        fi
        rm -f "$tmp_settings"
        return
    fi
    
    backup_if_exists "$target_file"
    
    if download_file "$settings_url" "$target_file" "Claude設定ファイル"; then
        echo -e "${GREEN}✅ Claude設定ファイルのインストールが完了しました${NC}"
        echo -e "${YELLOW}💡 設定ファイルの場所: $target_file${NC}"
        echo -e "${YELLOW}💡 チーム設定（reviewers, codeOwners）は実際の環境に合わせて調整してください${NC}"
    else
        echo -e "${RED}❌ Claude設定ファイルのダウンロードに失敗しました${NC}"
    fi
}

install_claude_settings

# Claudeコマンドファイルのインストール
echo ""
echo "📋 Claudeコマンドファイルをインストール中..."

install_claude_commands() {
    local commands_dir="$CLAUDE_DIR/commands"
    ensure_dir "$commands_dir"
    
    record_step "Claudeコマンドファイルを $commands_dir にダウンロード"
    
    local commands=("dev.md" "documentation.md" "plan.md")
    
    for cmd in "${commands[@]}"; do
        local cmd_url="$REPO_URL/.claude/commands/$cmd"
        local target_file="$commands_dir/$cmd"
        
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
        echo -e "${GREEN}✅ Claudeコマンドファイルのインストールが完了しました${NC}"
        echo -e "${YELLOW}💡 コマンドファイルの場所: $commands_dir${NC}"
    fi
}

install_claude_commands

# Cursorコマンドファイルのインストール
echo ""
echo "📋 Cursorコマンドファイルをインストール中..."

install_cursor_commands() {
    local cursor_commands_dir="$HOME/.cursor/commands"
    ensure_dir "$cursor_commands_dir"
    
    record_step "Cursorコマンドファイルを $cursor_commands_dir にダウンロード"
    
    local commands=("dev.md" "documentation.md" "plan.md")
    
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
        echo -e "${GREEN}✅ Cursorコマンドファイルのインストールが完了しました${NC}"
        echo -e "${YELLOW}💡 コマンドファイルの場所: $cursor_commands_dir${NC}"
    fi
}

install_cursor_commands

# Clineルールのインストール
echo ""
echo "📋 Clineルールをインストール中..."

install_cline_rules() {
    local cline_rules_dir="$HOME/Documents/Cline/Rules"
    local project_cline_dir=".clinerules"

    ensure_dir "$cline_rules_dir"
    ensure_dir "$project_cline_dir"

    record_step "Clineルールを $cline_rules_dir と $project_cline_dir にダウンロード"

    local mdc_files=(
        "general.mdc"
        "jujutsu.mdc"
        "java-spring.mdc"
        "php.mdc"
        "python.mdc"
        "perl.mdc"
        "database.mdc"
    )

    for mdc in "${mdc_files[@]}"; do
        local basename="${mdc%.mdc}"
        local source_url="$REPO_URL/.cursor/rules/$mdc"
        local target_md="$basename.md"

        if [[ "$PLAN_MODE" == true ]]; then
            local tmp_mdc=$(mktemp)
            local tmp_md=$(mktemp)
            if curl -fsSL "$source_url" -o "$tmp_mdc" 2>/dev/null; then
                # frontmatterを削除（最初の2つの --- で囲まれた部分をスキップ）
                # count: --- の出現回数をカウント
                # skip: frontmatter内部かどうかのフラグ（count<=2の間はスキップ）
                awk 'BEGIN{skip=0; count=0} /^---$/{count++; if(count<=2){skip=!skip; next}} !skip' "$tmp_mdc" > "$tmp_md"

                # 出力が空でないか確認（malformed fileの検出）
                if [[ ! -s "$tmp_md" ]]; then
                    PLAN_DIFFS+=("⚠️  Warning: $basename の処理結果が空です（frontmatterが不正な可能性）")
                fi

                # グローバルルール
                print_diff "$cline_rules_dir/$target_md" "$tmp_md"

                # プロジェクトルール
                print_diff "$project_cline_dir/$target_md" "$tmp_md"
            else
                PLAN_DIFFS+=("$basename のダウンロードに失敗しました: $source_url")
            fi
            rm -f "$tmp_mdc" "$tmp_md"
        else
            local tmp_mdc=$(mktemp)
            if curl -fsSL "$source_url" -o "$tmp_mdc" 2>/dev/null; then
                # frontmatterを削除してグローバルルールに配置
                # 最初の2つの --- で囲まれた部分（YAML frontmatter）をスキップ
                backup_if_exists "$cline_rules_dir/$target_md"
                awk 'BEGIN{skip=0; count=0} /^---$/{count++; if(count<=2){skip=!skip; next}} !skip' "$tmp_mdc" > "$cline_rules_dir/$target_md"

                # 出力が空でないか確認（malformed fileの検出）
                if [[ ! -s "$cline_rules_dir/$target_md" ]]; then
                    echo -e "${YELLOW}⚠️  Warning: $basename の処理結果が空です（frontmatterが不正な可能性）${NC}"
                fi

                # frontmatterを削除してプロジェクトルールに配置
                backup_if_exists "$project_cline_dir/$target_md"
                awk 'BEGIN{skip=0; count=0} /^---$/{count++; if(count<=2){skip=!skip; next}} !skip' "$tmp_mdc" > "$project_cline_dir/$target_md"

                # 出力が空でないか確認
                if [[ ! -s "$project_cline_dir/$target_md" ]]; then
                    echo -e "${YELLOW}⚠️  Warning: $basename の処理結果が空です（frontmatterが不正な可能性）${NC}"
                fi
            else
                echo -e "${RED}❌ $basename のダウンロードに失敗しました${NC}"
            fi
            rm -f "$tmp_mdc"
        fi
    done

    if [[ "$PLAN_MODE" != true ]]; then
        echo -e "${GREEN}✅ Clineルールのインストールが完了しました${NC}"
        echo -e "${YELLOW}💡 グローバルルール: $cline_rules_dir${NC}"
        echo -e "${YELLOW}💡 プロジェクトルール: $project_cline_dir${NC}"
    fi
}

install_cline_rules

# メインCLAUDE.mdファイルの作成
echo ""
echo "📝 メインCLAUDE.mdファイルを作成中..."

record_step "CLAUDE.md を $CLAUDE_DIR/CLAUDE.md に生成"

if [[ "$PLAN_MODE" == true ]]; then
    tmp_main=$(mktemp)
    generate_claude_main > "$tmp_main"
    print_diff "$CLAUDE_DIR/CLAUDE.md" "$tmp_main"
    rm -f "$tmp_main"
else
    backup_if_exists "$CLAUDE_DIR/CLAUDE.md"
    generate_claude_main > "$CLAUDE_DIR/CLAUDE.md"
fi

if [[ "$PLAN_MODE" == true ]]; then
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
echo "   ├── CLAUDE.md              # メイン設定ファイル"
echo "   ├── settings.json          # Claude Desktop/Web設定"
echo "   ├── commands/              # コマンドファイル"
echo "   ├── base/                  # 基本設定"
echo "   ├── skills/                # Skills（言語別・jujutsu・ci-cd・oss-license・stable-version・e2e-first-planning・design-review）"
echo "   ├── agents/                # Agents（pr-resolver・oss-license-checker・stable-version-auditor・e2e-first-planner・design-reviewer）"
echo "   ├── security/              # セキュリティポリシー"
echo "   └── team/                  # チーム標準"
echo ""
echo "📍 Cursor用コマンドファイル: $HOME/.cursor/commands/"
echo "   ├── dev.md                 # 開発コマンド"
echo "   ├── documentation.md       # ドキュメント化コマンド"
echo "   └── plan.md                # 計画コマンド"
echo ""
echo "📍 Cline用ルールファイル: $HOME/Documents/Cline/Rules/"
echo "   ├── general.md             # 全般ルール"
echo "   ├── jujutsu.md             # Jujutsuルール（SSOT）"
echo "   ├── java-spring.md         # Java Spring"
echo "   ├── php.md                 # PHP"
echo "   ├── python.md              # Python"
echo "   ├── perl.md                # Perl"
echo "   └── database.md            # DB設計"
echo ""
echo "📍 Cline用プロジェクトルール: .clinerules/"
echo "   └── （上記と同じ7ファイル）"
echo ""
echo "🚀 次のステップ:"
echo "   1. 必要に応じて言語設定のコメントを外す"
echo "   2. settings.jsonのチーム設定を実際の環境に合わせて調整"
echo "   3. コマンドファイル（@dev, @documentation, @plan）を活用"
echo "   4. Claudeを再起動して設定を反映"
echo "   5. Cline（VSCode拡張機能）をインストールして使用"
echo "   6. プロジェクト用設定は install-project.sh を使用"
echo ""
echo "⚙️ Claude設定ファイル:"
echo "   - 場所: $CLAUDE_DIR/settings.json"
echo "   - 内容: セキュリティ、権限、Git統合、チーム設定"
echo "   - カスタマイズ: reviewers, codeOwners等を調整してください"
echo ""
echo "🤖 Cline設定:"
echo "   - グローバルルール: $HOME/Documents/Cline/Rules/"
echo "   - プロジェクトルール: .clinerules/"
echo "   - 参考: https://docs.cline.bot/features/cline-rules"
echo ""
