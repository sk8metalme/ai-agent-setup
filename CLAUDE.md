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
```

## アーキテクチャ

```
ai-agent-setup/
├── plugins/                  # プラグインソース（11個）
│   ├── development-toolkit/  # 開発ワークフロー（/plan, /dev, /create_pr）
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
