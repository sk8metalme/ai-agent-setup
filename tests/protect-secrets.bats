#!/usr/bin/env bats
# protect-secrets.sh のテストスイート

# テスト用のセットアップ
setup() {
    # テスト対象のスクリプトへのパス
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    HOOK_SCRIPT="$SCRIPT_DIR/global/hooks/protect-secrets.sh"

    # テスト用の一時ディレクトリ
    TEST_TEMP_DIR="$(mktemp -d)"

    # DEBUG=1でテストログを有効化（任意）
    export DEBUG=0
}

# テスト後のクリーンアップ
teardown() {
    rm -rf "$TEST_TEMP_DIR"
}

# ヘルパー関数：スクリプトを環境変数付きで実行
run_hook() {
    local input="$1"
    CLAUDE_TOOL_INPUT="$input" bash "$HOOK_SCRIPT"
}

# テスト1: CLAUDE_TOOL_INPUT未設定時は許可される
@test "Allow when CLAUDE_TOOL_INPUT is not set" {
    run bash "$HOOK_SCRIPT"
    [ "$status" -eq 0 ]
}

# テスト2: CLAUDE_TOOL_INPUT空文字時は許可される
@test "Allow when CLAUDE_TOOL_INPUT is empty" {
    run CLAUDE_TOOL_INPUT="" bash "$HOOK_SCRIPT"
    [ "$status" -eq 0 ]
}

# テスト3: .envファイルのReadをブロック
@test "Block Read tool access to .env file" {
    run run_hook '{"file_path": "/path/to/.env"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト4: .secretsディレクトリのReadをブロック
@test "Block Read tool access to .secrets directory" {
    run run_hook '{"file_path": "/home/user/.secrets/api_key.txt"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト5: credentialsファイルのReadをブロック
@test "Block Read tool access to credentials file" {
    run run_hook '{"file_path": "/config/credentials.json"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト6: 通常のファイルのReadは許可
@test "Allow Read tool access to normal file" {
    run run_hook '{"file_path": "/path/to/readme.md"}'
    [ "$status" -eq 0 ]
}

# テスト7: .pemファイルのReadをブロック
@test "Block Read tool access to .pem file" {
    run run_hook '{"file_path": "/keys/private.pem"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト8: .sshディレクトリのReadをブロック
@test "Block Read tool access to .ssh directory" {
    run run_hook '{"file_path": "/home/user/.ssh/id_rsa"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト9: .awsディレクトリのReadをブロック
@test "Block Read tool access to .aws directory" {
    run run_hook '{"file_path": "/home/user/.aws/credentials"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト10: cat コマンドで秘密情報ファイルを読み取ろうとするとブロック
@test "Block Bash tool cat command on .env file" {
    run run_hook '{"command": "cat /path/to/.env"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト11: grep コマンドで秘密情報ファイルを読み取ろうとするとブロック
@test "Block Bash tool grep command on credentials file" {
    run run_hook '{"command": "grep password /etc/credentials"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト12: パイプを含むcat コマンドでもブロック
@test "Block Bash tool cat command with pipe on .env file" {
    run run_hook '{"command": "cat .env | grep API"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト13: 通常のBashコマンドは許可
@test "Allow Bash tool normal command" {
    run run_hook '{"command": "ls -la /home"}'
    [ "$status" -eq 0 ]
}

# テスト14: catコマンドで通常ファイルは許可
@test "Allow Bash tool cat command on normal file" {
    run run_hook '{"command": "cat README.md"}'
    [ "$status" -eq 0 ]
}

# テスト15: コマンド行末のcatでもマッチ（単語境界テスト）
@test "Block Bash tool cat command at end of line" {
    run run_hook '{"command": "cat .env"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト16: .netrcファイルのReadをブロック
@test "Block Read tool access to .netrc file" {
    run run_hook '{"file_path": "/home/user/.netrc"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト17: service-account.jsonファイルのReadをブロック
@test "Block Read tool access to service-account.json file" {
    run run_hook '{"file_path": "/config/service-account.json"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト18: 大文字小文字を区別しない（.ENV も検出）
@test "Block Read tool access to .ENV file (case insensitive)" {
    run run_hook '{"file_path": "/path/to/.ENV"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト19: passwordを含むファイル名をブロック
@test "Block Read tool access to file containing 'password'" {
    run run_hook '{"file_path": "/config/database_password.txt"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト20: tokenを含むファイル名をブロック
@test "Block Read tool access to file containing 'token'" {
    run run_hook '{"file_path": "/app/api_token.json"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト21: JSONに複数フィールドがあっても正しくパース
@test "Parse JSON with multiple fields correctly" {
    run run_hook '{"file_path": "/path/to/.env", "other_field": "value"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト22: エスケープされた引用符を含むJSONでもパース（jq使用時）
@test "Parse JSON with escaped quotes (when jq available)" {
    if ! command -v jq &>/dev/null; then
        skip "jq not available"
    fi
    run run_hook '{"file_path": "/path/\"with\"/quotes/.env"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト23: 複数のセミコロンで区切られたコマンドでもマッチ
@test "Block Bash tool cat command with semicolon separator" {
    run run_hook '{"command": "cd /tmp; cat .env"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト24: private_keyパターンをブロック
@test "Block Read tool access to private_key file" {
    run run_hook '{"file_path": "/keys/private_key.pem"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}

# テスト25: api-keyパターンをブロック
@test "Block Read tool access to api-key file" {
    run run_hook '{"file_path": "/config/api-key.txt"}'
    [ "$status" -eq 1 ]
    [[ "$output" =~ "BLOCK" ]]
}
