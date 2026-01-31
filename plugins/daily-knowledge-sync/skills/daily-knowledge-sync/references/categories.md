# 知識カテゴリ

このドキュメントは知識カテゴリ分類システムを定義します。

## カテゴリ構造

知識リポジトリはタグ付きmarkdownファイルを持つカテゴリベースのディレクトリ構造を使用します:

```
knowledge-repo/
├── errors/          # エラー解決とバグ修正
├── patterns/        # コーディングパターンとベストプラクティス
├── commands/        # 便利なコマンドとCLIツール
├── design/          # アーキテクチャと設計判断
├── domain/          # ドメイン固有の知識
└── operations/      # DevOps、メンテナンス、運用
```

各カテゴリには、カテゴリ横断の検索性のためのfrontmatterタグを持つmarkdownファイルが含まれます。

## カテゴリ定義

### errors/

**目的**: エラー解決とデバッグアプローチを文書化

**コンテンツタイプ**:
- エラーメッセージとその解決策
- バグ修正手順
- デバッグ技術
- よくある落とし穴とその回避方法

**例**:
- "Fix ModuleNotFoundError in Python imports"
- "Resolve CORS error in FastAPI"
- "Debug memory leak in Node.js application"

**キーワード**: error, exception, bug, fix, resolve, debug, traceback

---

### patterns/

**目的**: コーディングパターン、ベストプラクティス、実装アプローチを文書化

**コンテンツタイプ**:
- デザインパターン
- 実装戦略
- コード整理技術
- リファクタリングアプローチ
- アーキテクチャパターン

**例**:
- "Repository pattern for database access"
- "Use dependency injection for testability"
- "Implement circuit breaker for resilience"

**キーワード**: pattern, implementation, approach, best practice, design, architecture, refactor

---

### commands/

**目的**: 便利なコマンド、CLIツール、シェルスクリプトを文書化

**コンテンツタイプ**:
- Bash/シェルコマンド
- Gitワークフロー
- Dockerコマンド
- パッケージマネージャーの使用法
- ツール設定

**例**:
- "Use git rebase --onto for branch management"
- "Find and delete files older than 30 days"
- "Docker multi-stage build optimization"

**キーワード**: command, cli, bash, shell, terminal, git, npm, docker, script

---

### design/

**目的**: アーキテクチャ決定とシステム設計を文書化

**コンテンツタイプ**:
- アーキテクチャ図
- 設計判断とその根拠
- システム設計パターン
- データモデリング
- API設計

**例**:
- "Microservices vs. monolith trade-offs"
- "Event-driven architecture for async processing"
- "Database schema design for multi-tenancy"

**キーワード**: design, architecture, diagram, model, system, c4, sequence, mermaid

---

### domain/

**目的**: ドメイン固有の知識とビジネスロジックを文書化

**コンテンツタイプ**:
- ビジネスルール
- ドメインワークフロー
- 業界固有の知識
- 規制要件
- 製品仕様

**例**:
- "Payment processing workflow"
- "User authentication flow"
- "Compliance requirements for GDPR"

**キーワード**: domain, business, requirement, specification, workflow, process, rule

---

### operations/

**目的**: DevOps、メンテナンス、運用手順を文書化

**コンテンツタイプ**:
- デプロイ手順
- モニタリングセットアップ
- インシデント対応
- メンテナンスタスク
- CI/CDパイプライン
- インフラストラクチャ管理

**例**:
- "Blue-green deployment strategy"
- "Set up Prometheus monitoring"
- "Database backup and restore procedure"

**キーワード**: deploy, deployment, maintenance, operation, monitoring, ci/cd, devops, infrastructure

## カテゴリ分類ガイドライン

### 主カテゴリの選択

知識の**主な目的**を最もよく表すカテゴリを選択:

- 主にエラー修正に関するもの → `errors/`
- 主に実装方法に関するもの → `patterns/`
- 主にコマンドやツールの使用法に関するもの → `commands/`
- 主にシステム設計に関するもの → `design/`
- 主にビジネス/ドメインロジックに関するもの → `domain/`
- 主に運用/DevOpsに関するもの → `operations/`

### オーバーラップの処理

多くの知識項目は複数のカテゴリにまたがります。以下を使用:

1. **主カテゴリ**: ディレクトリ配置用
2. **タグ**: カテゴリ横断の発見性のため

例: "Deploy FastAPI with Docker"
- 主カテゴリ: `operations/` (デプロイに焦点)
- タグ: `[docker, fastapi, deployment, commands, devops]`

これにより、DockerコマンドやFastAPIパターンを検索するときに発見可能になります。

### カテゴリ移行

以下の場合、知識項目を再分類することができます:
- 元のカテゴリ分類が不明確だった
- 知識が進化して他の場所により適合するようになった
- 使用パターンが異なる検索方法を示している

移行プロセス:
1. ファイルを新しいカテゴリディレクトリに移動
2. frontmatterの`category`フィールドを更新
3. 必要に応じて元の場所にリダイレクトまたは注記を追加

## 自動カテゴリ分類

`categorize_knowledge.py`スクリプトは、キーワードスコアリングを使用してカテゴリを提案します。

**仕組み**:
1. テキストをカテゴリキーワードでスキャン
2. カテゴリごとのキーワードマッチ数をカウント
3. タグをより高い重みで考慮
4. 最高スコアのカテゴリを選択
5. 明確なマッチがない場合は`domain/`にフォールバック

**自動カテゴリ分類を上書き**するには、frontmatterでカテゴリを手動で指定します。

## 検索戦略

### カテゴリ横断で知識を見つける

以下の組み合わせを使用:

1. **カテゴリブラウジング**: 最も関連性の高いカテゴリディレクトリから開始
2. **タグ検索**: すべてのカテゴリでタグを検索
3. **全文検索**: `grep`またはリポジトリ検索でキーワードを検索
4. **関連リンク**: 知識ファイルの「Related」セクションをフォロー

検索ワークフローの例:

**エラー解決策を見つける**:
```bash
# errorsディレクトリをブラウズ
ls errors/

# 特定のエラーを検索
grep -r "ModuleNotFoundError" errors/

# タグを使用してすべてのカテゴリを検索
grep -r "tags: \[.*python.*import.*\]" .
```

**実装パターンを見つける**:
```bash
# patternsディレクトリをブラウズ
ls patterns/

# 認証パターンを検索
grep -r "authentication" patterns/ design/

# タグで検索
grep -r "tags: \[.*authentication.*security.*\]" .
```

## ベストプラクティス

1. **1つの主カテゴリを選択** - カテゴリ間でファイルを重複させない
2. **タグを自由に使用** - カテゴリ横断の発見を助ける
3. **関連知識をリンク** - 知識グラフを構築
4. **カテゴリのバランスを保つ** - 1つが大きくなりすぎたら、サブカテゴリを検討
5. **レビューとリファクタリング** - 定期的にカテゴリ分類の正確性をレビュー
