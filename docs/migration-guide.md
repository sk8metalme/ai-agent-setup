# マイグレーションガイド

## 概要

ai-agent-setup は、レガシースクリプト方式から公式プラグインシステムへ完全移行しました。
このガイドでは、既存のインストール方法から新しいプラグインシステムへの移行手順を説明します。

---

## 変更内容サマリー

| 項目 | 旧方式（非推奨） | 新方式（推奨） |
|------|----------------|---------------|
| インストール方法 | `install-global.sh` | `/plugin install <name>@ai-agent-setup` |
| 設定の配置 | `~/.claude/` にファイルコピー | プラグインシステムが自動管理 |
| 更新方法 | スクリプト再実行 | `/plugin update <name>` |
| 管理方法 | 手動ファイル管理 | プラグインシステム経由 |

---

## 移行手順

### ステップ1: レガシー設定のバックアップ（任意）

既存の `~/.claude/` 設定をバックアップします。

```bash
cp -r ~/.claude ~/.claude.backup-$(date +%Y%m%d)
```

### ステップ2: プラグインのインストール

以下のコマンドでプラグインをインストールします。

#### 基本プラグイン（推奨）

```bash
/plugin install team-standards@ai-agent-setup
/plugin install development-toolkit@ai-agent-setup
```

#### 言語別プラグイン（使用言語に応じて）

```bash
# Java + Spring Boot開発の場合
/plugin install lang-java-spring@ai-agent-setup

# Python + FastAPI開発の場合
/plugin install lang-python@ai-agent-setup

# PHP + Slim Framework開発の場合
/plugin install lang-php@ai-agent-setup

# Perl + Mojolicious開発の場合
/plugin install lang-perl@ai-agent-setup
```

#### その他の機能プラグイン（必要に応じて）

```bash
# Jujutsu (jj) バージョン管理を使用する場合
/plugin install jujutsu-workflow@ai-agent-setup

# CI/CDトラブルシューティングが必要な場合
/plugin install ci-cd-tools@ai-agent-setup

# UI/UXデザインレビューが必要な場合
/plugin install design-review@ai-agent-setup

# E2Eファースト開発計画が必要な場合
/plugin install e2e-planning@ai-agent-setup

# OSSライセンスチェックが必要な場合
/plugin install oss-compliance@ai-agent-setup

# 技術スタックバージョン監査が必要な場合
/plugin install version-audit@ai-agent-setup
```

### ステップ3: レガシー設定の削除（任意）

プラグインインストール後、レガシー設定を削除できます。

```bash
# 注意: プラグインで管理されていないカスタム設定がある場合は削除しないでください
rm -rf ~/.claude/base
rm -rf ~/.claude/team
rm -rf ~/.claude/security
rm -rf ~/.claude/hooks
rm -rf ~/.claude/commands
rm -rf ~/.claude/skills
rm -rf ~/.claude/agents
rm -rf ~/.claude/languages
```

---

## プラグイン対応表

以下は、レガシー設定とプラグインの対応関係です。

| レガシー設定 | 対応プラグイン |
|-------------|---------------|
| ~/.claude/base/CLAUDE-base.md | team-standards@ai-agent-setup |
| ~/.claude/team/CLAUDE-team-standards.md | team-standards@ai-agent-setup |
| ~/.claude/security/CLAUDE-security-policy.md | team-standards@ai-agent-setup |
| ~/.claude/hooks/* | team-standards@ai-agent-setup |
| ~/.claude/commands/plan.md | development-toolkit@ai-agent-setup |
| ~/.claude/commands/dev.md | development-toolkit@ai-agent-setup |
| ~/.claude/commands/documentation.md | development-toolkit@ai-agent-setup |
| ~/.claude/commands/create_pr.md | development-toolkit@ai-agent-setup |
| ~/.claude/commands/git_sync.md | development-toolkit@ai-agent-setup |
| ~/.claude/commands/suggest-claude-md.md | development-toolkit@ai-agent-setup |
| ~/.claude/skills/changelog/ | development-toolkit@ai-agent-setup |
| ~/.claude/agents/changelog-generator/ | development-toolkit@ai-agent-setup |
| ~/.claude/agents/pr-resolver/ | development-toolkit@ai-agent-setup |
| ~/.claude/skills/jujutsu/ | jujutsu-workflow@ai-agent-setup |
| ~/.claude/skills/ci-cd/ | ci-cd-tools@ai-agent-setup |
| ~/.claude/skills/design-review/ | design-review@ai-agent-setup |
| ~/.claude/agents/design-reviewer/ | design-review@ai-agent-setup |
| ~/.claude/skills/e2e-first-planning/ | e2e-planning@ai-agent-setup |
| ~/.claude/agents/e2e-first-planner/ | e2e-planning@ai-agent-setup |
| ~/.claude/skills/oss-license/ | oss-compliance@ai-agent-setup |
| ~/.claude/agents/oss-license-checker/ | oss-compliance@ai-agent-setup |
| ~/.claude/skills/stable-version/ | version-audit@ai-agent-setup |
| ~/.claude/agents/stable-version-auditor/ | version-audit@ai-agent-setup |
| ~/.claude/languages/java-spring/ | lang-java-spring@ai-agent-setup |
| ~/.claude/skills/java-spring/ | lang-java-spring@ai-agent-setup |
| ~/.claude/languages/python/ | lang-python@ai-agent-setup |
| ~/.claude/skills/python/ | lang-python@ai-agent-setup |
| ~/.claude/languages/php/ | lang-php@ai-agent-setup |
| ~/.claude/skills/php/ | lang-php@ai-agent-setup |
| ~/.claude/languages/perl/ | lang-perl@ai-agent-setup |
| ~/.claude/skills/perl/ | lang-perl@ai-agent-setup |

---

## よくある質問

### Q1: レガシースクリプトは完全に使えなくなりますか？

A: `install-global.sh` と `install-project.sh` は非推奨となり、実行するとプラグインシステムへの移行を促すメッセージが表示されます。実際のインストールは行われません。

### Q2: 既存のカスタム設定はどうなりますか？

A: `~/.claude/CLAUDE.md` や `~/.claude/settings.json` などのプロジェクト固有設定はそのまま残ります。プラグイン化されていない独自のカスタマイズは手動で管理してください。

### Q3: プラグインの更新はどうすればよいですか？

A: 以下のコマンドで更新できます。

```bash
/plugin update <plugin-name>@ai-agent-setup
```

すべてのプラグインを更新する場合:

```bash
/plugin update --all
```

### Q4: プラグインをアンインストールしたい場合は？

A: 以下のコマンドでアンインストールできます。

```bash
/plugin uninstall <plugin-name>
```

### Q5: Cursor や Cline の設定はどうなりますか？

A: Cursor (`.cursor/`) と Cline (`.clinerules/`) の設定は Claude Code プラグインシステムの対象外のため、引き続き手動で管理してください。

---

## トラブルシューティング

### プラグインがインストールできない

1. Claude Code が最新版か確認してください
2. ネットワーク接続を確認してください
3. プラグインマーケットプレイス設定を確認してください

### レガシー設定と競合する

プラグインインストール後に古い設定との競合が発生した場合は、以下を確認してください:

1. `~/.claude/` 内のレガシー設定ファイルを削除
2. Claude Code を再起動
3. プラグインを再インストール

---

## サポート

問題が発生した場合は、以下のリソースを参照してください:

- [README.md](../README.md) - プロジェクト概要
- [GitHub Issues](https://github.com/sk8metalme/ai-agent-setup/issues) - バグ報告・機能リクエスト
- [プラグイン一覧](.claude-plugin/marketplace.json) - 利用可能なプラグイン

---

最終更新: 2025-12-25
