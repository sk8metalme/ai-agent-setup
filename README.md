# AI Agent Setup

生成AIエージェント（Claude、Cursor、Cline）の設定ファイルを簡単に配布・セットアップできるシステムです。

## 📋 概要

このプロジェクトでは、**Claude Code公式プラグインシステム**を使用した配布方式を提供しています。

> **⚠️ 重要**: レガシースクリプト（install-global.sh / install-project.sh）は非推奨です。プラグインシステムへの移行をお願いします。詳細は [マイグレーションガイド](docs/migration-guide.md) をご覧ください。

### 🔌 プラグイン配布（推奨）

**Claude Code公式プラグインシステム**を使用した配布方式です。

#### インストール方法

```bash
# 1. マーケットプレイスを追加
/plugin marketplace add sk8metalme/ai-agent-setup

# 2. 必要なプラグインをインストール
/plugin install team-standards@ai-agent-setup
/plugin install jujutsu-workflow@ai-agent-setup
/plugin install development-toolkit@ai-agent-setup
```

#### 利用可能なプラグイン

**高優先度（必須・推奨）:**

| プラグイン | 説明 |
|-----------|------|
| `team-standards` | チーム標準・セキュリティポリシー・基本設定（全員必須） |
| `jujutsu-workflow` | Jujutsuバージョン管理ワークフロー |
| `development-toolkit` | 開発ワークフロー統合（計画・PR・CHANGELOG） |

**中優先度（機能別）:**

| プラグイン | 説明 |
|-----------|------|
| `ci-cd-tools` | CI/CDトラブルシューティング・GitHub Actions支援 |
| `oss-compliance` | OSSライセンスチェック・監査 |
| `version-audit` | 技術スタックバージョン監査・EOLチェック |
| `design-review` | UI/UXデザインレビュー・アクセシビリティチェック |
| `e2e-planning` | E2Eファースト開発計画・Walking Skeleton設計 |

**低優先度（言語別）:**

| プラグイン | 説明 |
|-----------|------|
| `lang-java-spring` | Java + Spring Boot開発支援 |
| `lang-python` | Python + FastAPI開発支援 |
| `lang-php` | PHP + Slim Framework開発支援 |
| `lang-perl` | Perl + Mojolicious開発支援 |

#### 更新方法

```bash
# 特定プラグインを更新
claude plugin update team-standards@ai-agent-setup

# 全プラグインを更新
claude plugin update --all
```

### 📁 その他の設定ファイル

プラグインシステムの対象外ですが、以下のツール向け設定も提供しています：

- **Cursor**: `.cursor/rules/*.mdc` 形式のProject Rules
- **Cline**: `.clinerules/` ディレクトリのルールファイル
- **AGENTS.md**: シンプルなAI設定ファイル

## 🤖 スキル & エージェント

### スキル（知識ライブラリ）
- **jujutsu**: Jujutsuバージョン管理のベストプラクティス
- **ci-cd**: GitHub Actions/Screwdriverのトラブルシューティング
- **oss-license**: OSSライセンスコンプライアンスガイド
- **stable-version**: LTS/EOL管理、バージョンアップグレード判断
- **e2e-first-planning**: Walking Skeleton、MVP計画策定
- **design-review**: アクセシビリティ、レスポンシブ、パフォーマンス評価
- **changelog**: CHANGELOG/リリースノート生成、Conventional Commits、SemVer
- **java-spring**: Java + Spring Boot開発支援
- **php**: PHP開発支援
- **perl**: Perl開発支援
- **python**: Python開発支援

### エージェント（実行アシスタント）
- **pr-resolver**: PRレビューコメントの自動resolve
- **oss-license-checker**: 依存パッケージライセンス監査、代替提案
- **stable-version-auditor**: 技術スタックバージョン監査、リスク評価
- **e2e-first-planner**: E2E開発計画の自動生成
- **design-reviewer**: UI/UXデザインの自動レビュー
- **changelog-generator**: CHANGELOG.md自動生成、GitHub Releases作成支援

## 🚀 クイックスタート

### プラグインシステムを使ったインストール（推奨）

```bash
# 1. マーケットプレイスを追加
/plugin marketplace add sk8metalme/ai-agent-setup

# 2. 基本プラグインをインストール（推奨）
/plugin install team-standards@ai-agent-setup
/plugin install development-toolkit@ai-agent-setup

# 3. 必要に応じて言語別プラグインをインストール
/plugin install lang-python@ai-agent-setup  # Python開発の場合
/plugin install lang-java-spring@ai-agent-setup  # Java開発の場合

# 4. その他の機能プラグイン（必要に応じて）
/plugin install jujutsu-workflow@ai-agent-setup  # Jujutsu使用時
/plugin install ci-cd-tools@ai-agent-setup  # CI/CDツール使用時
```

### レガシースクリプト（非推奨）

> **⚠️ 非推奨**: install-global.sh と install-project.sh は非推奨です。実行すると、プラグインシステムへの移行を促すメッセージが表示されます。既存ユーザーは [マイグレーションガイド](docs/migration-guide.md) を参照してください。

## 🎯 対応言語・フレームワーク

| 言語 | フレームワーク | 特徴 |
|------|---------------|------|
| **Java** | Spring Boot 3.x + Gradle | エンタープライズ開発、NullAway、Rocky Linux |
| **PHP** | Slim Framework + Composer | 軽量API、Monolog、Phake、MySQL/Oracle |
| **Perl** | Mojolicious + Modern Perl | スクリプト・Web、モダンPerl機能 |
| **Python** | FastAPI + Poetry | 高速API、型ヒント、非同期処理 |

## 📁 プラグインシステムによるファイル配置

プラグインインストール後、Claude Codeが自動的に以下の場所にファイルを配置します：

### ユーザーホームディレクトリ（グローバル設定）

プラグインで管理されるファイルは `~/.claude/plugins/<plugin-name>/` に配置されます。

```
~/.claude/
├── plugins/                     # プラグイン管理ディレクトリ
│   ├── team-standards/          # チーム標準プラグイン
│   │   ├── base/CLAUDE-base.md
│   │   ├── team/CLAUDE-team-standards.md
│   │   ├── security/CLAUDE-security-policy.md
│   │   └── hooks/
│   ├── development-toolkit/     # 開発ツールキットプラグイン
│   │   ├── commands/
│   │   ├── skills/
│   │   ├── agents/
│   │   └── bin/
│   ├── lang-python/             # Python開発プラグイン
│   │   ├── skills/
│   │   └── languages/
│   └── ...                      # その他のプラグイン
├── CLAUDE.md                    # ユーザー固有設定
└── settings.json                # ユーザー固有設定
```

### 配布用テンプレート（本プロジェクト）

このリポジトリ内の構造：

```
ai-agent-setup/
├── plugins/                     # プラグインソース（SSoT）
│   ├── team-standards/
│   ├── development-toolkit/
│   ├── lang-python/
│   └── ...（全12個のプラグイン）
├── .claude/                     # プロジェクトテンプレート（最小限）
│   ├── CLAUDE.md               # プラグインインストールガイド
│   ├── settings.json           # 基本設定
│   └── README.md               # 設定説明
├── .cursor/                     # Cursor設定
├── .clinerules/                 # Cline設定
├── AGENTS.md                   # シンプル設定
├── install-global.sh           # 非推奨（リダイレクト専用）
└── install-project.sh          # 非推奨（リダイレクト専用）
```

### プロジェクト設定（Cursor + Claude）
```
my-project/
├── .cursor/
│   ├── rules/                # Project Rules（推奨）
│   │   ├── general.mdc       # 全般的なルール
│   │   ├── java-spring.mdc   # Java固有
│   │   ├── php.mdc          # PHP固有
│   │   ├── perl.mdc         # Perl固有
│   │   ├── python.mdc       # Python固有
│   │   └── database.mdc     # データベース設計
│   └── commands/             # 🆕 コマンドファイル
│       ├── dev.md           # 開発コマンド
│       ├── documentation.md # ドキュメント化コマンド
│       └── plan.md          # 計画コマンド
├── .claude/                  # Claude設定（プロジェクト固有）
│   ├── CLAUDE.md             # メインエントリーポイント
│   ├── settings.json         # Claude Desktop/Web設定
│   ├── commands/             # 🆕 コマンドファイル
│   │   ├── dev.md           # 開発コマンド
│   │   ├── documentation.md # ドキュメント化コマンド
│   │   └── plan.md          # 計画コマンド
│   ├── base/CLAUDE-base.md   # 基本設定
│   ├── skills/               # スキル（知識ライブラリ）
│   ├── agents/               # エージェント（実行アシスタント）
│   ├── languages/            # 言語別設定
│   ├── security/             # セキュリティポリシー
│   └── team/                 # チーム標準
├── .clinerules/              # Cline設定（プロジェクト固有）
│   ├── general.md            # 全般的なルール
│   ├── jujutsu.md            # Jujutsuルール
│   ├── java-spring.md        # Java固有
│   ├── php.md               # PHP固有
│   ├── python.md            # Python固有
│   ├── perl.md              # Perl固有
│   └── database.md          # データベース設計
├── AGENTS.md                 # シンプルな代替手段
└── src/                      # ソースコード
```

## 🔧 設定の特徴

### 共通設定
- **言語**: 日本語での応答
- **コード品質**: クリーンコード、SOLID原則
- **テスト**: カバレッジ95%以上
- **セキュリティ**: 入力検証、機密情報保護
- **批判的思考**: より良い判断のための否定的意見も含む

### Claude設定（settings.json）
- **セキュリティ**: 危険コマンド拒否、機密情報スキャン
- **Git統合**: コミットテンプレート、保護ブランチ設定
- **チーム設定**: レビュアー、コードオーナー管理
- **権限管理**: 安全なコマンドのみ許可
- **開発ツール**: bash, read, edit, write, glob, grep有効

### コマンドファイル（commands/）
- **@dev**: TDD開発、コードレビュー、リファクタリング支援
- **@documentation**: 世界レベルのドキュメント化戦略・テンプレート
- **@plan**: プロジェクト計画、要件定義、リスク管理
- **Claude・Cursor両対応**: 同一コマンドを両環境で利用可能
- **実践的テンプレート**: 即座に使える包括的なドキュメント体系

### スキル & エージェント

#### スキル（知識ライブラリ）
- **jujutsu**: ブランチ管理、コミット戦略、PR作成ガイド
- **ci-cd**: GitHub Actions/Screwdriverログ確認、トラブルシューティング
- **oss-license**: MIT/Apache/GPL等の分類、license-checker使用法
- **stable-version**: LTS判断、EOL対応、endoflife.date API活用
- **e2e-first-planning**: Walking Skeleton → MVP、縦割りタスク分割
- **design-review**: WCAG 2.1 AA、Core Web Vitals、レスポンシブ確認
- **changelog**: Keep a Changelog形式、Conventional Commits、SemVer、自動生成ツール（conventional-changelog/standard-version/git-chglog）
- **言語別スキル**: Java/PHP/Perl/Python開発のベストプラクティス

#### エージェント（実行アシスタント）
- **pr-resolver**: GitHub GraphQL APIでPRコメント自動resolve
- **oss-license-checker**: プロジェクトタイプ判定、ライセンス監査、代替提案
- **stable-version-auditor**: 技術スタック検出、リスク評価（Critical/Warning/Info）
- **e2e-first-planner**: ユーザーストーリーからE2Eスライス生成、計画出力
- **design-reviewer**: Playwright MCP連携、ブレークポイント別レビュー
- **changelog-generator**: git/jjコミット履歴解析、CHANGELOG.md生成、バージョン提案、GitHub Releases作成支援

### プロジェクト用Claude設定
- **プロジェクト最適化**: プロジェクト固有のワークフロー対応
- **チーム協業**: プロジェクトメンバー全員で統一設定
- **設定の優先順位**: プロジェクト設定 > グローバル設定
- **保護ブランチ拡張**: developブランチも追加保護
- **ディレクトリ別管理**: src/, tests/, docs/, config/別のコードオーナー

### 言語別設定

#### Java + Spring Boot
- Gradle 8.x、Rocky Linux 9
- NullAway（Null安全性チェック）
- JUnit 5 + Mockito
- Spring Security + JWT

#### PHP
- PHP 8.2+、PSR-12準拠
- Slim Framework（Laravelなし）
- PHPUnit + Phake（モック）
- Monolog（ロギング）
- MySQL/Oracle対応

#### Perl
- Perl 5.32+、モダンPerl
- Mojolicious、Moo/Moose
- Test::More + Test::Exception
- DBI（MySQL/Oracle）

#### Python
- Python 3.9+、型ヒント必須
- FastAPI、Pydantic
- pytest + pytest-asyncio
- SQLAlchemy（MySQL/PostgreSQL）

## ⚙️ Cursor User Rules 推奨設定

以下をCursorの設定（`Cmd/Ctrl + ,` → Cursor Settings → Rules）に追加することを推奨します：

```
# User Rules 推奨設定

1. タスクが完了したら、ターミナルからsayコマンドを実行して、音声で通知してください。
2. 回答は常に日本語で行ってください。
```

これにより、プロジェクト固有の設定と組み合わせて、より一貫した開発体験が得られます。

## 📚 ドキュメント

- [マイグレーションガイド](docs/migration-guide.md) - レガシースクリプトからプラグインシステムへの移行方法
- [シンプルガイド](docs/simple-guide.md) - 基本的な使い方
- [グローバル設定ガイド](docs/global-config-guide.md) - グローバル設定の詳細
- [Claude Import ガイド](docs/claude-import-guide.md) - @import構文の使い方
- [Cursor公式ガイド](docs/cursor-official-guide.md) - Project Rules仕様
- [**Clineルールガイド**](docs/cline-guide.md) - Cline（VSCode拡張）用ルール設定


## 🏢 エンタープライズ向け

プライベートリポジトリでの配布を行う場合は、インストーラースクリプト内の `REPO_URL` を変更してください：

```bash
# install-global.sh または install-project.sh の先頭で変更
REPO_URL="https://raw.githubusercontent.com/your-org/your-repo/main"
```

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチをプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照してください。

---

**注意**: このシステムは機密情報を含まず、設定ファイルのみを管理します。APIキーやパスワードなどの機密情報は別途管理してください。
