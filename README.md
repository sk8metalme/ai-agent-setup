# AI Agent Setup

生成AIエージェント（Claude、Cursor、Cline）の設定ファイルを簡単に配布・セットアップできるシステムです。

## 📋 概要

このプロジェクトでは、以下の2つの配布方式を提供しています：

### 🌐 グローバル設定（Claude用）
- **配置場所**: `~/.claude/`
- **用途**: チーム共通の基本設定、セキュリティポリシー、言語別設定
- **特徴**: `@import`構文でモジュール化、一度設定すれば全プロジェクトで利用可能

### 📁 プロジェクト設定（Cursor/AGENTS.md用）
- **配置場所**: プロジェクトルート
- **用途**: プロジェクト固有の設定、開発チーム向け
- **特徴**: `.cursor/rules/*.mdc`形式またはシンプルな`AGENTS.md`

## 🚀 クイックスタート

### グローバル設定（Claude用）

```bash
# Claude グローバル設定を対話的にインストール（推奨）
bash <(curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh)

# 非対話でインストールする場合（デフォルトを環境変数で指定）
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh | LANGUAGE_CHOICE=5 bash
# または
LANGUAGE_CHOICE=5 bash <(curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh)

# 実行前に影響を確認したい場合
bash <(curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh) --plan
# または
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh | LANGUAGE_CHOICE=5 bash -s -- --plan
```

- 手動実行時はテキストメニューで選択肢を確認できる対話モードの利用を推奨します。
- 自動化など非対話で実行する場合は `LANGUAGE_CHOICE=1..5` で言語テンプレートを指定してください（未指定時は自動的に「すべて」を取得）。
- **環境変数の渡し方**: `ENV=value bash` の形式で環境変数をbashプロセスに渡してください。パイプ使用時は `| ENV=value bash` の順序で記述。
- 実行前に影響をレビューしたい場合は `--plan`（差分表示）を付与すると、既存環境との違いを可視化できます。

### プロジェクト設定（Cursor/AGENTS.md用）

```bash
# プロジェクト用設定を対話的にインストール（推奨）
bash <(curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-project.sh)

# 非対話でインストールする場合
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-project.sh | PROJECT_CONFIG_TYPE=3 PROJECT_LANGUAGE_CHOICE=5 bash
# または
PROJECT_CONFIG_TYPE=3 PROJECT_LANGUAGE_CHOICE=5 bash <(curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-project.sh)

# 実行前に影響を確認したい場合
bash <(curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-project.sh) --plan
# または
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-project.sh | PROJECT_CONFIG_TYPE=3 PROJECT_LANGUAGE_CHOICE=5 bash -s -- --plan
```

- 非対話で実行する場合は `PROJECT_CONFIG_TYPE=1..3` と `PROJECT_LANGUAGE_CHOICE=1..5` を指定してインストール対象を制御できます（未指定時は両方／すべてを取得）。
- **環境変数の渡し方**: `ENV=value bash` の形式で環境変数をbashプロセスに渡してください。複数の環境変数は `ENV1=value1 ENV2=value2 bash` の形式。
- 実行前の確認には `--plan`（詳細差分）を使用すると既存ファイルへの影響を把握できます。

## 🎯 対応言語・フレームワーク

| 言語 | フレームワーク | 特徴 |
|------|---------------|------|
| **Java** | Spring Boot 3.x + Gradle | エンタープライズ開発、NullAway、Rocky Linux |
| **PHP** | Slim Framework + Composer | 軽量API、Monolog、Phake、MySQL/Oracle |
| **Perl** | Mojolicious + Modern Perl | スクリプト・Web、モダンPerl機能 |
| **Python** | FastAPI + Poetry | 高速API、型ヒント、非同期処理 |

## 📁 インストール後のファイル配置

### グローバル設定（Claude）
```
~/.claude/
├── CLAUDE.md                    # メインエントリーポイント
├── settings.json               # Claude Desktop/Web設定
├── commands/                    # コマンドファイル
│   ├── dev.md                  # 開発コマンド
│   ├── documentation.md        # ドキュメント化コマンド
│   └── plan.md                 # 計画コマンド
├── base/CLAUDE-base.md         # 基本設定
├── team/CLAUDE-team-standards.md # チーム標準
├── security/CLAUDE-security-policy.md # セキュリティポリシー
└── languages/
    ├── java-spring/CLAUDE-java-spring.md
    ├── php/CLAUDE-php.md
    ├── perl/CLAUDE-perl.md
    └── python/CLAUDE-python.md

~/.cursor/commands/              # Cursor用コマンドファイル
├── dev.md                      # 開発コマンド
├── documentation.md            # ドキュメント化コマンド
└── plan.md                     # 計画コマンド

~/Documents/Cline/Rules/        # Cline用グローバルルール
├── general.md                  # 全般的なルール
├── jujutsu.md                  # Jujutsuルール（SSOT）
├── java-spring.md              # Java固有
├── php.md                      # PHP固有
├── python.md                   # Python固有
├── perl.md                     # Perl固有
└── database.md                 # データベース設計
```

### 配布用テンプレート（本プロジェクト）
```
ai-agent-setup/
├── .cursor/                     # Cursor設定テンプレート
│   └── rules/
│       ├── general.mdc          # 全般的なルール
│       ├── jujutsu.mdc          # Jujutsuルール（SSOT）
│       ├── java-spring.mdc      # Java固有
│       ├── php.mdc             # PHP固有
│       ├── python.mdc          # Python固有
│       ├── perl.mdc            # Perl固有
│       └── database.mdc        # データベース設計
├── .clinerules/                 # Cline設定テンプレート
│   ├── general.md               # 全般的なルール
│   ├── jujutsu.md               # Jujutsuルール
│   ├── java-spring.md           # Java固有
│   ├── php.md                  # PHP固有
│   ├── python.md               # Python固有
│   ├── perl.md                 # Perl固有
│   └── database.md             # データベース設計
├── .claude/                     # Claude設定テンプレート
│   ├── CLAUDE.md               # メインエントリーポイント
│   ├── settings.json           # Claude Desktop/Web設定
│   ├── base/CLAUDE-base.md     # 基本設定
│   ├── languages/              # 言語別設定
│   ├── security/               # セキュリティポリシー
│   └── team/                   # チーム標準
├── project-config/             # プロジェクト用設定
│   ├── claude-import/          # プロジェクト用Claude import
│   └── claude-settings/        # プロジェクト用Claude settings
├── AGENTS.md                   # シンプル設定
├── install-global.sh           # グローバル設定インストーラー
└── install-project.sh          # プロジェクト設定インストーラー
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
