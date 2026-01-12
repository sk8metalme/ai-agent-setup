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
