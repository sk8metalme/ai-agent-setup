---
name: create_pr
description: GitHub PRを作成する
model: sonnet
---

# Create PR - GitHub PR作成

このコマンドは、現在のブランチからGitHub PRを作成します。

## 実行内容

1. **事前確認フェーズ**
   - ターゲットブランチの確認（main / develop / その他）
   - バージョンファイルの存在確認と更新方針の確認（スキップ / PATCH / MINOR / MAJOR）

2. **現在の状態確認**
   - 現在のブランチを確認（main/masterでないことを確認）
   - 未コミットの変更を確認
   - git statusを表示

3. **Git追跡対象の検証**
   - 未追跡ファイル・ステージング済みファイルのスキャン
   - 危険パターン（秘密情報、ビルド成果物、OS生成ファイル、一時ファイル）との照合
   - 問題検出時にユーザーへ確認（.gitignoreに追加/個別確認/無視/中止）

4. **変更内容の確認とレビュー**
   - mainブランチとの差分・コミット履歴・変更ファイル一覧を表示
   - review-dojo-mcp連携（利用可能な場合のみ）
   - code-simplifierエージェントでコード簡素化
   - セキュリティレビューの実行（指摘があれば修正→再レビュー）

5. **バージョン更新の実施**
   - ステップ1で決めた方針に基づいてバージョンを更新
   - 更新する場合はバージョンファイルを編集してコミット

6. **リモートへプッシュ**
   - 現在のブランチをリモートにプッシュ（`-u origin [ブランチ名]`）

7. **PR作成**
   - `gh pr create` でPR作成（タイトル・本文は自動生成）
   - ブラウザでPRページを自動で開く

## 実行手順

このコマンドを実行すると、以下の処理を順番に実行します。

```bash
# ステップ1: 事前確認フェーズ
# - バージョンファイルの存在を確認（package.json, pom.xml, pyproject.toml等）
# - AskUserQuestionでターゲットブランチとバージョン更新方針を確認
#   → target_branch, version_update 変数に保存

# ステップ2: 現在のブランチを確認
current_branch=$(git branch --show-current)

# main/masterブランチでないことを確認
if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
  echo "Error: main/masterブランチからはPRを作成できません"
  exit 1
fi

# ステップ3: Git追跡対象の検証
untracked_files=$(git ls-files --others --exclude-standard)
staged_files=$(git diff --cached --name-only)

# 危険パターンとの照合:
# - 秘密情報: .env*, .secrets/, credentials/, *.pem, *.key, id_rsa*, service-account.json
# - ビルド成果物: node_modules/, dist/, build/
# - OS/エディタ生成: .DS_Store, .vscode/, .idea/, *.swp
# - 一時ファイル: *.log, *.tmp, *.bak, docs/tmp/
#
# 問題検出時の選択肢:
# A: .gitignoreに追加 / B: 個別確認 / C: 警告を無視 / D: 中止

# ステップ4: 未コミット変更と差分の確認
git status

# mainブランチとの差分を確認
git log main..HEAD --oneline
git diff main...HEAD --stat

# ステップ4.1: コードレビュー（review-dojo-mcp統合・オプショナル）
# - review-dojo-mcpが利用可能な場合、generate_pr_checklistで過去の知見を取得
# - code-simplifierエージェントでコード簡素化
# - /security-reviewでセキュリティレビュー
# - 指摘事項があれば修正→再レビュー（ループ）

# ステップ5: バージョン更新の実施
# version_update の値に基づいて処理（skip/patch/minor/major）
# セマンティックバージョニング: 1.2.3 → patch: 1.2.4, minor: 1.3.0, major: 2.0.0
#
# サポート: package.json, pom.xml, build.gradle, pyproject.toml, composer.json,
#           galaxy.yml, *.spec, Cargo.toml, *.gemspec, VERSION, version.txt

# ステップ6: リモートにプッシュ
git push -u origin "$current_branch"

# ステップ7: PR作成 + ブラウザオープン
gh pr create --base "$target_branch" --title "<コミット履歴の概要>" --body "<サマリー、変更一覧、テストプラン>" --web
```

## 注意事項

- このコマンドはGitHub CLI (`gh`)が必要です
- 事前に`gh auth login`で認証してください
- main/masterブランチからは実行できません
- 未コミットの変更がある場合は先にコミットしてください
- PR作成完了後、自動的にブラウザでPRページを開きます
- ステップ1で事前にターゲットブランチとバージョン更新方針を確認します
- バージョン管理ファイルが存在しない場合、バージョン更新の質問は表示されません
- サポートされるバージョンファイル：package.json, pom.xml, build.gradle, pyproject.toml, composer.json, galaxy.yml, *.spec, Cargo.toml, *.gemspec, VERSION, version.txt
- **review-dojo-mcpが利用可能な場合、過去のレビュー知見を参照して品質向上を図ります**（オプショナル機能）
  - インストール方法: https://github.com/sk8metalme/review-dojo-mcp
