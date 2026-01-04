#!/bin/bash
# protect-secrets.sh
# Claude Code Hooks 用の秘密情報保護スクリプト
# 配置場所: ~/.claude/hooks/protect-secrets.sh

# -u を削除（未設定変数でエラー終了しない）
set -eo pipefail

# デバッグモード（1でログ出力有効化）
DEBUG="${DEBUG:-0}"
DEBUG_LOG="${HOME}/.claude/hooks/protect-secrets.log"

log_debug() {
    if [[ "$DEBUG" -eq 1 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$DEBUG_LOG"
    fi
}

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/protect-secrets.conf"

# デフォルト設定
SECRETS_PATTERNS=".env|\.secrets|credentials|credential|private[_-]?key|api[_-]?key|password|passwd|token|secret"
SECRETS_EXTENSIONS="\.pem|\.key|\.p12|\.pfx|id_rsa|id_ed25519|\.ppk"
SECRETS_FILES="\.netrc|\.npmrc|\.pypirc|service-account\.json|keystore"
BLOCK_MESSAGE="秘密情報ファイルへのアクセスはブロックされました。"

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

# JSONからfile_pathを抽出（Read toolの場合）
file_path=$(echo "$tool_input" | grep -oE '"file_path"\s*:\s*"[^"]*"' | sed 's/"file_path"\s*:\s*"\([^"]*\)"/\1/' || echo "")

# Bashコマンドの場合、commandを抽出
bash_command=$(echo "$tool_input" | grep -oE '"command"\s*:\s*"[^"]*"' | sed 's/"command"\s*:\s*"\([^"]*\)"/\1/' || echo "")

log_debug "Extracted file_path: ${file_path:-NONE}"
log_debug "Extracted bash_command: ${bash_command:-NONE}"

# ファイルパスが秘密情報パターンにマッチするかチェック
check_secrets_pattern() {
    local path="$1"
    local path_lower=$(echo "$path" | tr '[:upper:]' '[:lower:]')

    # パターンマッチ
    if echo "$path_lower" | grep -qE "$SECRETS_PATTERNS"; then
        return 0  # マッチ（ブロック対象）
    fi

    # 拡張子チェック
    if echo "$path_lower" | grep -qE "$SECRETS_EXTENSIONS"; then
        return 0  # マッチ（ブロック対象）
    fi

    # ファイル名チェック
    if echo "$path_lower" | grep -qE "$SECRETS_FILES"; then
        return 0  # マッチ（ブロック対象）
    fi

    # 特定ディレクトリチェック（~/.secrets, ~/.aws, ~/.ssh）
    if echo "$path" | grep -qE "(^|/)\.secrets(/|$)|(^|/)\.aws(/|$)|(^|/)\.ssh(/|$)"; then
        return 0  # マッチ（ブロック対象）
    fi

    return 1  # マッチしない（許可）
}

# Read toolのチェック
if [[ -n "$file_path" ]]; then
    if check_secrets_pattern "$file_path"; then
        log_debug "BLOCKED: Read attempt on secrets file: $file_path"
        echo "BLOCK: ${BLOCK_MESSAGE}" >&2
        echo "ブロックされたファイル: ${file_path}" >&2
        echo "理由: このファイルには秘密情報が含まれている可能性があります。" >&2
        echo "対処: 環境変数を使用するか、ユーザーに直接確認してください。" >&2
        exit 1
    fi
fi

# Bash tool のチェック（cat, less, more, head, tail, vim, nano等でのファイル読み取り）
if [[ -n "$bash_command" ]]; then
    # 読み取り系コマンドのパターン
    read_commands="cat |less |more |head |tail |vim |nano |vi |emacs |grep |awk |sed "

    # コマンドが読み取り系かチェック
    for cmd in $read_commands; do
        if echo "$bash_command" | grep -qE "^${cmd}| ${cmd}"; then
            # コマンドライン全体に対して秘密情報パターンをチェック
            if check_secrets_pattern "$bash_command"; then
                log_debug "BLOCKED: Bash read command on secrets: $bash_command"
                echo "BLOCK: ${BLOCK_MESSAGE}" >&2
                echo "ブロックされたコマンド: ${bash_command}" >&2
                echo "理由: このコマンドは秘密情報を読み取る可能性があります。" >&2
                exit 1
            fi
        fi
    done
fi

# 条件に該当しなければ許可
log_debug "Hook completed, allowing operation"
exit 0
