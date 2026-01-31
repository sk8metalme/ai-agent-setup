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

**このスキル実行中は、原則としてユーザーへの質問・確認を一切行わないでください。ただし、Step 3の初回設定が未完了の場合のみ、ユーザーへの確認を許容します。**

- **質問・確認禁止**: ユーザーへの質問や確認メッセージを出力しない（AskUserQuestion ツールの使用も不可）
  - **例外**: Step 3（リポジトリの設定）が未完了の場合、リポジトリURLやパスの確認は許可
- **自己判断**: 知識として価値があるかどうかは、**Step 5 の判断基準**に従って自分で判断する
  - 迷った場合 → **追加する方向で判断**（除外より追加を優先）
  - ただし、Step 7 で 90% 以上の類似度が検出された場合はスキップを優先

### 🚨 完了までの継続（必須）

**コーヒータイムから最終のコーヒー豆紹介まで、必ずすべてのステップを完了させてください。途中で停止しないでください。**

- **全ステップ必須**: コーヒータイムから最終のコーヒー豆紹介まで、一つも省略しない
- **中断禁止**: 途中で「完了しました」と報告して終わらない。必ず最終ステップまで実行
- **エラー回復**: エラーが発生しても可能な限り回復して続行。致命的なエラー（リポジトリ未設定など）の場合のみ停止
- **最終確認**: コーヒー豆紹介を出力して初めて「完了」とする

### 🚨 パス検証の判断基準（AIエージェント向け）

**スクリプト存在確認で誤判断を防ぐため、以下の基準を厳守してください:**

1. **SKILL_BASE の取得方法**:
   - スキル読み込み時に表示される "Base directory for this skill" の値を使用
   - **推測でパスを設定しない**（例: プラグインルートパスから推測しない）
   - 不明な場合は、Read ツールでスキルファイルのパスを確認してから親ディレクトリを取得

2. **スクリプト確認の正しい方法**:
   - 必須スクリプト6個を**個別に確認**（`ls` でディレクトリを表示するだけでは不十分）
   - 各スクリプトごとに `✅`/`❌` を表示
   - 1つでも `❌` があれば「スクリプトが見つからない」と判断

3. **よくある間違い**:
   - ❌ `ls "$SKILL_BASE/scripts/"` の出力が空 → 「見つからない」と誤判断
   - ❌ スクリプトパスを `scripts/xxx.py` で指定（相対パス）
   - ❌ 古いバージョンにフォールバック（指定されたバージョンを優先）
   - ✅ 各スクリプトを `-f` で個別確認 → 正確な判断

4. **フォールバック不要の原則**:
   - 指定された SKILL_BASE のバージョンを**必ず使用**
   - 古いバージョンへのフォールバックは不要（スクリプトが見つからない場合はエラーとして報告）

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

### Step 1: 前提条件の確認

スキル実行前に、必要な設定を確認します。

#### 1-1. 環境変数の確認

```bash
echo "KNOWLEDGE_REPO_PATH: ${KNOWLEDGE_REPO_PATH:-未設定}"
echo "KNOWLEDGE_REPO_URL: ${KNOWLEDGE_REPO_URL:-未設定}"
```

- **設定済み** → その値を使用して続行
- **未設定** → Step 3（リポジトリの設定）で設定が必要

#### 1-2. Base Directoryの確認

このスキルのスクリプトは、Base directory からの相対パスで参照します。

**SKILL_BASE の取得方法**:

スキル読み込み時に以下のような表示があります:
```
Base directory for this skill: /Users/username/.claude/plugins/cache/ai-agent-setup/daily-knowledge-sync/1.5.0/skills/daily-knowledge-sync
```

この値を `SKILL_BASE` として使用します:

```bash
# 例: スキル読み込み時の表示から取得
SKILL_BASE="/Users/username/.claude/plugins/cache/ai-agent-setup/daily-knowledge-sync/1.5.0/skills/daily-knowledge-sync"
```

**重要**:
- **推測でパスを設定しないこと**（プラグインルートからの推測は不正確）
- 不明な場合は、Read ツールでこのスキルファイル自体のパスを確認し、親ディレクトリを取得

#### 1-3. スクリプト個別確認

必須スクリプト6個を**個別に確認**します（`ls` でディレクトリを表示するだけでは不十分）:

```bash
REQUIRED_SCRIPTS=(
  "extract_knowledge.py"
  "evaluate_knowledge.py"
  "process_knowledge_batch.py"
  "categorize_knowledge.py"
  "check_similarity.py"
  "manage_daily_trigger.py"
)

echo "=== スクリプト確認 ==="
for script in "${REQUIRED_SCRIPTS[@]}"; do
  if [ -f "$SKILL_BASE/scripts/$script" ]; then
    echo "✅ $script"
  else
    echo "❌ $script"
  fi
done
```

**判断基準**:
- すべて `✅` → Step 2 へ進む
- 1つでも `❌` → エラーとして報告（フォールバック不要）

#### 1-4. リポジトリの状態確認

```bash
REPO_PATH="${KNOWLEDGE_REPO_PATH:-$HOME/knowledge-base}"
if [ -d "$REPO_PATH" ]; then
  echo "✅ リポジトリ存在: $REPO_PATH"
  cd "$REPO_PATH" && git status
else
  echo "❌ リポジトリ未設定 → Step 3 へ"
fi
```

### Step 2: 今日実行すべきか確認

まず、スキルを実行すべきか確認します（1日1回）:

```bash
python "$SKILL_BASE/scripts/manage_daily_trigger.py" check
```

終了コードが0なら続行、1なら今日は既に実行済みです。

### Step 3: リポジトリの設定（初回のみ）

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

### Step 4: 知識候補の抽出

前日のJSONLファイルから潜在的な知識項目を抽出:

```bash
# 昨日分を抽出（デフォルト）
python "$SKILL_BASE/scripts/extract_knowledge.py"

# または日付を指定
python "$SKILL_BASE/scripts/extract_knowledge.py" 2026-01-30
```

これは `/tmp/knowledge_candidates_YYYY-MM-DD.json` に出力されます。

**候補をレビュー**して、何が抽出されたかを理解します。

**日次まとめ用の記録**:
以下の情報を記録してください（Step 11-1で使用）:
- 対象日（YYYY-MM-DD形式）
- 作業リポジトリ一覧（`source_file`パスからリポジトリパスをデコード）
- 知識候補件数（抽出された候補の総数）

### Step 5: 知識の評価とバッチ処理（スコアリングシステム v1.4.0+）

**v1.4.0以降では、スコアリングシステムによる自動評価を使用します。**

抽出された候補（`/tmp/knowledge_candidates_YYYY-MM-DD.json`）を、スコアリングエンジンで評価・処理します。

#### 5-1. バッチ処理の実行

```bash
# バッチ処理スクリプトを実行
CANDIDATES_FILE="/tmp/knowledge_candidates_$(date -v-1d +%Y-%m-%d).json"
REPO_PATH="${KNOWLEDGE_REPO_PATH:-$HOME/knowledge-base}"

python "$SKILL_BASE/scripts/process_knowledge_batch.py" \
  "$CANDIDATES_FILE" \
  "$REPO_PATH" \
  --date "$(date -v-1d +%Y-%m-%d)"
```

このスクリプトは以下を自動実行します:
1. **評価**: スコアリングエンジンで0-100点評価
2. **除外パターンチェック**: 完了報告、挨拶、実行ログなどを除外
3. **閾値判定**: 60点以上のみ採用（accept）
4. **類似度チェック**: 既存知識と70%以上類似していれば重複として除外
5. **カテゴリ分類**: 3カテゴリ（errors, ops, domain）に自動分類
6. **ファイル作成**: Markdownファイルを生成
7. **Git コミット**: 自動的にコミット

#### 5-2. スコアリング基準（詳細は config/ 参照）

**ポジティブスコア（加点）**:
- エラー解決（スタックトレース含む）: +20点
- 問題解決（解決策含む）: +25点
- 便利なツール使用（grep, jq, docker等）: +15点
- コード例を含む: +15点
- ベストプラクティス言及: +15点
- 複数ステップの手順: +10点

**ネガティブスコア（減点）**:
- 進行中・未完了（WIP, TODO）: -15点
- コンテキスト不足: -20点
- 質問のみ（回答なし）: -10点

**除外パターン**:
- 完了報告（「完了だぜ」「タスク完了」等）
- 挨拶・相槌（「なるほど」「よし」等）
- 実行ログ（`Running...`, `Step 1/3`等）
- システムメッセージ
- 最小文字数: 80文字未満

**カテゴリ（6→3に削減）**:
- **errors/**: エラー解決、デバッグ、バグ修正
- **ops/**: 運用、DevOps、インフラ、便利コマンド（旧 commands + operations）
- **domain/**: ドメイン知識、設計判断、ビジネスロジック（旧 patterns + design + domain）

#### 5-3. 処理結果の確認

バッチ処理後、以下の統計が表示されます:

```
==================================================
SUMMARY
==================================================
Total candidates: 150
  ✅ Accepted:  25
  ❌ Rejected:  110
  ⚠️  Duplicates: 15
  📝 Created:   25
```

**日次まとめ用の記録**:
以下の情報を記録してください（Step 11-1で使用）:
- 作成されたファイル数と主なトピック
- 高スコア（80点以上）の知識項目
- 除外された候補の主な理由（統計から）

### Step 6: （削除）カテゴリ分類はStep 5で自動実行

**v1.4.0以降、このステップは不要です。** Step 5のバッチ処理で自動的にカテゴリ分類されます。

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

**日次まとめ用の記録**:
以下の情報を記録してください（Step 11-1で使用）:
- カテゴリ別の件数分布
- カテゴリごとの主なトピック概要

### Step 7: 重複のチェック

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

**日次まとめ用の記録**:
以下の情報を記録してください（Step 11-1で使用）:
- スキップされた知識候補の数（重複により除外）

### Step 8: 知識ファイルの作成

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

**日次まとめ用の記録**:
以下の情報を記録してください（Step 11-1で使用）:
- 作成した知識ファイルの一覧（カテゴリ/ファイル名）
- 作成した知識ファイルの総数

### Step 9: GitHubへのコミットとプッシュ

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

### Step 10: 今日実行済みとしてマーク

正常に完了した後、今日を処理済みとしてマーク:

```bash
python "$SKILL_BASE/scripts/manage_daily_trigger.py" mark
```

これにより、明日まで再実行されないようになります。

### Step 11: 知識同期完了と日次まとめ

お疲れさまでした！知識同期が完了しました。

#### Step 11-1: 日次まとめの出力

Step 4-8で記録した情報を使用して、日次まとめを出力してください。

**参照**: [references/daily_summary_format.md](references/daily_summary_format.md) のテンプレートとタスク推測ロジックを使用してください。

**出力内容**:
1. 実行サマリー（対象日、リポジトリ数、候補件数、作成ファイル数）
2. 作業リポジトリ一覧
3. カテゴリ別分布と主なトピック
4. 新規追加ファイル一覧
5. 明日の推奨タスク（継続作業、未解決問題、深堀りトピック等）

**重要**: ユーザーへの質問は禁止。Step 4-8の記録データのみから自律的に生成してください。

#### Step 11-2: 今日のコーヒー豆 🌍

最後に、世界のコーヒーから今日の1杯をご紹介します。

**参照**: [references/coffee_output_format.md](references/coffee_output_format.md) の出力フォーマットを使用してください。

[references/coffee_beans.md](references/coffee_beans.md) からランダムに1つ選んで紹介してください。

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
python "$SKILL_BASE/scripts/manage_daily_trigger.py" status
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
python "$SKILL_BASE/scripts/extract_knowledge.py" 2026-01-31
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
