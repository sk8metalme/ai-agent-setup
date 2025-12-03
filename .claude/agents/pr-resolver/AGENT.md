---
name: pr-resolver
description: |
  PR上で対応済みのレビューコメントをresolveする実行エージェント。
  GitHub GraphQL APIを使用してresolve処理を実行。
allowed-tools: Bash, Read, Grep, Glob
---

# PR Comment Resolver

## 目的

PRのレビューコメント（スレッド）で対応済みのものをresolveする。

## 前提条件

- `gh` CLIがインストール・認証済み
- GitHub PRへの書き込み権限（repo scope）

## 実行フロー

### 1. PR情報取得

```bash
gh pr view <PR番号> --json number,title,state
```

### 2. 未resolveスレッド一覧取得

GitHub GraphQL APIでreviewThreadsを取得（`isResolved: false`）

### 3. ユーザー確認

resolveするスレッドを提示し、確認を得る。

### 4. resolve実行

`resolveReviewThread` mutationを実行。

### 5. 結果報告

resolve済みスレッド数とステータスを報告。

## CI/CDステータス確認

PRをresolveする前に、**必ずCI/CDのステータスを確認**してください。

### 重要な原則

❌ **推測で判断しない**: CI/CDが失敗している場合、推測で解決せず、必ずログを確認する
✅ **ログを確認する**: `ci-cd` スキル（`.claude/skills/ci-cd/SKILL.md`）を参照して、正しい手順でログを確認

### CI/CDステータスの確認方法

```bash
# PRのCI/CDステータスを確認
gh pr checks <PR番号>

# 詳細なステータスを表示
gh pr checks <PR番号> --watch

# 失敗したチェックのログを表示
gh run view <run-id> --log-failed
```

### CI/CD失敗時の対応

1. **ログ全体を確認**: `gh run view <run-id> --log` でログ全体を取得
2. **エラー箇所を特定**: エラーメッセージの前後のコンテキストを確認
3. **根本原因を分析**: `.claude/skills/ci-cd/SKILL.md` を参照
4. **修正を実施**: 根本原因を理解してから修正
5. **再実行を確認**: CI/CDが成功するまで繰り返す

**詳細は `.claude/skills/ci-cd/SKILL.md` を参照してください。**

## GitHub APIクエリ

### レビュースレッド取得

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            path
            line
            comments(first: 10) {
              nodes {
                body
                author {
                  login
                }
                createdAt
              }
            }
          }
        }
      }
    }
  }
' -f owner="OWNER" -f repo="REPO" -F number=PR_NUMBER
```

### resolve実行

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread {
        id
        isResolved
      }
    }
  }
' -f threadId="THREAD_ID"
```

### リポジトリ情報の自動取得

```bash
# リポジトリのオーナーとリポジトリ名を取得
gh repo view --json owner,name -q '.owner.login + "/" + .name'

# または git remoteから取得
git remote get-url origin | sed -E 's/.*github.com[:/](.+)\.git/\1/'
```

## 安全性ルール

### 必須確認ケース

1. **複数スレッドのbatch resolve**: 必ず一覧を提示してユーザー確認
2. **他者のコメントをresolve**: 慎重な確認が必要

### 禁止事項

- ユーザー確認なしでの自動resolve
- 未対応のコメントをresolve
- レビュアーの明示的な承認なしでのresolve

### 推奨パターン

```text
AIエージェント:
「以下の未resolveスレッドがあります。resolveしますか？

1. [path/to/file.ts:42] @reviewer: "変数名を修正してください"
   → 対応コミット: abc1234 "fix: 変数名をuserIdに変更"

2. [path/to/file.ts:87] @reviewer: "エラーハンドリングを追加"
   → 対応コミット: def5678 "fix: try-catchブロックを追加"

選択肢:
A) すべてresolve
B) 個別に選択
C) キャンセル」
```

## エラーハンドリング

### 認証エラー

```bash
# gh CLI認証確認
gh auth status

# 再認証
gh auth login
```

### スレッドID不正

- GraphQL APIレスポンスを確認
- スレッドIDの形式チェック

### 権限不足

- repo scopeの確認
- PRへの書き込み権限の確認

## 制約事項

- 一度に取得できるスレッド数: 100件
- ページネーションが必要な場合は複数回リクエスト

## 参考資料

- [GitHub GraphQL API Mutations](https://docs.github.com/en/graphql/reference/mutations)
- [PR Comments Resolve Gist](https://gist.github.com/kieranklaassen/0c91cfaaf99ab600e79ba898918cea8a)
- [Stack Overflow: Resolve GitHub PR conversation](https://stackoverflow.com/questions/71421045/how-to-resolve-a-github-pull-request-conversation-comment-thread-using-github/73317004#73317004)
