#!/bin/bash
# protect-branch.sh
# Claude Code Hooks 用の保護ブランチガードスクリプト
# 配置場所: ~/.claude/hooks/protect-branch.sh

# -u を削除（未設定変数でエラー終了しない）
set -eo pipefail

# デバッグモード（1でログ出力有効化）
DEBUG="${DEBUG:-0}"
DEBUG_LOG="${HOME}/.claude/hooks/protect-branch.log"

log_debug() {
    if [[ "$DEBUG" -eq 1 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$DEBUG_LOG"
    fi
}

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/protect-branch.conf"

# デフォルト設定
PROTECTED_BRANCHES="main|master|develop"
DANGEROUS_OPS="git commit|git push|git merge"
BLOCK_MESSAGE="保護ブランチへの直接操作は禁止です。新しいブランチを作成してください。"

# 設定ファイルが存在すれば読み込む
if [[ -f "$CONFIG_FILE" ]]; then
    # セキュリティ検証：設定ファイルの所有者が現在のユーザーであることを確認
    if [[ "$(stat -f '%u' "$CONFIG_FILE" 2>/dev/null || stat -c '%u' "$CONFIG_FILE" 2>/dev/null)" != "$(id -u)" ]]; then
        log_debug "WARNING: Config file owner mismatch, skipping load"
    else
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
    fi
fi

log_debug "Hook started"
log_debug "CLAUDE_TOOL_INPUT: ${CLAUDE_TOOL_INPUT:-NOT_SET}"

# CLAUDE_TOOL_INPUT が未設定または空の場合は許可
tool_input="${CLAUDE_TOOL_INPUT:-}"
if [[ -z "$tool_input" ]]; then
    log_debug "CLAUDE_TOOL_INPUT not set, allowing"
    exit 0
fi

# 正規表現パターンを構築
BRANCH_PATTERN="^(${PROTECTED_BRANCHES})$"
OPS_PATTERN="(${DANGEROUS_OPS})"

log_debug "OPS_PATTERN: $OPS_PATTERN"

# 現在のブランチを取得（Git リポジトリ外の場合は空）
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
log_debug "Current branch: ${current_branch:-NONE}"

# Git リポジトリ外の場合は許可
if [[ -z "$current_branch" ]]; then
    log_debug "Not in git repo, allowing"
    exit 0
fi

# 保護ブランチかチェック
if echo "$current_branch" | grep -qE "$BRANCH_PATTERN"; then
    log_debug "On protected branch: $current_branch"
    # 危険な操作かチェック
    if echo "$tool_input" | grep -qE "$OPS_PATTERN"; then
        log_debug "BLOCKED: $tool_input on protected branch $current_branch"
        echo "BLOCK: ${BLOCK_MESSAGE}" >&2
        echo "現在のブランチ: ${current_branch}" >&2
        echo "実行しようとした操作: ${tool_input}" >&2
        exit 1
    else
        log_debug "Operation not in dangerous list, allowing"
    fi
else
    log_debug "Not on protected branch, allowing"
fi

# 条件に該当しなければ許可
log_debug "Hook completed, allowing operation"
exit 0
