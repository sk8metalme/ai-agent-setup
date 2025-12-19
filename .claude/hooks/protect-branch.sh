#!/bin/bash
# protect-branch.sh
# Claude Code Hooks 用の保護ブランチガードスクリプト
# 配置場所: ~/.claude/hooks/protect-branch.sh

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/protect-branch.conf"

# デフォルト設定
PROTECTED_BRANCHES="main|master|develop"
DANGEROUS_OPS="git commit|git push|git merge"
BLOCK_MESSAGE="保護ブランチへの直接操作は禁止です。新しいブランチを作成してください。"

# 設定ファイルが存在すれば読み込む
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

# 正規表現パターンを構築
BRANCH_PATTERN="^(${PROTECTED_BRANCHES})$"
OPS_PATTERN="(${DANGEROUS_OPS})"

# 現在のブランチを取得（Git リポジトリ外の場合は空）
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Git リポジトリ外の場合は許可
if [[ -z "$current_branch" ]]; then
    exit 0
fi

# 保護ブランチかチェック
if echo "$current_branch" | grep -qE "$BRANCH_PATTERN"; then
    # 危険な操作かチェック
    if echo "$CLAUDE_TOOL_INPUT" | grep -qE "$OPS_PATTERN"; then
        echo "BLOCK: ${BLOCK_MESSAGE}" >&2
        echo "現在のブランチ: ${current_branch}" >&2
        echo "実行しようとした操作: ${CLAUDE_TOOL_INPUT}" >&2
        exit 1
    fi
fi

# 条件に該当しなければ許可
exit 0
