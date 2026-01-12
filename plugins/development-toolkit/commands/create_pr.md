---
name: create_pr
description: GitHub PRを作成する
model: sonnet
---

# Create PR - GitHub PR作成

このコマンドは、現在のブランチからGitHub PRを作成します。

## 実行内容

0. **事前確認フェーズ（ユーザー確認項目を最初にまとめて実施）**
   - ターゲットブランチの確認（main / develop / その他）
   - バージョンファイルの存在確認
   - バージョン更新方針の確認（バージョンファイルがある場合のみ）
     - スキップ / PATCH / MINOR / MAJOR

1. **現在の状態確認**
   - 現在のブランチを確認（main/masterでないことを確認）
   - 未コミットの変更を確認
   - git statusを表示

1.5. **Git追跡対象の検証**

- 未追跡ファイル（untracked files）のスキャン
- ステージング済みファイルのスキャン
- 危険パターン（秘密情報、ビルド成果物、OS生成ファイル、一時ファイル）との照合
- 問題検出時にユーザーへ確認（.gitignoreに追加/個別確認/無視/中止）

2. **変更内容の確認**
   - mainブランチとの差分を確認
   - コミット履歴を表示
   - 変更ファイル一覧を表示
   - review-dojo-mcpが利用可能な場合：
     - `generate_pr_checklist`で過去のレビュー知見を取得
     - 取得した知見をレビューの参考情報として表示
   - `code-simplifier:code-simplifier` エージェントでコード簡素化・リファクタリング
   - `/security-review` でセキュリティレビューを実行（code-simplifier の後）
   - 指摘があればユーザーに修正確認→修正→再レビュー（ループ）

3. **バージョン更新の実施**
   - ステップ0で決めた方針に基づいてバージョンを更新
   - 更新する場合はバージョンファイルを編集してコミット
   - スキップの場合は次のステップへ

4. **リモートへプッシュ**
   - 現在のブランチをリモートにプッシュ
   - まだプッシュしていない場合は `-u origin [ブランチ名]`

5. **PR作成**
   - `gh pr create` でPR作成
   - ターゲットブランチ：ステップ0で確認したブランチ
   - タイトル：最新のコミットメッセージから自動生成
   - 本文：変更内容のサマリーを自動生成
   - ブラウザでPRページを自動で開く

## 実行手順

このコマンドを実行すると、以下の処理を順番に実行します。

```bash
# ステップ0: 事前確認フェーズ
# Claude Code実行時の処理:
# 1. バージョンファイルの存在を確認（package.json, pom.xml, build.gradle, pyproject.toml等）
# 2. AskUserQuestionツールで以下を一度にまとめて確認:
#    質問1: ターゲットブランチを選択してください
#      - main（推奨）
#      - develop
#      - その他（ユーザー入力）
#    質問2: バージョン更新方針を選択してください（バージョンファイルがある場合のみ表示）
#      - スキップ（バージョン更新しない）
#      - PATCH（バグ修正、軽微な変更）
#      - MINOR（機能追加、後方互換性あり）
#      - MAJOR（破壊的変更、後方互換性なし）
# 3. ユーザーの選択を変数に保存:
#    target_branch="<ユーザーの選択>"
#    version_update="<ユーザーの選択>"  # skip/patch/minor/major

# ステップ1: 現在のブランチを確認
current_branch=$(git branch --show-current)

# main/masterブランチでないことを確認
if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
  echo "Error: main/masterブランチからはPRを作成できません"
  exit 1
fi

# ステップ1.5: Git追跡対象の検証
# Git管理に不要なファイルが含まれていないか検証

# 未追跡ファイルの取得
untracked_files=$(git ls-files --others --exclude-standard)

# ステージング済みファイルの取得
staged_files=$(git diff --cached --name-only)

# Claude Code実行時の処理:
# 1. 未追跡ファイルとステージング済みファイルに対して危険パターンとの照合を実施
# 2. 危険パターン（すべて同等に警告）:
#    - 秘密情報: .env, .env.* (!.env.example, !.env.template), .secrets/, secrets/,
#                credentials/, *.pem, *.key, *.p12, *.pfx, *.ppk, id_rsa*, id_ed25519*,
#                service-account.json, .netrc, .npmrc, .pypirc
#    - ビルド成果物・依存関係: node_modules/, dist/, build/, *.tsbuildinfo
#    - OS・エディタ生成ファイル: .DS_Store, Thumbs.db, .vscode/, .idea/,
#                                *.swp, *.swo, *~
#    - 一時ファイル: *.log, *.tmp, *.bak, .temp/, docs/tmp/
#
# 3. 問題が検出された場合:
#    a. 警告メッセージと該当ファイル一覧を表示
#    b. AskUserQuestionツールで以下の選択肢を提示:
#       - A: .gitignoreに追加して続行
#         → 検出されたパターンを .gitignore に追加
#         → git add .gitignore を実行
#         → 既にステージングされている危険ファイルは git reset HEAD <file> で除外
#       - B: 個別に確認
#         → 各ファイルについて追加/除外/維持を選択
#       - C: 警告を無視して続行
#         → 警告内容をコンソールに記録して次のステップへ進む
#       - D: 中止
#         → PR作成を中止
#
# 4. 問題がない場合:
#    → 次のステップへ進む
#
# エッジケース対応:
# - .gitignore が存在しない場合: ファイルを新規作成（ユーザー確認後）
# - パターンが既に .gitignore に存在: 重複追加しない
# - 未追跡ファイルがない場合: スキップして次へ
# - 大量ファイル（100件以上）: 要約表示 + 詳細はコンソールへ

# ステップ2: 未コミット変更と差分の確認
git status

# mainブランチとの差分を確認
git log main..HEAD --oneline
git diff main...HEAD --stat

# ステップ2.5: コードレビュー・セキュリティレビュー（review-dojo-mcp統合）
# Claude Code実行時の処理:
# 1. 変更ファイルリストを取得
#    changed_files=$(git diff main...HEAD --name-only)
#
# 2. review-dojo-mcpが利用可能かチェック
#    MCPツール "mcp__review-dojo__generate_pr_checklist" が利用可能か確認
#
# 3. review-dojo-mcpが利用可能な場合:
#    a. MCPSearchツールで "generate_pr_checklist" を検索・ロード
#       MCPSearch(query: "select:mcp__review-dojo__generate_pr_checklist")
#    b. generate_pr_checklist を実行して過去のレビュー知見を取得
#       入力: 変更ファイルリスト
#       出力: 過去のレビュー知見に基づくチェックリスト
#    c. 取得した知見を表示し、レビューの参考情報として活用
#       echo "=== 過去のレビュー知見（review-dojo-mcp） ==="
#       echo "<generated_checklist>"
#       echo "=========================================="
#
# 4. review-dojo-mcpが利用不可の場合:
#    → スキップして次へ進む（従来通りのレビュー）
#
# 5. code-simplifier:code-simplifier エージェントでコード簡素化を実行
#    - Task tool を使用して code-simplifier エージェントを起動
#    - 最近変更したコードを対象に簡素化・リファクタリング
#    - 変更があった場合は自動コミット
#
# 6. /security-review スキルでセキュリティレビューを実行
#
# 7. 指摘事項がある場合:
#    a. AskUserQuestionツールで修正するか確認
#       - 修正する: 修正を実施し、ステップ2.5を再実行
#       - スキップ: 次のステップへ進む
#
# 8. 指摘事項がない場合: 次のステップへ進む
#
# 注意:
# - このループは指摘事項がなくなるまで繰り返される
# - review-dojo-mcpはオプショナル機能（利用不可でもエラーにならない）
# - MCPツールのインストール: https://github.com/sk8metalme/review-dojo-mcp

# ステップ3: バージョン更新の実施
# Claude Code実行時の処理:
# ステップ0で決めた version_update の値に基づいて処理
# 1. version_update が "skip" の場合: 何もしない
# 2. version_update が "patch", "minor", "major" の場合:
#    a. バージョンファイルを検出（Node.js/TypeScript, Java, Python, PHP, Ansible, RPM, Rust, Ruby等）
#    b. 現在のバージョンを読み取り
#    c. セマンティックバージョニングに従って新しいバージョンを計算
#       例: 1.2.3 → patch: 1.2.4, minor: 1.3.0, major: 2.0.0
#    d. バージョンファイルを編集して新しいバージョンに更新
#    e. git add <version_file>
#    f. git commit -m "chore: bump version to <new_version>"
#
# サポートされるバージョンファイル:
# - Node.js/TypeScript: package.json
# - Java: pom.xml (Maven), build.gradle/build.gradle.kts (Gradle)
# - Python: pyproject.toml
# - PHP: composer.json
# - Ansible: galaxy.yml
# - RPM: *.spec
# - Rust: Cargo.toml
# - Ruby: *.gemspec
# - 汎用: VERSION, version.txt

# ステップ4: リモートにプッシュ
git push -u origin "$current_branch"

# ステップ5: PR作成 + ブラウザオープン
# $target_branchはステップ0で確認したブランチ名を使用
# --webオプションでPR作成完了後、自動的にブラウザでPRページを開く
gh pr create --base "$target_branch" --title "コミット履歴をまとめた概要を端的に説明したタイトル" --body "コミット履歴のサマリー、変更ファイル一覧、テストプラン（必要に応じて）" --web
```

## PRタイトルとボディの生成

PRのタイトルとボディは以下のように生成されます:

- **タイトル**: コミット履歴をまとめた概要を端的に説明したタイトル
- **ボディ**:
  - コミット履歴のサマリー
  - 変更ファイル一覧
  - テストプラン（必要に応じて）

## 注意事項

- このコマンドはGitHub CLI (`gh`)が必要です
- 事前に`gh auth login`で認証してください
- main/masterブランチからは実行できません
- 未コミットの変更がある場合は先にコミットしてください
- PR作成完了後、自動的にブラウザでPRページを開きます
- **ステップ0で事前にターゲットブランチとバージョン更新方針を確認します**
- バージョン管理ファイルが存在しない場合、バージョン更新の質問は表示されません
- サポートされるバージョンファイル：package.json, pom.xml, build.gradle, pyproject.toml, composer.json, galaxy.yml, *.spec, Cargo.toml, *.gemspec, VERSION, version.txt
- **review-dojo-mcpが利用可能な場合、過去のレビュー知見を参照して品質向上を図ります**（オプショナル機能）
  - インストール方法: https://github.com/sk8metalme/review-dojo-mcp
