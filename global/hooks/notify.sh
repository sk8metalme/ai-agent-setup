#!/bin/bash
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

# Claude Codeを実行中のアプリを自動検出
detect_and_activate() {
    # 方法1: TERM_PROGRAM 環境変数から検出（Claude Codeから継承される場合）
    if [[ -n "$TERM_PROGRAM" ]]; then
        case "$TERM_PROGRAM" in
            "iTerm.app")
                bring_to_front "iTerm"
                return
                ;;
            "vscode")
                bring_to_front "Visual Studio Code"
                return
                ;;
            "Apple_Terminal")
                bring_to_front "Terminal"
                return
                ;;
        esac
    fi
    
    # 方法2: 親プロセスから検出
    local ppid_check=$$
    for _ in {1..10}; do
        ppid_check=$(ps -o ppid= -p "$ppid_check" 2>/dev/null | tr -d ' ')
        [[ -z "$ppid_check" || "$ppid_check" == "1" ]] && break
        
        local pname=$(ps -o comm= -p "$ppid_check" 2>/dev/null)
        case "$pname" in
            *iTerm*)
                bring_to_front "iTerm"
                return
                ;;
            *Code*|*code*)
                bring_to_front "Visual Studio Code"
                return
                ;;
            *Terminal*)
                bring_to_front "Terminal"
                return
                ;;
        esac
    done
    
    # 方法3: フォールバック - 実行中のアプリを優先順位で検出
    if pgrep -x "iTerm2" > /dev/null; then
        bring_to_front "iTerm"
    elif pgrep -f "Visual Studio Code" > /dev/null || pgrep -x "Code" > /dev/null; then
        bring_to_front "Visual Studio Code"
    fi
}

detect_and_activate
