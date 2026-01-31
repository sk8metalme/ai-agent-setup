---
name: daily-knowledge-sync
description: 日々のClaude Code会話から知識を自動抽出し、GitHubリポジトリに同期します。JSONL会話ログを分析し、価値ある知見（エラー解決、コーディングパターン、便利なコマンド、設計判断、ドメイン知識、運用）を特定し、70%類似度閾値で重複をチェックし、カテゴリ分類された知識ベースにコミットします。1日1回、Claude Code起動時または「おはよう」の挨拶時にトリガーされます。
---

# Daily Knowledge Sync

Claude Codeの会話から自動的に知識を収集し、検索可能でカテゴリ分類された知識リポジトリを構築します。

## 概要

このスキルは、前日のClaude Code会話ログ（`~/.claude/projects/`内のJSONLファイル）を分析し、価値ある知識項目を抽出し、カテゴリ分類し、重複をチェックし、GitHubリポジトリにコミットします。1日1回、最初のClaude Codeセッションで実行されます。

**抽出される内容**:
- エラー解決とデバッグの知見
- コーディングパターンとベストプラクティス
- 便利なコマンドとCLIワークフロー
- 設計判断とアーキテクチャの知見
- ドメイン固有の知識
- DevOpsと運用手順

**主な機能**:
- 🔄 自動的な日次実行
- 🏷️ カテゴリベースの整理 + タグメタデータ
- 🔍 重複検出のための70%類似度閾値
- 📝 構造化されたmarkdown形式
- 🔐 バージョン管理のためのGit統合

## 実行ガイドライン

> **⚠️ 重要**: このスキルは**完全自律実行**を前提としています。以下のガイドラインを**厳守**してください。

### 🚨 自律的な作業進行（必須）

**このスキル実行中は、ユーザーへの質問・確認を一切行わないでください。**

- **質問禁止**: AskUserQuestion ツールの使用禁止。すべての判断を自律的に行う
- **確認不要**: 「これでよいですか？」「続けてよいですか？」などの確認メッセージは出力しない
- **自己判断**: 知識として価値があるかどうかは、以下の基準で自分で判断する：
  - 再利用可能な知見か？ → Yes なら追加
  - 特定の問題を解決するか？ → Yes なら追加
  - 将来参照したいか？ → Yes なら追加
  - 迷った場合 → **追加する方向で判断**（除外より追加を優先）

### 🚨 完了までの継続（必須）

**Step 0 から Step 10 まで、必ずすべてのステップを完了させてください。途中で停止しないでください。**

- **全ステップ必須**: Step 0（コーヒータイム）〜 Step 10（コーヒー豆紹介）まで、一つも省略しない
- **中断禁止**: 途中で「完了しました」と報告して終わらない。必ず Step 10 まで実行
- **エラー回復**: エラーが発生しても可能な限り回復して続行。致命的なエラー（リポジトリ未設定など）の場合のみ停止
- **最終確認**: Step 10 のコーヒー豆紹介を出力して初めて「完了」とする

### サブエージェント活用（効率化・推奨）

複数のセッションログを参照する際は、サブエージェントを活用して効率化することを検討してください。

- **複数セッションログの並列処理**: `~/.claude/projects/` 配下に複数のプロジェクトディレクトリがある場合、Task ツールでサブエージェントを活用して並列に分析
- **活用パターン例**:
  - 各プロジェクトディレクトリごとに Explore エージェントで内容を調査
  - 複数の JSONL ファイルを並列に読み込み・分析
- **判断基準**: 3つ以上のセッションログがある場合は並列処理を検討、2つ以下なら直列処理で十分

## ワークフロー

### Step 0: コーヒーでひと息 ☕

知識同期を始める前に、まずはコーヒーでも飲んでリラックスしましょう。

```
        ) )
       ( (
     ........
     |      |]
     \      /
      `----'
```

おはようございます！今日も素敵な1日になりますように。
コーヒーを片手に、昨日の会話から得られた知見を整理していきましょう。

準備ができたら、次のステップに進んでください。

### Step 1: 今日実行すべきか確認

まず、スキルを実行すべきか確認します（1日1回）:

```bash
python scripts/manage_daily_trigger.py check
```

終了コードが0なら続行、1なら今日は既に実行済みです。

### Step 2: リポジトリの設定（初回のみ）

まだ設定していない場合、知識リポジトリをセットアップします:

**オプションA: 既存のリポジトリを使用**

1. 知識リポジトリをローカルにクローン:
   ```bash
   git clone <your-knowledge-repo-url> ~/knowledge-base
   ```

2. 後で使用するためにリポジトリパスをメモしておく

**オプションB: 新しいリポジトリを作成**

1. 新しいGitHubリポジトリを作成（例: `my-knowledge-base`）

2. ローカルにクローン:
   ```bash
   git clone <repo-url> ~/knowledge-base
   ```

3. 構造を初期化:
   ```bash
   cd ~/knowledge-base
   mkdir -p errors patterns commands design domain operations
   git add .
   git commit -m "docs: Initialize knowledge base structure"
   git push origin main
   ```

**設定変数**（これらを覚えておいてください）:
- `KNOWLEDGE_REPO_PATH`: 知識リポジトリのローカルパス（例: `~/knowledge-base`）
- `KNOWLEDGE_REPO_URL`: GitHubリポジトリのURL

### Step 3: 知識候補の抽出

前日のJSONLファイルから潜在的な知識項目を抽出:

```bash
# 昨日分を抽出（デフォルト）
python scripts/extract_knowledge.py

# または日付を指定
python scripts/extract_knowledge.py 2026-01-30
```

これは `/tmp/knowledge_candidates_YYYY-MM-DD.json` に出力されます。

**候補をレビュー**して、何が抽出されたかを理解します。

### Step 4: 知識の分析と統合

抽出されたJSON内の各候補について:

1. **候補を読む**:
   - `text`: 会話の内容
   - `role`: userまたはassistant
   - `tool_uses`: 使用されたツール
   - `errors`: エラーメッセージ

2. **価値ある知識かどうか判断**:
   - 再利用可能な知見か？
   - 特定の問題を解決するか？
   - 将来参照したいか？

3. **知識形式に統合**:
   - 明確なタイトルを作成
   - コンテキストセクションを書く
   - 問題/トピックを記述
   - 解決策/知見を文書化
   - 該当する場合は関連リンクを追加

4. **タグを割り当て**:
   - 技術タグ（python, docker, git）
   - ドメインタグ（api, database, testing）
   - タイプタグ（error-fix, best-practice）
   - 詳細は [references/knowledge_format.md](references/knowledge_format.md) を参照

### Step 5: 知識のカテゴリ分類

各知識項目について、カテゴリを決定:

```python
from scripts.categorize_knowledge import KnowledgeCategorizer

categorizer = KnowledgeCategorizer(KNOWLEDGE_REPO_PATH)

category = categorizer.categorize(
    text=knowledge_content,
    tags=knowledge_tags
)
```

カテゴリ:
- `errors`: エラー解決
- `patterns`: コーディングパターンとベストプラクティス
- `commands`: CLIコマンドとツール
- `design`: アーキテクチャと設計判断
- `domain`: ビジネス/ドメイン知識
- `operations`: DevOpsとメンテナンス

カテゴリ分類ガイドラインは [references/categories.md](references/categories.md) を参照してください。

### Step 6: 重複のチェック

新しい知識ファイルを作成する前に、重複をチェック:

```python
from scripts.check_similarity import SimilarityChecker

checker = SimilarityChecker(threshold=0.7)

# カテゴリ内の既存ファイルと照合
category_dir = Path(KNOWLEDGE_REPO_PATH) / category
for existing_file in category_dir.glob("*.md"):
    duplicates = checker.check_knowledge_file(
        new_text=knowledge_content,
        knowledge_file=existing_file
    )

    if duplicates:
        # 重複を処理: スキップ、マージ、またはユーザーに確認
        print(f"Found similar knowledge: {duplicates[0]['section']}")
```

**重複処理のオプション**:
1. **スキップ**: 非常に類似している場合（>90%）
2. **マージ**: 補完的な場合（70-90%）
3. **新規作成**: 十分に異なる場合（<70%）

### Step 7: 知識ファイルの作成

重複していない知識について:

```python
from datetime import datetime
from scripts.categorize_knowledge import KnowledgeCategorizer

categorizer = KnowledgeCategorizer(KNOWLEDGE_REPO_PATH)
date = datetime.now().strftime("%Y-%m-%d")

filename = categorizer.generate_filename(
    title=knowledge_title,
    date=date
)

file_path = categorizer.create_knowledge_file(
    category=category,
    filename=filename,
    title=knowledge_title,
    content=knowledge_content,
    tags=knowledge_tags,
    metadata={
        "date": date,
        "source": "conversation",
    }
)

print(f"Created: {file_path}")
```

形式の詳細は [references/knowledge_format.md](references/knowledge_format.md) を参照してください。

### Step 8: GitHubへのコミットとプッシュ

すべての知識ファイルを作成した後:

```bash
cd $KNOWLEDGE_REPO_PATH

# 変更をステージング
git add errors/ patterns/ commands/ design/ domain/ operations/

# コミットメッセージ用のユーザー名を取得
USERNAME=$(git config user.name)
DATE=$(date +%Y-%m-%d)

# 標準形式でコミット
git commit -m "docs: $USERNAME $DATE

Daily knowledge sync from Claude Code conversations.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# mainブランチにプッシュ
git push origin main
```

### Step 9: 今日実行済みとしてマーク

正常に完了した後、今日を処理済みとしてマーク:

```bash
python scripts/manage_daily_trigger.py mark
```

これにより、明日まで再実行されないようになります。

### Step 10: 今日のコーヒー豆 🌍

お疲れさまでした！知識同期が完了しました。

最後に、世界のコーヒーから今日の1杯をご紹介します。
[references/coffee_beans.md](references/coffee_beans.md) からランダムに1つ選んで紹介してください。

**紹介フォーマット例**:

---

☕ **本日のコーヒー: エチオピア イルガチェフェ**

| 項目 | 評価 |
|------|------|
| 苦さ | ★★☆☆☆ |
| 酸味 | ★★★★☆ |
| 香り | ★★★★★ |
| コク | ★★★☆☆ |
| 甘み | ★★★★☆ |

**特徴**: フローラル、フルーティー、紅茶のような上品さ

**おすすめの飲み方**: ハンドドリップ

**ひとこと**: コーヒー発祥の地エチオピアが誇る最高級品種。標高2000m以上の高地で栽培され、花のような華やかな香りが特徴です。

---

また明日も、新しい知見と美味しいコーヒーをお楽しみに！☕

## 設定リファレンス

### 環境変数（オプション）

`~/.bashrc` または `~/.zshrc` に設定できます:

```bash
export KNOWLEDGE_REPO_PATH="$HOME/knowledge-base"
export KNOWLEDGE_REPO_URL="https://github.com/username/knowledge-base"
export KNOWLEDGE_SIMILARITY_THRESHOLD="0.7"  # デフォルト: 0.7
```

### スキル状態ファイル

- `~/.claude/daily_knowledge/last_run.txt`: 最終実行日を追跡

### リポジトリ構造

```
knowledge-base/
├── errors/
│   ├── README.md
│   ├── 2026-01-31_fix_import_error.md
│   └── 2026-01-30_resolve_cors_issue.md
├── patterns/
│   ├── README.md
│   └── 2026-01-31_dependency_injection.md
├── commands/
│   ├── README.md
│   └── 2026-01-31_git_rebase_onto.md
├── design/
│   ├── README.md
│   └── 2026-01-30_microservices_design.md
├── domain/
│   ├── README.md
│   └── 2026-01-29_payment_workflow.md
└── operations/
    ├── README.md
    └── 2026-01-31_docker_deployment.md
```

## カスタマイズ

### 類似度閾値の調整

SimilarityCheckerを作成する際に閾値を編集:

```python
# より厳格（検出される重複が少ない）
checker = SimilarityChecker(threshold=0.8)

# より寛容（検出される重複が多い）
checker = SimilarityChecker(threshold=0.6)
```

### カスタムカテゴリ

`scripts/categorize_knowledge.py` を編集してカスタムカテゴリを追加:

```python
CATEGORY_KEYWORDS = {
    # 既存のカテゴリ...
    "security": ["security", "vulnerability", "auth", "encryption"],
    "performance": ["performance", "optimization", "speed", "memory"],
}
```

その後、リポジトリにディレクトリを作成してください。

### 会話のフィルタリング

特定のプロジェクトを抽出から除外するには、`extract_knowledge.py` を変更:

```python
def find_jsonl_files(self, target_date: str) -> list[Path]:
    jsonl_files = []

    # 特定のディレクトリをスキップ
    exclude_dirs = ["test-project", "scratch"]

    for jsonl_file in self.projects_dir.rglob("*.jsonl"):
        if any(excl in str(jsonl_file) for excl in exclude_dirs):
            continue
        jsonl_files.append(jsonl_file)

    return jsonl_files
```

## トラブルシューティング

### スキルが1日に複数回実行される

トリガー状態を確認:
```bash
python scripts/manage_daily_trigger.py status
```

必要に応じてリセット:
```bash
rm ~/.claude/daily_knowledge/last_run.txt
```

### 候補が抽出されない

JSONLファイルが存在することを確認:
```bash
ls -la ~/.claude/projects/*/
```

日付形式を確認:
```bash
python scripts/extract_knowledge.py 2026-01-31
```

### 類似度チェックが機能しない

scikit-learnがインストールされていない場合:
```bash
pip install scikit-learn
```

scikit-learnが利用できない場合、スクリプトは単純な単語ベースの類似度にフォールバックします。

### Gitプッシュが失敗する

認証されていることを確認:
```bash
gh auth status  # GitHub CLI用
# またはSSHキーを設定
```

リモートに変更がある場合、プッシュ前にプル:
```bash
cd $KNOWLEDGE_REPO_PATH
git pull origin main --rebase
git push origin main
```

### カテゴリが自動検出されない

カテゴリはキーワードマッチングに基づいています。自動分類が失敗する場合:

1. コンテンツにキーワードが含まれているか確認
2. ファイル作成時に手動でカテゴリを指定
3. `categorize_knowledge.py` にカスタムキーワードを追加

## ベストプラクティス

1. **プッシュ前にレビュー**: コミット前に抽出された知識を必ずレビュー
2. **タイトルを洗練**: タイトルを具体的で検索可能にする
3. **コンテキストを追加**: この知識がなぜ重要かを含める
4. **関連項目をリンク**: 知識項目間の接続を構築
5. **タグを豊富に使用**: タグ不足よりタグ過多の方が良い
6. **重複をクリーンアップ**: 定期的に類似項目をレビューしてマージ
7. **既存知識を更新**: 重複作成よりも既存項目の更新を優先

## 他スキルとの連携

このスキルは以下と相性が良いです:

- **/guardrail-builder**: 繰り返しパターンからルールを自動作成
- **/michi:dev**: TDDワークフロー中の開発知見をキャプチャ
- **Code Reviewスキル**: レビューの学びを抽出

## リソース

詳細な形式仕様については、同梱のリファレンスファイルを参照してください:

- **[references/knowledge_format.md](references/knowledge_format.md)**: Markdown形式、frontmatter、タグ戦略
- **[references/categories.md](references/categories.md)**: カテゴリ定義、分類ガイドライン、検索戦略
