#!/bin/bash
# Claude回答完了時の通知スクリプト
# Claude Codeが回答を完了した際にmacOS通知を表示します
#
# 設定:
# - 通知方法: terminal-notifier（推奨）またはosascript（フォールバック）
# - プロジェクト名を通知に表示
# - 通知音: 環境変数 CLAUDE_NOTIFY_SOUND で制御（デフォルト: Glass）
# - 音声通知: 環境変数 CLAUDE_NOTIFY_VOICE で制御（デフォルト: 有効）
#
# インストール:
# このスクリプトは install-global.sh によって自動的に ~/.claude/hooks/ に配置されます

# JSON入力を読み込み（将来の拡張用に保持）
# shellcheck disable=SC2034
read -r json_input

# プロジェクト名を取得
project_name=$(basename "$CLAUDE_PROJECT_DIR")

# 通知メッセージ
NOTIFICATION_TITLE="Claude Code"
NOTIFICATION_SUBTITLE="プロジェクト: $project_name"
NOTIFICATION_MESSAGE="回答が完了しました"

# 通知音（環境変数で制御可能）
NOTIFICATION_SOUND="${CLAUDE_NOTIFY_SOUND:-Glass}"

# terminal-notifierが利用可能かチェック
if command -v terminal-notifier &> /dev/null; then
    # terminal-notifierを使用（高機能版）
    terminal-notifier \
        -title "$NOTIFICATION_TITLE" \
        -subtitle "$NOTIFICATION_SUBTITLE" \
        -message "$NOTIFICATION_MESSAGE" \
        -sound "$NOTIFICATION_SOUND" \
        -group "claude-code"
else
    # osascriptにフォールバック（標準版）
    osascript -e "display notification \"$NOTIFICATION_MESSAGE\" with title \"$NOTIFICATION_TITLE\" subtitle \"$NOTIFICATION_SUBTITLE\""
fi

# 音声通知（環境変数で制御可能）
# CLAUDE_NOTIFY_VOICE=false を設定すると無効化できます
if [[ "${CLAUDE_NOTIFY_VOICE:-true}" == "true" ]]; then
    say "Claude の回答が完了しました"
fi

exit 0
