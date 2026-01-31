#!/bin/bash
# notify.sh
# Claude Code Hooks 用の通知スクリプト
# 配置場所: ~/.claude/hooks/notify.sh

set -eo pipefail

# ===== 設定読み込み =====
# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/notify.conf"

# デフォルト設定（設定ファイルがない場合のフォールバック）
TERMINAL_APPS=(
  "Ghostty"
  "iTerm2"
  "Visual Studio Code"
  "Terminal"
)

# 設定ファイルが存在すれば読み込む
if [[ -f "$CONFIG_FILE" ]]; then
    # セキュリティ検証：設定ファイルの所有者が現在のユーザーであることを確認
    if [[ "$(stat -f '%u' "$CONFIG_FILE" 2>/dev/null || stat -c '%u' "$CONFIG_FILE" 2>/dev/null)" != "$(id -u)" ]]; then
        # 所有者不一致の場合はデフォルト設定を使用
        :
    else
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
    fi
fi

# ===== 通知処理 =====
# stdin からJSON を読み取り
input=$(cat)
# 各フィールドを抽出
cwd=$(echo "$input" | jq -r '.cwd // "Unknown"')
message=$(echo "$input" | jq -r '.message // "タスク完了"')
event=$(echo "$input" | jq -r '.hook_event_name // "Unknown"')
session_id=$(echo "$input" | jq -r '.session_id // ""' | cut -c1-8)
# プロジェクト名を取得
project=$(basename "$cwd")

# 通知を送信（変数を適切にクォート）
terminal-notifier -title "Claude Code [$project]" -subtitle "📁 $cwd" -message "$message" -group "${cwd}:${event}:${session_id}" -sound "default"

# ===== ウィンドウを最前面にする =====
bring_to_front() {
    local app_name="$1"
    osascript -e "tell application \"$app_name\" to activate" 2>/dev/null
}

# ターミナルアプリを検出して最前面にする
detect_and_activate() {
    # 設定の順番に pgrep で検索し、最初に見つかったアプリを最前面にする
    for app in "${TERMINAL_APPS[@]}"; do
        if pgrep -x "$app" > /dev/null || pgrep -f "$app" > /dev/null; then
            bring_to_front "$app"
            return 0
        fi
    done
    return 1
}

detect_and_activate
