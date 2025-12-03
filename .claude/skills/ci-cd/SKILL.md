---
name: ci-cd
description: |
  CI/CD（GitHub Actions、Screwdriver）の確認方法とトラブルシュート。
  推測ではなく、必ずログを確認してから対策を講じる。
allowed-tools: Bash, Read, Grep, Glob
---

# CI/CD確認スキル

## 目的

CI/CDの失敗時に、**推測で解決するのではなく**、必ずジョブのログを確認して原因を把握してから対策を講じる。

## 重要な原則

### ❌ 禁止事項

- エラーメッセージを見ずに推測で修正を試みる
- ログを部分的にしか確認しない
- エラーの根本原因を特定せずに対処療法を実施

### ✅ 必須事項

- **必ずジョブのログ全体を確認する**
- エラーメッセージの前後のコンテキストを読む
- 失敗したステップを特定する
- 根本原因を理解してから修正する

## GitHub Actionsのログ確認方法

### 1. CLIでワークフロー実行状況を確認

```bash
# 最新のワークフロー実行一覧を表示
gh run list

# 特定のワークフロー実行の詳細を表示
gh run view <run-id>

# 失敗したワークフロー実行のみを表示
gh run list --status failure

# 特定のブランチのワークフロー実行を表示
gh run list --branch feature/my-branch
```

### 2. ジョブのログを取得

```bash
# 特定のワークフロー実行のログを表示
gh run view <run-id> --log

# 失敗したジョブのログのみを表示
gh run view <run-id> --log-failed

# ログをファイルに保存
gh run view <run-id> --log > workflow.log
```

### 3. 特定のジョブのログを確認

```bash
# ジョブ一覧を表示
gh run view <run-id> --job

# 特定のジョブのログを表示
gh run view --job <job-id> --log
```

### 4. Webブラウザで確認

```bash
# ワークフロー実行ページをブラウザで開く
gh run view <run-id> --web
```

### 5. リアルタイムでログを監視

```bash
# ワークフロー実行を監視（ポーリング）
gh run watch <run-id>
```

## Screwdriverのログ確認方法

### 1. Screwdriver CLIでビルド状況を確認

```bash
# ビルド一覧を表示
sd-cmd exec get builds --pipeline <pipeline-id>

# 特定のビルドの詳細を表示
sd-cmd exec get build --build-id <build-id>
```

### 2. ビルドログを取得

```bash
# ビルドログを表示
sd-cmd exec get build-log --build-id <build-id>

# ステップごとのログを確認
sd-cmd exec get build-log --build-id <build-id> --step <step-name>
```

### 3. WebブラウザでScrewdriver UIを確認

```bash
# Screwdriver UIのURLを開く
open https://screwdriver.company.com/pipelines/<pipeline-id>/builds/<build-id>
```

### 4. APIを使用したログ取得

```bash
# curlでビルドログを取得
curl -H "Authorization: Bearer $SD_TOKEN" \
  "https://api.screwdriver.company.com/v4/builds/<build-id>/steps/<step-name>/logs"

# jqで整形
curl -H "Authorization: Bearer $SD_TOKEN" \
  "https://api.screwdriver.company.com/v4/builds/<build-id>/steps/<step-name>/logs" | jq -r '.[].message'
```

## 失敗時の対応フロー

### Step 1: ログを全文確認

```bash
# GitHub Actionsの場合
gh run view <run-id> --log > /tmp/ci-log.txt
cat /tmp/ci-log.txt

# Screwdriverの場合
sd-cmd exec get build-log --build-id <build-id> > /tmp/sd-log.txt
cat /tmp/sd-log.txt
```

### Step 2: エラーメッセージを特定

- ログ内で `Error:`, `FAILED:`, `✗`, `[ERROR]` を検索
- スタックトレースの先頭行を確認
- 失敗したステップ名を特定

```bash
# エラー行を抽出
grep -i "error\|failed\|✗" /tmp/ci-log.txt

# 前後5行のコンテキストも表示
grep -i -B 5 -A 5 "error" /tmp/ci-log.txt
```

### Step 3: 根本原因を分析

以下の観点で分析：

1. **依存関係の問題**: パッケージのインストールエラー
2. **環境変数の問題**: 未設定または誤った値
3. **権限の問題**: ファイルアクセス権限、API認証
4. **テストの失敗**: ユニットテスト、統合テスト
5. **ビルドの失敗**: コンパイルエラー、リンクエラー
6. **タイムアウト**: ジョブ実行時間超過

### Step 4: 修正を実施

根本原因を理解してから、以下を実施：

1. ローカル環境で再現を試みる
2. 修正コードを作成
3. ローカルでテスト
4. コミット＆プッシュ
5. CI/CDで再実行を確認

### Step 5: 結果を確認

```bash
# 最新のワークフロー実行を確認
gh run list --limit 1

# 成功を確認
gh run view <run-id>
```

## よくあるエラーと対処法

### GitHub Actions

#### エラー1: `Error: Process completed with exit code 1`

**確認すべき点**:
- 前のステップのログでエラー詳細を確認
- テストの失敗、ビルドエラーの有無

**対処法**:
```bash
# ログ全体を確認してエラー箇所を特定
gh run view <run-id> --log | grep -B 20 "exit code 1"
```

#### エラー2: `Error: Unable to resolve action`

**確認すべき点**:
- アクションの名前・バージョンが正しいか
- プライベートリポジトリの場合、アクセス権限

**対処法**:
```yaml
# 正しいアクション名を確認
- uses: actions/checkout@v4  # v3 → v4 に更新
```

#### エラー3: `Error: Resource not accessible by integration`

**確認すべき点**:
- `GITHUB_TOKEN` の権限設定
- ワークフローの `permissions` セクション

**対処法**:
```yaml
permissions:
  contents: write
  pull-requests: write
```

### Screwdriver

#### エラー1: `Build failed: Command not found`

**確認すべき点**:
- コマンドがコンテナイメージに含まれているか
- PATHが正しく設定されているか

**対処法**:
```yaml
# screwdriver.yamlでイメージを確認
image: node:18  # 必要なコマンドが含まれるイメージを使用
```

#### エラー2: `Build timeout`

**確認すべき点**:
- ビルド時間が制限を超えていないか
- 無限ループやハングアップの有無

**対処法**:
```yaml
# タイムアウトを延長
annotations:
  screwdriver.cd/timeout: 120  # 分単位
```

#### エラー3: `Secrets not found`

**確認すべき点**:
- シークレットが正しく設定されているか
- シークレット名のタイポ

**対処法**:
```bash
# Screwdriver UIでシークレットを確認
# Pipeline Settings > Secrets
```

## トラブルシュートチェックリスト

- [ ] ログ全体を確認したか
- [ ] エラーメッセージの前後のコンテキストを読んだか
- [ ] 失敗したステップを特定したか
- [ ] 根本原因を理解したか
- [ ] ローカル環境で再現を試みたか
- [ ] 修正後、ローカルでテストしたか
- [ ] CI/CDで再実行して成功を確認したか

## 参考資料

### GitHub Actions
- [GitHub CLI Manual - gh run](https://cli.github.com/manual/gh_run)
- [GitHub Actions - Workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions - Troubleshooting](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows)

### Screwdriver
- [Screwdriver Documentation](https://docs.screwdriver.cd/)
- [Screwdriver API](https://api.screwdriver.cd/v4/documentation)
- [Screwdriver CLI](https://github.com/screwdriver-cd/sd-cmd)

---

**重要**: このスキルの最も重要な原則は「推測せず、ログを確認する」ことです。必ずログ全体を読んでから対策を講じてください。
