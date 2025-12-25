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

# 通知を送信
terminal-notifier -title "Claude Code [$project]" -subtitle "📁 $cwd" -message "$message" -group "$cwd:$event" -sound "default"
