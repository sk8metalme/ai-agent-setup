---
name: secrets-guard
description: |
  Claude Codeで秘密情報を安全に管理するための多層防御アプローチガイド。
  APIトークン、DB認証情報、SSH鍵などを保護する3層防御戦略。
allowed-tools: Read, Grep
---

# 秘密情報管理（Secrets Guard）

Claude Codeで秘密情報を安全に管理するための多層防御アプローチガイド。

---

## 概要

Claude Codeは強力な開発支援ツールですが、秘密情報（APIトークン、データベース認証情報、SSH鍵など）の取り扱いには注意が必要です。本スキルでは、**3層の防御層（L1-L3）**を組み合わせた包括的なアプローチで秘密情報を保護します。

### 既知の問題点

| 問題 | 詳細 |
|------|------|
| **自動読み込み** | Claude Codeは`.env`, `.env.local`などを自動的にメモリに読み込む可能性がある |
| **deny設定のバグ** | `settings.json`の`deny`設定が完全に機能しないバグ（[Issue #6631](https://github.com/anthropics/claude-code/issues/6631), [#6699](https://github.com/anthropics/claude-code/issues/6699)） |
| **間接的な漏洩** | system reminderなど間接的な方法で内容が漏洩する可能性がある |

---

## 多層防御アプローチ

### レベル1: 物理的な分離（最も確実）

**原則**: 秘密情報はClaude Codeがアクセスできない場所に置く

#### セットアップ手順

```bash
# 1. ~/.secrets/ ディレクトリを作成
mkdir -p ~/.secrets
chmod 700 ~/.secrets

# 2. プロジェクト用ディレクトリを作成
mkdir -p ~/.secrets/my-project

# 3. .envファイルを移動（シンボリックリンクは作成しない）
mv .env ~/.secrets/my-project/.env

# 4. テンプレートから作成する場合
cp global/templates/secrets/.env.example ~/.secrets/my-project/.env
vi ~/.secrets/my-project/.env
```

#### 実行時の読み込み

**方法A: sourceコマンド**

```bash
# プロジェクトディレクトリで実行
set -a
source ~/.secrets/my-project/.env
set +a
npm run dev
```

**方法B: シェル関数（推奨）**

`~/.bashrc` または `~/.zshrc` に追加:

```bash
load_project_env() {
    local project_name="${1:-$(basename $(pwd))}"
    local env_file="$HOME/.secrets/${project_name}/.env"

    if [[ -f "$env_file" ]]; then
        set -a
        source "$env_file"
        set +a
        echo "✅ Loaded: $env_file"
    else
        echo "⚠️  Not found: $env_file"
    fi
}
alias lenv='load_project_env'
```

使用例:

```bash
cd ~/projects/my-project
lenv  # ~/.secrets/my-project/.env を読み込み
```

---

### レベル2: deny設定（追加の防御層）

`~/.claude/settings.json` のdenied配列に秘密情報パターンを追加。

#### テンプレート使用

```bash
# テンプレートを確認
cat global/templates/secrets/settings-deny-secrets.json

# 手動で ~/.claude/settings.json の "permissions.denied" に追加
```

#### 設定例

```json
{
  "permissions": {
    "denied": [
      "Read(~/.secrets/*)",
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Read(**/credentials.json)",
      "Bash(cat:*/.env*)",
      "Bash(cat:*credentials*)"
    ]
  }
}
```

---

### レベル3: PreToolUse Hook（フェイルセーフ）

deny設定のバグを補完するため、`protect-secrets.sh`を設置。

#### Hookの仕組み

1. Claude CodeがファイルやBashコマンドを実行する前に`protect-secrets.sh`を実行
2. スクリプトが秘密情報パターンを検出した場合、操作をブロック（exit 1）
3. deny設定が機能しなくても、Hookで確実にブロック

#### 有効化済み

`install-global.sh` 実行時に以下が自動的に設定されます:

- `~/.claude/hooks/protect-secrets.sh` （実行スクリプト）
- `~/.claude/hooks/protect-secrets.conf` （設定ファイル）
- `~/.claude/settings.json` にHook設定追加

#### カスタマイズ

`~/.claude/hooks/protect-secrets.conf` を編集:

```bash
# 独自の秘密情報パターンを追加
SECRETS_PATTERNS=".env|\.secrets|credentials|my_custom_pattern"

# デバッグモード有効化
DEBUG=1
```

#### デバッグ

```bash
# ログを確認
tail -f ~/.claude/hooks/protect-secrets.log

# 手動テスト
CLAUDE_TOOL_INPUT='{"file_path":".env"}' ~/.claude/hooks/protect-secrets.sh
# 期待: exit 1, BLOCKメッセージ表示
```

---

## ディレクトリ構成例

```
$HOME/
├── .secrets/                    # 秘密情報（Claude Codeアクセス外）
│   ├── project-a/
│   │   └── .env
│   ├── project-b/
│   │   └── .env
│   └── shared/
│       └── common.env
│
├── .claude/
│   ├── settings.json            # deny設定
│   └── hooks/
│       ├── protect-secrets.sh   # PreToolUse Hook
│       └── protect-secrets.conf
│
└── projects/                    # 開発プロジェクト
    ├── project-a/
    │   ├── .claude/
    │   └── src/
    └── project-b/
```

---

## シークレットスキャン（Gitleaks）

### インストール

```bash
# Homebrew (macOS)
brew install gitleaks

# または
go install github.com/gitleaks/gitleaks/v8@latest
```

### 使用方法

```bash
# テンプレートをコピー
cp global/templates/secrets/gitleaks.toml .

# スキャン実行
gitleaks detect --config gitleaks.toml

# pre-commitフックに統合
cat <<'EOF' > .git/hooks/pre-commit
#!/bin/bash
gitleaks protect --staged --config gitleaks.toml
EOF
chmod +x .git/hooks/pre-commit
```

---

## .gitignore設定

秘密情報ファイルをGitから除外:

```gitignore
# 秘密情報
.env
.env.*
!.env.example
!.env.template
.secrets/
secrets/
credentials/
*.pem
*.key
*.p12
*.pfx
id_rsa*
id_ed25519*
service-account.json
.netrc
.npmrc
.pypirc
```

---

## チェックリスト

### 初期セットアップ

- [ ] `~/.secrets/` ディレクトリを作成（`chmod 700`）
- [ ] `.env`ファイルをプロジェクト外に移動
- [ ] `install-global.sh`を実行（Hookとdenied設定を自動適用）
- [ ] シェル関数`load_project_env`を追加
- [ ] `.gitignore`に秘密情報パターンを追加

### プロジェクト開始時

- [ ] `mkdir -p ~/.secrets/<project-name>`
- [ ] `.env.example`をコピーして`~/.secrets/<project-name>/.env`を作成
- [ ] Gitleaks設定を追加
- [ ] pre-commitフックを設定

---

## トラブルシューティング

### Q: deny設定が効かない

**A:** PreToolUse Hook（L3）が動作しているか確認:

```bash
# Hookのログを確認
DEBUG=1
tail -f ~/.claude/hooks/protect-secrets.log
```

### Q: Hookがエラーになる

**A:** 実行権限と所有者を確認:

```bash
ls -la ~/.claude/hooks/protect-secrets.sh
# -rwxr-xr-x (実行権限が必要)

# 修正
chmod +x ~/.claude/hooks/protect-secrets.sh
```

### Q: 間接的に秘密情報が漏洩した

**A:** 以下の対策を追加:

1. 秘密情報をプロジェクトディレクトリ外に移動（L1）
2. system reminderに秘密情報が含まれていないか確認
3. コンテナ環境での実行を検討

---

## 参考リンク

### 公式ドキュメント

- [Claude Code Security](https://code.claude.com/docs/en/security)
- [API Key Best Practices](https://support.claude.com/en/articles/9767949-api-key-best-practices)

### GitHub Issues

- [#6631 - Permission Deny Configuration Not Enforced](https://github.com/anthropics/claude-code/issues/6631)
- [#6699 - deny permissions not enforced](https://github.com/anthropics/claude-code/issues/6699)
- [#39 - 秘密情報管理](https://github.com/sk8metalme/ai-agent-setup/issues/39)

### ツール

- [Gitleaks](https://github.com/gitleaks/gitleaks) - シークレットスキャナー
- [TruffleHog](https://github.com/trufflesecurity/truffleHog) - シークレット検出

---

## まとめ

**多層防御の原則**:

1. **L1（物理的分離）**: 最も確実。`~/.secrets/`に配置
2. **L2（deny設定）**: 追加の防御層。バグがあるため単独では不十分
3. **L3（Hook）**: フェイルセーフ。deny設定のバグを補完

この3層を組み合わせることで、Claude Codeで安全に開発できます。
