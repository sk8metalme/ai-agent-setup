# 知識カテゴリ

このドキュメントは知識カテゴリ分類システムを定義します。

## カテゴリ構造

知識リポジトリはタグ付きmarkdownファイルを持つ3つの主要カテゴリで構成されます:

```
knowledge-repo/
├── errors/          # エラー解決、デバッグ、バグ修正
├── ops/             # 運用、DevOps、インフラ、便利コマンド
└── domain/          # ドメイン知識、設計判断、ビジネスロジック
```

各カテゴリには、カテゴリ横断の検索性のためのfrontmatterタグを持つmarkdownファイルが含まれます。

## カテゴリ定義

### errors/

**目的**: エラー解決、デバッグ、バグ修正を文書化

**採用基準**:
- 実際のスタックトレースを含む
- エラーメッセージと解決策がセット
- 再現可能な問題と修正方法が記載されている

**コンテンツタイプ**:
- エラーメッセージとその解決策
- バグ修正手順
- デバッグ技術
- スタックトレース付きのエラー対応

**例**:
- "Fix ModuleNotFoundError in Python imports with stack trace"
- "Resolve CORS error in FastAPI: detailed solution"
- "Debug memory leak in Node.js application with profiling"

**キーワード**: error, exception, bug, fix, resolve, debug, traceback, stack trace

**除外される例**:
- 単に"error"という単語を含むだけのメッセージ
- スタックトレースのない曖昧なエラー言及
- 解決策のないエラー報告

---

### ops/

**目的**: 運用、DevOps、インフラ、便利なコマンドを文書化

**採用基準**:
- 複雑なコマンド操作（単純な`ls`や`cd`は除外）
- インフラ構築・設定手順
- CI/CD、デプロイ手順

**コンテンツタイプ**:
- 便利なコマンドとCLIツール
- Gitワークフロー
- Dockerコマンド
- デプロイ手順
- モニタリングセットアップ
- CI/CDパイプライン
- インフラストラクチャ管理

**例**:
- "Use git rebase --onto for branch management"
- "Docker multi-stage build optimization"
- "Blue-green deployment strategy"
- "Set up Prometheus monitoring"

**キーワード**: command, cli, bash, shell, git, docker, deploy, deployment, ci/cd, devops, infrastructure, monitoring, operation

**除外される例**:
- 単純なファイル操作コマンド（`ls`, `cd`, `cat`など）
- 説明のないコマンドの羅列
- 一時的な実行ログ

---

### domain/

**目的**: ドメイン知識、設計判断、ビジネスロジックを文書化

**採用基準**:
- アーキテクチャ決定とその根拠
- ビジネスロジックの説明
- 設計パターンの適用理由

**コンテンツタイプ**:
- アーキテクチャ図と設計判断
- デザインパターンとベストプラクティス
- ビジネスルール
- ドメインワークフロー
- 業界固有の知識
- API設計とデータモデリング

**例**:
- "Microservices vs. monolith trade-offs for our use case"
- "Repository pattern for database access: implementation guide"
- "Payment processing workflow with security considerations"
- "Event-driven architecture for async processing"

**キーワード**: pattern, implementation, approach, best practice, design, architecture, refactor, diagram, model, c4, domain, business, requirement, specification, workflow

**除外される例**:
- 根拠のない設計メモ
- 一時的な実装アイデア
- コンテキストのない図

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
