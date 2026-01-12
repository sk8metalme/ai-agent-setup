# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 対話設定

- 日本語で回答
- 質問は AskUserQuestion ツールを使用

## リポジトリ概要

AI コーディングアシスタント（Claude Code、Cursor、Cline）向けの設定ファイル配布システム。
Claude Code 公式プラグインシステムとグローバル設定スクリプトを提供。

## よく使うコマンド

```bash
# グローバル設定のインストール（~/.claude/ へ）
./install-global.sh

# プラグインのインストール確認
cat ~/.claude/plugins/installed_plugins.json | jq '.plugins | keys'

# プラグインマニフェスト検証エラーの確認
grep -h '"docs"\|"languages"' plugins/*/.claude-plugin/plugin.json || echo "✅ OK"

# プラグイン名の一貫性チェック（marketplace.json と plugin.json の name が一致するか）
for plugin_dir in plugins/*/; do
  plugin_name=$(basename "$plugin_dir")
  json_name=$(cat "$plugin_dir/.claude-plugin/plugin.json" 2>/dev/null | jq -r '.name // empty')
  marketplace_name=$(cat .claude-plugin/marketplace.json | jq -r ".plugins[] | select(.source == \"./plugins/$plugin_name\") | .name")
  if [ -n "$json_name" ] && [ "$json_name" != "$marketplace_name" ]; then
    echo "❌ 不一致: ディレクトリ=$plugin_name, plugin.json=$json_name, marketplace.json=$marketplace_name"
  fi
done
echo "✅ チェック完了"

# marketplace.json の source パスが実在するか確認
jq -r '.plugins[] | .source' .claude-plugin/marketplace.json | while read src; do
  [ -d "${src#./}" ] || echo "❌ ディレクトリなし: $src"
done
echo "✅ ディレクトリ存在確認完了"
```

## アーキテクチャ

```
ai-agent-setup/
├── plugins/                  # プラグインソース（12個）
│   ├── development-toolkit/  # 開発ワークフロー（/plan, /dev, /create_pr）
│   ├── deep-dive/            # 深堀りスキル（ultrathink、要件明確化）
│   ├── jujutsu-workflow/     # Jujutsu VCS サポート
│   ├── lang-java-spring/     # Java + Spring Boot
│   ├── lang-python/          # Python + FastAPI
│   ├── lang-php/             # PHP + Slim
│   ├── lang-perl/            # Perl + Mojolicious
│   ├── ci-cd-tools/          # CI/CD トラブルシューティング
│   ├── oss-compliance/       # OSS ライセンス監査
│   ├── version-audit/        # バージョン/EOL 監査
│   ├── design-review/        # UI/UX デザインレビュー
│   └── e2e-planning/         # E2E 開発計画
├── global/                   # グローバル配布（install-global.sh → ~/.claude/）
│   ├── CLAUDE.md             # @import + プラグインガイド
│   ├── base/                 # 基本コーディング原則
│   ├── security/             # セキュリティポリシー
│   ├── team/                 # チーム開発標準
│   └── hooks/                # notify.sh, protect-branch.sh
├── .cursor/rules/            # Cursor Project Rules (.mdc)
├── .clinerules/              # Cline ルール
└── CLAUDE.md                 # このファイル（開発者向け）
```

## プラグイン開発ガイドライン

### plugin.json サポートキー

| キー | 説明 | 必須 |
|------|------|------|
| `name` | プラグイン名（kebab-case） | ✅ |
| `description` | 説明 | ✅ |
| `version` | semver（例: "1.0.0"） | ✅ |
| `author` | `{ "name": "...", "email": "...", "url": "..." }` | - |
| `homepage` | プロジェクト/ドキュメントURL | - |
| `repository` | ソースリポジトリURL | - |
| `license` | SPDX識別子（例: "MIT"） | - |
| `keywords` | 検索用キーワード配列 | - |
| `category` | マーケットプレイス用カテゴリ | - |
| `tags` | マーケットプレイス検索用タグ配列 | - |
| `strict` | マニフェスト検証の強制（boolean） | - |
| `commands` | コマンドマークダウンファイルパス配列 | - |
| `agents` | エージェントファイルパス配列 | - |
| `hooks` | フック設定（パスまたはオブジェクト） | - |
| `mcpServers` | MCPサーバー設定またはパス | - |

### 使用禁止キー（エラーになる）

| キー | 代替方法 |
|------|---------|
| `docs` | SKILL.md に統合 |
| `languages` | SKILL.md に統合 |
| `components` | 使用不可 |

**エラー例:**
```
Error: Plugin has an invalid manifest file.
Validation errors: Unrecognized key(s) in object: 'docs'
```

### バージョン管理

プラグイン関連のファイル（plugin.json, commands/, agents/, skills/, hooks/）を修正した場合は、必ずバージョンを更新すること。

**Semantic Versioning:**
- **MAJOR** (x.0.0): 破壊的変更（既存機能の削除・変更）
- **MINOR** (0.x.0): 後方互換の新機能追加
- **PATCH** (0.0.x): バグ修正・ドキュメント修正

### プラグイン名変更時のチェックリスト

プラグインのディレクトリ名や name を変更する際は、以下のすべてのファイルで一貫性を保つこと。

**問題事例（deep-dive プラグイン）:**
- ディレクトリ名を `dd/` → `deep-dive/` に変更
- `plugin.json` の `"name": "deep-dive"` に変更
- しかし、**marketplace.json が古い "dd" のまま**だった
- 結果: マーケットプレイスでプラグインが見つからない（`Plugin "deep-dive" not found in any marketplace`）

**必須チェック項目:**

| # | ファイル | 確認内容 | 例 |
|---|---------|---------|-----|
| 1 | `plugins/<name>/` | ディレクトリ名 | `plugins/deep-dive/` |
| 2 | `plugins/<name>/.claude-plugin/plugin.json` | `"name"` キー | `"name": "deep-dive"` |
| 3 | **`.claude-plugin/marketplace.json`** | `"name"` と `"source"` | `"name": "deep-dive"`, `"source": "./plugins/deep-dive"` |
| 4 | `CLAUDE.md` | アーキテクチャ図、実例記載 | `├── deep-dive/` |
| 5 | `README.md` | インストールコマンド、テーブル、説明 | `/plugin install deep-dive@ai-agent-setup` |
| 6 | `global/CLAUDE.md` | プラグインガイド（該当する場合） | `/plugin install deep-dive@ai-agent-setup` |

**最重要:** **`.claude-plugin/marketplace.json`** の更新忘れに注意！これがないとマーケットプレイスで検索できません。

**検証コマンド:**

```bash
# プラグイン名の一貫性チェック（新旧名が混在していないか確認）
OLD_NAME="dd"
NEW_NAME="deep-dive"

# marketplace.json に古い名前が残っていないか
grep -n "\"$OLD_NAME\"" .claude-plugin/marketplace.json

# plugin.json が正しいか
cat plugins/$NEW_NAME/.claude-plugin/plugin.json | jq '.name'

# README.md/CLAUDE.md に古い名前が残っていないか
grep -n "$OLD_NAME" README.md CLAUDE.md

# マーケットプレイス更新後の動作確認
/plugin marketplace refresh
/plugin install $NEW_NAME@ai-agent-setup
```

**バージョン更新の推奨:**
- プラグイン名変更は破壊的変更のため、**MAJOR バージョンアップ**を推奨
- ただし、まだ広く使われていない場合は MINOR/PATCH でも可

### marketplace.json での skills 登録（必須）

**重要**: プラグインの skills を機能させるには、**2箇所**に定義が必要：

| ファイル | 用途 | 必須 |
|---------|------|------|
| `plugins/<name>/.claude-plugin/plugin.json` | プラグイン本体の定義 | ✅ |
| `.claude-plugin/marketplace.json` | マーケットプレイス経由でのスキル登録 | ✅ |

**よくある間違い:**
- plugin.json にだけ skills を定義 → マーケットプレイス経由だと「Unknown skill」エラー

**正しい設定例:**

`.claude-plugin/marketplace.json`:
```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "version": "1.0.0",
      "skills": ["./skills/my-skill/SKILL.md"]
    }
  ]
}
```

**重要**: `skills` 配列は必須です。`source` からの相対パスで `SKILL.md` まで含めた完全パス形式で指定してください。

### marketplace.json と plugin.json の version 同期

**重要**: marketplace.json の version は plugin.json と**必ず一致**させること。

不一致があると、マーケットプレイスに古いバージョンが表示され、ユーザーが混乱する。

**チェックコマンド:**
```bash
# 全プラグインの version 一致確認
for plugin_dir in plugins/*/; do
  plugin_name=$(basename "$plugin_dir")
  plugin_ver=$(jq -r '.version' "$plugin_dir/.claude-plugin/plugin.json" 2>/dev/null)
  market_ver=$(jq -r ".plugins[] | select(.name == \"$plugin_name\") | .version" .claude-plugin/marketplace.json)
  if [ "$plugin_ver" != "$market_ver" ]; then
    echo "❌ $plugin_name: plugin.json=$plugin_ver, marketplace.json=$market_ver"
  fi
done
echo "✅ バージョン確認完了"
```

### Commands vs Skills（v2.1.0+）

Claude Code v2.1.0 以降、Skills がスラッシュコマンドメニューに自動表示されるようになりました。

**機能比較:**

| 機能 | Commands | Skills |
|------|----------|--------|
| スラッシュコマンド呼び出し | ✅ | ✅ |
| トリガーキーワード自動起動 | ❌ | ✅ |
| `agent` / `model` / `context: fork` | ❌ | ✅ |
| `user-invocable: false`（内部専用） | ❌ | ✅ |

**推奨:** 新規プラグインは **Skills-only** で作成

```json
{
  "name": "example-plugin",
  "version": "1.0.0",
  "skills": ["./skills/example/SKILL.md"]
}
```

Commands はレガシー互換性維持目的でのみ使用を検討してください。

**実例:** deep-dive plugin v1.2.0 で `commands/dd.md` を削除し Skills-only に統合（177行削減）

**参考:** [Commit 870624f](https://github.com/anthropics/claude-code/commit/870624fc1581a70590e382f263e2972b3f1e56f5) - Skills のスラッシュコマンドメニュー対応

### Skills パス形式の注意点（重要）

**Claude Code は skills パスを「ディレクトリパス」として解釈し、その中の `SKILL.md` を自動的に探索します。**

| 項目 | 正しい形式 ✅ | 間違った形式 ❌ |
|------|------------|--------------|
| plugin.json | `"./skills/changelog"` | `"./skills/changelog/SKILL.md"` |
| marketplace.json | `"./skills/changelog"` | `"./skills/changelog/SKILL.md"` |
| 結果 | Skills が正常に読み込まれる | "Unknown skill" エラー |

**よくあるエラー:**
```
Unknown skill: changelog
```

**原因:** パスに `/SKILL.md` を含めている

**解決方法:** ディレクトリパスのみを指定

```json
// ❌ 動かない
{
  "skills": [
    "./skills/changelog/SKILL.md"
  ]
}

// ✅ 正しい
{
  "skills": [
    "./skills/changelog"
  ]
}
```

**公式リポジトリとの比較:**

[anthropics/skills](https://github.com/anthropics/skills) の plugin.json:
```json
{
  "skills": [
    "./skills/pdf",
    "./skills/pptx",
    "./skills/docx"
  ]
}
```

**重要:** すべてディレクトリパスのみ。`SKILL.md` を含めない。

**検証コマンド:**
```bash
# skills パスに SKILL.md が含まれていないか確認
jq -r '.skills[]' plugins/*/.claude-plugin/plugin.json | grep -i 'SKILL\.md' && echo "❌ エラー: SKILL.md を削除してください" || echo "✅ OK"

# marketplace.json も同様に確認
jq -r '.plugins[].skills[]?' .claude-plugin/marketplace.json | grep -i 'SKILL\.md' && echo "❌ エラー: SKILL.md を削除してください" || echo "✅ OK"
```

**参考:** [Issue #49 コメント](https://github.com/sk8metalme/ai-agent-setup/issues/49) - Skills パス形式の問題発見と修正

---

### SessionEnd フックの設定方法

**重要:** plugin.json の `hooks` 設定は**現在非対応**です。フックを使用するには **~/.claude/settings.json** で手動登録が必要です。

#### 1. フックスクリプトの配置

プラグインのフックスクリプトは `scripts/` ディレクトリに配置します：

```bash
plugins/
└── my-plugin/
    └── scripts/
        └── my-hook.sh  # フックスクリプト
```

#### 2. settings.json への登録

**~/.claude/settings.json** に以下の形式で追加：

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/plugins/<owner>_<plugin-name>_<version>/scripts/my-hook.sh"
          }
        ]
      }
    ]
  }
}
```

**実例: guardrail-builder (development-toolkit v1.6.0):**

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/plugins/sk8metalme_development-toolkit_1.6.0/scripts/guardrail-builder-hook.sh"
          }
        ]
      }
    ]
  }
}
```

#### 3. プラグインパスの確認方法

インストール済みプラグインのパスは以下で確認できます：

```bash
# インストール済みプラグイン一覧
cat ~/.claude/plugins/installed_plugins.json | jq -r '.plugins | keys[]'

# 特定プラグインのパス
ls -la ~/.claude/plugins/ | grep development-toolkit
```

**出力例:**
```
drwxr-xr-x  sk8metalme_development-toolkit_1.6.0
```

#### 4. フックスクリプトのベストプラクティス

**無限ループ対策（必須）:**

SessionEnd フック内で claude コマンドを実行すると、再度 SessionEnd フックが発火して無限ループになります。環境変数でガードしてください：

```bash
#!/bin/bash

# 無限ループ対策
if [ "${MY_HOOK_RUNNING:-}" = "1" ]; then
    echo "Already running. Skipping." >&2
    exit 0
fi
export MY_HOOK_RUNNING=1

# フック処理
# ...
```

**プロジェクトルート検出:**

フックは Claude Code のワーキングディレクトリとは異なる場所で実行される可能性があります。以下の順序で検出してください：

```bash
PROJECT_ROOT=""

# 1) 環境変数 CLAUDE_PROJECT_DIR
if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    PROJECT_ROOT="${CLAUDE_PROJECT_DIR/#\~/$HOME}"
fi

# 2) ~/.claude/settings.json の project_dir
if [ -z "$PROJECT_ROOT" ]; then
    SETTINGS_FILE="$HOME/.claude/settings.json"
    if [ -f "$SETTINGS_FILE" ]; then
        PROJECT_DIR_FROM_SETTINGS=$(jq -r '.project_dir // ""' "$SETTINGS_FILE")
        if [ -n "$PROJECT_DIR_FROM_SETTINGS" ]; then
            PROJECT_ROOT="${PROJECT_DIR_FROM_SETTINGS/#\~/$HOME}"
        fi
    fi
fi

# 3) git root
if [ -z "$PROJECT_ROOT" ]; then
    GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
    if [ -n "$GIT_ROOT" ]; then
        PROJECT_ROOT="$GIT_ROOT"
    fi
fi

# 4) pwd（最終フォールバック）
if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT="$(pwd)"
fi
```

#### 5. 動作確認

```bash
# Claude Code を正常終了
# → フックが実行され、処理結果が表示される（development-toolkit の場合は macOS 通知）

# ログ確認（development-toolkit の例）
tail -f ~/.claude/logs/guardrail-builder-*.log
```

#### 6. トラブルシューティング

**Q: フックが実行されない**

A: 以下を確認：
- settings.json の JSON 構文が正しいか（jq でバリデーション）
- フックスクリプトに実行権限があるか（`chmod +x`）
- プラグインパスが正しいか（バージョン番号を含む完全パス）

```bash
# JSON 構文チェック
jq . ~/.claude/settings.json > /dev/null && echo "✅ OK" || echo "❌ JSON エラー"

# 実行権限確認
ls -la ~/.claude/plugins/sk8metalme_development-toolkit_1.6.0/scripts/*.sh
```

**Q: 無限ループになる**

A: フックスクリプト内で環境変数ガードを追加（上記「無限ループ対策」参照）

**参考:**
- guardrail-builder 実装: `plugins/development-toolkit/scripts/guardrail-builder-hook.sh`
- [Issue #49](https://github.com/sk8metalme/ai-agent-setup/issues/49) - guardrail-builder 実装計画

---

## 開発原則

- TDD 推奨、カバレッジ 95%+ 目標
- 1 回の変更は最大 100 行
- main/master への直接 push 禁止
- force push 禁止
- 作業は feature/, bugfix/, hotfix/ ブランチで

## 必要ツール

```bash
which npm jj gh node jq
```

- `npm` - Node.js パッケージマネージャー
- `jj` - Jujutsu バージョン管理
- `gh` - GitHub CLI
- `node` - Node.js ランタイム
- `jq` - JSON プロセッサ（インストールスクリプト用）

## プラグインインストール（ユーザー向け）

```bash
# マーケットプレイス追加
/plugin marketplace add sk8metalme/ai-agent-setup

# 推奨プラグイン
/plugin install development-toolkit@ai-agent-setup

# 言語別プラグイン
/plugin install lang-java-spring@ai-agent-setup
/plugin install lang-python@ai-agent-setup
/plugin install lang-php@ai-agent-setup
/plugin install lang-perl@ai-agent-setup

# 機能プラグイン
/plugin install jujutsu-workflow@ai-agent-setup
/plugin install ci-cd-tools@ai-agent-setup
/plugin install oss-compliance@ai-agent-setup
/plugin install version-audit@ai-agent-setup
/plugin install design-review@ai-agent-setup
/plugin install e2e-planning@ai-agent-setup
```

## 学習済みルール

@CLAUDE-guardrail.md
