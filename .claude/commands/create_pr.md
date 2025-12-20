---
name: create_pr
description: GitHub PRを作成する
model: sonnet
---

# Create PR - GitHub PR作成

このコマンドは、現在のブランチからGitHub PRを作成します。

## 実行内容

1. **現在の状態確認**
   - 現在のブランチを確認（main/masterでないことを確認）
   - 未コミットの変更を確認
   - git statusを表示

2. **変更内容の確認**
   - mainブランチとの差分を確認
   - コミット履歴を表示
   - 変更ファイル一覧を表示

3. **ターゲットブランチの確認**
   - ユーザーにターゲットブランチを確認
   - デフォルト: main

4. **リモートへプッシュ**
   - 現在のブランチをリモートにプッシュ
   - まだプッシュしていない場合は `-u origin [ブランチ名]`

5. **PR作成**
   - `gh pr create` でPR作成
   - タイトル：最新のコミットメッセージから自動生成
   - 本文：変更内容のサマリーを自動生成
   - ブラウザでPRページを自動で開く

## 実行手順

このコマンドを実行すると、以下の処理を順番に実行します。

```bash
# 1. 現在のブランチを確認
current_branch=$(git branch --show-current)

# main/masterブランチでないことを確認
if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
  echo "Error: main/masterブランチからはPRを作成できません"
  exit 1
fi

# 2. git statusで未コミット変更を確認
git status

# 3. mainブランチとの差分を確認
git log main..HEAD --oneline
git diff main...HEAD --stat

# 4. ターゲットブランチをユーザーに確認
# AskUserQuestionで確認（デフォルト: main）

# 5. リモートにプッシュ
git push -u origin "$current_branch"

# 6. PR作成
gh pr create --base main --web
```

## PRタイトルとボディの生成

PRのタイトルとボディは以下のように生成されます:

- **タイトル**: 最新のコミットメッセージの1行目
- **ボディ**:
  - コミット履歴のサマリー
  - 変更ファイル一覧
  - テストプラン（必要に応じて）

## 注意事項

- このコマンドはGitHub CLI (`gh`)が必要です
- 事前に`gh auth login`で認証してください
- main/masterブランチからは実行できません
- 未コミットの変更がある場合は先にコミットしてください
- `--web`オプションでブラウザが自動で開きます
