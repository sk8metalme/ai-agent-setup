#!/bin/bash
# guardrail-builder SessionEnd フックスクリプト
# 会話履歴を分析し、CLAUDE-guardrail.md に自動追記

set -euo pipefail

# ============================================================================
# 無限ループ対策
# ============================================================================
# 問題: SessionEndフック内でclaude実行 → またSessionEndフック発火 → 無限ループ
# 解決: 環境変数で「実行中」フラグを管理
if [ "${GUARDRAIL_BUILDER_RUNNING:-}" = "1" ]; then
    echo "Already running guardrail-builder-hook. Skipping." >&2
    exit 0
fi
export GUARDRAIL_BUILDER_RUNNING=1

# ============================================================================
# フック入力の読み込み
# ============================================================================
HOOK_INPUT=$(cat)

# デバッグ: フック入力全体をログ出力
mkdir -p "$HOME/.claude/logs"
DEBUG_LOG="$HOME/.claude/logs/guardrail-builder-debug-$(date +%Y%m%d-%H%M%S).json"
echo "$HOOK_INPUT" | jq '.' > "$DEBUG_LOG" 2>/dev/null || echo "$HOOK_INPUT" > "$DEBUG_LOG"
echo "Debug: フック入力を保存しました: $DEBUG_LOG" >&2

TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty')
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty')
HOOK_EVENT_NAME=$(echo "$HOOK_INPUT" | jq -r '.hook_event_name // "Unknown"')

# 入力検証
if [ -z "$TRANSCRIPT_PATH" ] || [ "$TRANSCRIPT_PATH" = "null" ]; then
    echo "Error: transcript_path not found" >&2
    echo "Debug log: $DEBUG_LOG" >&2
    exit 1
fi

# チルダ展開
TRANSCRIPT_PATH="${TRANSCRIPT_PATH/#\~/$HOME}"

if [ ! -f "$TRANSCRIPT_PATH" ]; then
    echo "Error: Transcript file not found: $TRANSCRIPT_PATH" >&2
    exit 1
fi

# ============================================================================
# プロジェクトルート検出
# ============================================================================
# 検出順序: 1) CLAUDE_PROJECT_DIR → 2) settings.json → 3) git root → 4) pwd

PROJECT_ROOT=""

# 1) CLAUDE_PROJECT_DIR 環境変数
if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    PROJECT_ROOT="${CLAUDE_PROJECT_DIR/#\~/$HOME}"
    if [ -d "$PROJECT_ROOT" ]; then
        echo "Using CLAUDE_PROJECT_DIR: $PROJECT_ROOT" >&2
    else
        PROJECT_ROOT=""
    fi
fi

# 2) ~/.claude/settings.json
if [ -z "$PROJECT_ROOT" ]; then
    SETTINGS_FILE="$HOME/.claude/settings.json"
    if [ -f "$SETTINGS_FILE" ]; then
        PROJECT_DIR_FROM_SETTINGS=$(jq -r '.project_dir // ""' "$SETTINGS_FILE" 2>/dev/null)
        if [ -n "$PROJECT_DIR_FROM_SETTINGS" ] && [ "$PROJECT_DIR_FROM_SETTINGS" != "null" ]; then
            PROJECT_DIR_FROM_SETTINGS="${PROJECT_DIR_FROM_SETTINGS/#\~/$HOME}"
            if [ -d "$PROJECT_DIR_FROM_SETTINGS" ]; then
                PROJECT_ROOT="$PROJECT_DIR_FROM_SETTINGS"
                echo "Using project_dir from settings.json: $PROJECT_ROOT" >&2
            fi
        fi
    fi
fi

# 3) git root
if [ -z "$PROJECT_ROOT" ]; then
    GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
    if [ -n "$GIT_ROOT" ] && [ -d "$GIT_ROOT" ]; then
        PROJECT_ROOT="$GIT_ROOT"
        echo "Using git root: $PROJECT_ROOT" >&2
    fi
fi

# 4) pwd
if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT="$(pwd)"
    echo "Using pwd: $PROJECT_ROOT" >&2
fi

# ============================================================================
# ログディレクトリ準備
# ============================================================================
LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/guardrail-builder-$(date +%Y%m%d-%H%M%S).log"

# ============================================================================
# バックグラウンド実行（新しいターミナルウィンドウ）
# ============================================================================
# osascript で新規ターミナル起動し、guardrail-builder スキル実行

# macOS でない場合はスキップ
if [ "$(uname)" != "Darwin" ]; then
    echo "Warning: macOS only. Skipping background execution." >&2
    exit 0
fi

# AppleScript でターミナル起動
osascript <<EOF
tell application "Terminal"
    do script "
        echo '======================================' | tee -a '$LOG_FILE'
        echo 'guardrail-builder: 会話履歴を分析中...' | tee -a '$LOG_FILE'
        echo '======================================' | tee -a '$LOG_FILE'
        echo '' | tee -a '$LOG_FILE'

        cd '$PROJECT_ROOT' || exit 1

        # 環境変数を引き継ぎ
        export GUARDRAIL_BUILDER_RUNNING=1

        # session_id を使用（Bash側で抽出済み）
        echo \"Session ID: $SESSION_ID\" | tee -a '$LOG_FILE'

        # Claude Code で --resume を使ってセッション再開し、スキルを実行
        if echo '/guardrail-builder' | claude --resume \"$SESSION_ID\" -p >> '$LOG_FILE' 2>&1; then
            echo '' | tee -a '$LOG_FILE'
            echo '✅ guardrail-builder: 完了' | tee -a '$LOG_FILE'

            # macOS 通知（成功）
            osascript -e 'display notification \"CLAUDE-guardrail.md を更新しました\" with title \"guardrail-builder\" sound name \"Glass\"'
        else
            echo '' | tee -a '$LOG_FILE'
            echo '❌ guardrail-builder: エラー' | tee -a '$LOG_FILE'

            # macOS 通知（エラー）
            osascript -e 'display notification \"更新に失敗しました。ログを確認してください\" with title \"guardrail-builder\" sound name \"Basso\"'
        fi

        echo '' | tee -a '$LOG_FILE'
        echo 'ログ: $LOG_FILE' | tee -a '$LOG_FILE'
        echo '' | tee -a '$LOG_FILE'
        echo 'Press Enter to close...'
        read
    "
end tell
EOF

echo "guardrail-builder started in background. Log: $LOG_FILE" >&2
