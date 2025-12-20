---
name: git_sync
description: PRマージ後にローカルのgitを最新化する
model: sonnet
---

# Git Sync - PRマージ後のローカル最新化

このコマンドは、PRマージ後にローカルのgitリポジトリを最新状態に同期します。

## 実行内容

1. **現在の状態確認**
   - 現在のブランチを確認
   - 未コミットの変更があるか確認

2. **変更の退避**
   - 未コミットの変更がある場合、`git stash`で一時退避

3. **メインブランチへ切り替え**
   - `git checkout main` または `git checkout master`
   - メインブランチの名前を自動検出

4. **リモートから最新を取得**
   - `git fetch origin` でリモートの最新情報を取得
   - `git pull` でメインブランチを最新化

5. **マージ済みブランチの削除**
   - リモートで削除されたブランチをローカルからも削除
   - `git branch --merged` で確認してから削除
   - main/master/develop は保護

6. **作業の復元**
   - stashした変更があれば `git stash pop` で復元

## 実行手順

このコマンドを実行すると、以下の処理を順番に実行します。

```bash
# 1. 現在のブランチを確認
git branch --show-current

# 2. 未コミット変更があればstashで退避
git stash push -m "git_sync: auto stash before sync"

# 3. メインブランチに切り替え
git checkout main  # または master

# 4. リモートから最新を取得
git fetch origin
git pull

# 5. マージ済みブランチを削除
git branch --merged | grep -v "^\*" | grep -v "main\|master\|develop" | xargs -r git branch -d

# 6. stashから変更を復元
git stash pop
```

## 注意事項

- このコマンドはメインブランチ（main/master）の最新化を前提としています
- 保護ブランチ（main/master/develop）は削除されません
- stashした変更はコンフリクトする可能性があります
- コンフリクトが発生した場合は手動で解決してください
