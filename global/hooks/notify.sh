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
TERM_PROGRAM_MAP=(
  "ghostty:Ghostty"
  "iTerm.app:iTerm"
  "vscode:Visual Studio Code"
  "Apple_Terminal:Terminal"
)

PARENT_PROCESS_MAP=(
  "*ghostty*:Ghostty"
  "*iTerm*:iTerm"
  "*Code*:Visual Studio Code"
  "*code*:Visual Studio Code"
  "*Terminal*:Terminal"
)

PGREP_FALLBACK=(
  "ghostty:Ghostty"
  "iTerm2:iTerm"
  "Visual Studio Code:Visual Studio Code"
  "Code:Visual Studio Code"
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

# 方法1: TERM_PROGRAM 環境変数から検出
detect_from_term_program() {
    [[ -z "$TERM_PROGRAM" ]] && return 1

    for mapping in "${TERM_PROGRAM_MAP[@]}"; do
        local term_value="${mapping%%:*}"
        local app_name="${mapping##*:}"
        if [[ "$TERM_PROGRAM" == "$term_value" ]]; then
            bring_to_front "$app_name"
            return 0
        fi
    done
    return 1
}

# 方法2: 親プロセス名から検出（ワイルドカード対応）
detect_from_parent_process() {
    local ppid_check=$$
    for _ in {1..10}; do
        ppid_check=$(ps -o ppid= -p "$ppid_check" 2>/dev/null | tr -d ' ')
        [[ -z "$ppid_check" || "$ppid_check" == "1" ]] && break

        local pname=$(ps -o comm= -p "$ppid_check" 2>/dev/null)
        for mapping in "${PARENT_PROCESS_MAP[@]}"; do
            local pattern="${mapping%%:*}"
            local app_name="${mapping##*:}"
            # ワイルドカードパターンマッチング
            if [[ "$pname" == $pattern ]]; then
                bring_to_front "$app_name"
                return 0
            fi
        done
    done
    return 1
}

# 方法3: pgrep フォールバック（設定順に試行）
detect_from_pgrep() {
    for mapping in "${PGREP_FALLBACK[@]}"; do
        local pgrep_pattern="${mapping%%:*}"
        local app_name="${mapping##*:}"
        if pgrep -x "$pgrep_pattern" > /dev/null || pgrep -f "$pgrep_pattern" > /dev/null; then
            bring_to_front "$app_name"
            return 0
        fi
    done
    return 1
}

# Claude Codeを実行中のアプリを自動検出
detect_and_activate() {
    detect_from_term_program && return
    detect_from_parent_process && return
    detect_from_pgrep
}

detect_and_activate
