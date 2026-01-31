# 知識ファイル形式

このドキュメントは知識markdownファイルの形式を定義します。

## ファイル構造

各知識ファイルは以下の構造に従う必要があります:

```markdown
---
title: Knowledge Title
category: errors|patterns|commands|design|domain|operations
tags: [tag1, tag2, tag3]
date: YYYY-MM-DD
source: conversation|manual|import
---

# Knowledge Title

## Context

この知識に遭遇したときの簡単なコンテキスト。

## Problem/Topic

問題またはトピックの説明。

## Solution/Insight

実際の知識内容:
- 主要な知見
- 解決手順
- コード例
- コマンド例

## Related

- 関連する知識項目へのリンク
- ドキュメントへの参照
```

## Frontmatterフィールド

### 必須フィールド

- **title**: 明確で説明的なタイトル（50-100文字）
- **category**: 以下のいずれか: errors, patterns, commands, design, domain, operations
- **tags**: 検索性のための関連タグの配列
- **date**: 作成日（YYYY-MM-DD）

### オプションフィールド

- **source**: 知識の出所（conversation, manual, import）
- **language**: 該当する場合はプログラミング言語
- **framework**: 該当する場合はフレームワーク/ライブラリ
- **difficulty**: beginner, intermediate, advanced
- **priority**: low, medium, high, critical

## コンテンツガイドライン

### タイトル

- 具体的で検索可能にする
- 主要な用語を含める（エラー名、コマンド名など）
- 例:
  - ✅ "Fix ModuleNotFoundError when importing local packages"
  - ✅ "Use git rebase --onto for advanced branch management"
  - ❌ "Error fix"
  - ❌ "Git command"

### コンテキストセクション

- いつこれに遭遇したか？
- どのようなタスクの一環として発生したか？
- なぜこれを文書化する価値があるか？

### 問題/トピックセクション

- 明確な問題文またはトピック説明
- エラーメッセージ（該当する場合）
- 環境の詳細（関連する場合）

### 解決策/知見セクション

- ステップバイステップの解決策または説明
- 構文ハイライト付きのコード例
- コマンド例
- 根拠とトレードオフ

### 関連セクション

- 内部リンク: `[Related knowledge](../errors/2026-01-30_other_error.md)`
- 外部リンク: ドキュメント、Stack Overflowなど
- 発見性のためのタグ

## タグ戦略

### タグカテゴリ

1. **技術**: `python`, `javascript`, `docker`, `git` など
2. **ドメイン**: `authentication`, `api`, `database`, `testing` など
3. **タイプ**: `error-fix`, `best-practice`, `optimization`, `security` など
4. **複雑さ**: `beginner`, `advanced`, `quick-fix`, `deep-dive` など

### タグのベストプラクティス

- 項目ごとに3-7個のタグを使用
- 命名の一貫性を保つ（小文字、ハイフン区切り）
- 具体的なタグと一般的なタグの両方を含める
- 例: `[python, import-error, package-management, pip, beginner]`

## 例

### エラー解決

```markdown
---
title: Fix "Permission denied" error when running Docker without sudo
category: errors
tags: [docker, linux, permissions, sudo, devops]
date: 2026-01-31
source: conversation
---

# Fix "Permission denied" error when running Docker without sudo

## Context

UbuntuへのDocker新規インストール後、`docker ps`を実行しようとしたときに遭遇しました。

## Problem

エラーメッセージ:
```
Got permission denied while trying to connect to the Docker daemon socket
```

## Solution

ユーザーをdockerグループに追加:

```bash
sudo usermod -aG docker $USER
newgrp docker  # またはログアウトしてログイン
docker ps      # これで動作するはず
```

## Related

- [Docker installation guide](https://docs.docker.com/engine/install/)
- [Linux user groups](../commands/2026-01-15_linux_groups.md)
```

### ベストプラクティス

```markdown
---
title: Use type hints and Pydantic for API input validation
category: patterns
tags: [python, fastapi, pydantic, validation, type-hints, best-practice]
date: 2026-01-31
source: conversation
difficulty: intermediate
---

# Use type hints and Pydantic for API input validation

## Context

FastAPIでREST APIを構築する際には、堅牢な入力検証が必要です。

## Topic

FastAPI + Pydanticは自動検証とドキュメント生成を提供します。

## Insight

Pydanticでリクエストモデルを定義:

```python
from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: str = Field(..., pattern=r"^[\w\.-]+@[\w\.-]+\.\w+$")
    age: int = Field(..., ge=0, le=150)

@app.post("/users/")
async def create_user(user: UserCreate):
    return {"username": user.username}
```

メリット:
- 自動検証
- 明確なエラーメッセージ
- 自動生成されたAPIドキュメント
- 型安全性

## Related

- [FastAPI documentation](https://fastapi.tiangolo.com/)
- [Pydantic models](https://pydantic-docs.helpmanual.io/)
```
