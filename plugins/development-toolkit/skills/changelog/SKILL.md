---
name: changelog
description: |
  CHANGELOGとリリースノート生成ガイド。
  Conventional Commits、Keep a Changelog形式、セマンティックバージョニング対応。
allowed-tools: Bash, Read, Grep, Glob
---

# CHANGELOG生成スキル

## 目的

プロジェクトの変更履歴を適切に管理し、ユーザーにとって有用なCHANGELOGとリリースノートを生成する。

## CHANGELOG形式

### Keep a Changelog形式（推奨）

[Keep a Changelog](https://keepachangelog.com/)に準拠した形式：

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- 新機能A
- 新機能B

### Changed
- 変更された機能C

### Deprecated
- 非推奨となった機能D

### Removed
- 削除された機能E

### Fixed
- 修正されたバグF

### Security
- セキュリティ修正G

## [1.0.0] - 2024-01-15

### Added
- 初回リリース
- 基本機能の実装

[Unreleased]: https://github.com/user/repo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/user/repo/releases/tag/v1.0.0
```

### カテゴリの意味

| カテゴリ | 説明 | 例 |
|---------|------|-----|
| **Added** | 新機能 | 新しいAPI、新しいコマンド |
| **Changed** | 既存機能の変更 | パラメータ変更、デフォルト値変更 |
| **Deprecated** | 非推奨（将来削除予定） | 古いAPI、レガシー機能 |
| **Removed** | 削除された機能 | 非推奨だった機能の削除 |
| **Fixed** | バグ修正 | クラッシュ修正、表示バグ修正 |
| **Security** | セキュリティ修正 | 脆弱性対応、CVE修正 |

## Conventional Commits

### フォーマット

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### タイプ一覧

| Type | 説明 | CHANGELOGカテゴリ |
|------|------|------------------|
| `feat` | 新機能 | Added |
| `fix` | バグ修正 | Fixed |
| `docs` | ドキュメントのみ | - |
| `style` | コードの意味に影響しない変更 | - |
| `refactor` | リファクタリング | - |
| `perf` | パフォーマンス改善 | Changed |
| `test` | テスト追加・修正 | - |
| `build` | ビルドシステム変更 | - |
| `ci` | CI設定変更 | - |
| `chore` | その他の変更 | - |
| `revert` | コミットの取り消し | - |

### Breaking Changes

**BREAKING CHANGE** を含むコミットはメジャーバージョンアップの対象：

```
feat!: drop support for Node 14

BREAKING CHANGE: Node 14 is no longer supported. Minimum version is Node 16.
```

### 例

#### 新機能
```
feat(auth): add OAuth2 login support

Implemented OAuth2 authentication flow with Google and GitHub providers.
Closes #123
```

#### バグ修正
```
fix(api): handle null response in user endpoint

Fixed crash when user data is null.
Fixes #456
```

#### 破壊的変更
```
feat(api)!: change user endpoint response format

BREAKING CHANGE: User endpoint now returns nested user object instead of flat structure.

Before:
{ "name": "John", "email": "john@example.com" }

After:
{ "user": { "name": "John", "email": "john@example.com" } }
```

## セマンティックバージョニング

### バージョン形式

```
MAJOR.MINOR.PATCH

例: 1.2.3
```

### バージョンアップルール

| 変更内容 | バージョン | 例 |
|---------|-----------|-----|
| **破壊的変更** | MAJOR | 1.0.0 → 2.0.0 |
| **新機能（後方互換）** | MINOR | 1.0.0 → 1.1.0 |
| **バグ修正** | PATCH | 1.0.0 → 1.0.1 |

### プレリリース

```
1.0.0-alpha.1    # アルファ版
1.0.0-beta.2     # ベータ版
1.0.0-rc.1       # リリース候補
```

## git logからの情報抽出

### コミットメッセージ取得

```bash
# 最新タグから現在までのコミット
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# 特定の期間のコミット
git log --since="2024-01-01" --until="2024-01-31" --pretty=format:"%h - %s (%an, %ad)" --date=short

# Conventional Commits形式でフィルタ
git log --pretty=format:"%s" | grep -E "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?:"
```

### タグ情報取得

```bash
# すべてのタグを日付順で表示
git tag -l --sort=-version:refname

# タグ間の差分
git log v1.0.0..v1.1.0 --oneline

# タグの作成日時
git log --tags --simplify-by-decoration --pretty="format:%ai %d"
```

### PR情報の抽出

```bash
# GitHub CLIでPR情報取得
gh pr list --state merged --limit 100 --json number,title,mergedAt,labels

# マージされたPRのコミット取得
gh pr view 123 --json commits
```

## 自動生成ツール

### conventional-changelog（Node.js）

```bash
# インストール
npm install -g conventional-changelog-cli

# CHANGELOG生成
conventional-changelog -p angular -i CHANGELOG.md -s

# 初回生成（全履歴）
conventional-changelog -p angular -i CHANGELOG.md -s -r 0
```

### standard-version（Node.js）

```bash
# インストール
npm install -g standard-version

# バージョンアップ + CHANGELOG生成
standard-version

# 初回リリース
standard-version --first-release

# プレリリース
standard-version --prerelease alpha
```

### git-chglog（Go）

```bash
# インストール
brew install git-chglog

# 初期設定
git-chglog --init

# CHANGELOG生成
git-chglog -o CHANGELOG.md

# 特定バージョン
git-chglog v1.0.0..v1.1.0
```

## CHANGELOGのベストプラクティス

### 1. ユーザー視点で書く

```markdown
# ❌ 悪い例
- Refactored UserService class

# ✅ 良い例
- Improved user authentication performance by 50%
```

### 2. 技術的詳細は控えめに

```markdown
# ❌ 悪い例
- Changed database query from N+1 to eager loading with includes

# ✅ 良い例
- Fixed slow user list loading (reduced from 5s to 0.5s)
```

### 3. 破壊的変更は明示

```markdown
## [2.0.0] - 2024-01-15

### Changed
- **BREAKING**: Minimum Node.js version is now 16
- **BREAKING**: User API endpoint response format changed

### Migration Guide
See [MIGRATION.md](MIGRATION.md) for upgrade instructions.
```

### 4. issueとPRをリンク

```markdown
### Fixed
- Fixed authentication timeout (#123, @username)
- Resolved crash on startup (PR #456)
```

### 5. 日付形式の統一

```markdown
# ISO 8601形式（推奨）
## [1.0.0] - 2024-01-15

# または
## [1.0.0] - 2024-01-15T10:30:00Z
```

## リリースノート vs CHANGELOG

### CHANGELOG.md
- **対象**: 開発者、技術者
- **内容**: すべての変更を時系列で記録
- **形式**: Keep a Changelog
- **更新頻度**: 各リリースごと

### Release Notes（GitHub Releases等）
- **対象**: エンドユーザー、プロダクトマネージャー
- **内容**: 主要な変更、ハイライト
- **形式**: よりマーケティング寄り
- **更新頻度**: 重要なリリースのみ

### リリースノートの例

```markdown
# Version 2.0.0 - Major Update! 🎉

We're excited to announce Version 2.0 with significant improvements!

## 🚀 New Features
- **OAuth2 Support**: Sign in with Google and GitHub
- **Dark Mode**: New dark theme option in settings
- **Performance**: 3x faster page load times

## 💥 Breaking Changes
- Minimum Node.js version is now 16
- API response format has changed (see migration guide)

## 🐛 Bug Fixes
- Fixed crash on startup
- Resolved authentication timeout issues

## 📖 Documentation
Full changelog: [CHANGELOG.md](CHANGELOG.md)
Migration guide: [MIGRATION.md](MIGRATION.md)

## 🙏 Contributors
Thanks to @user1, @user2, @user3 for their contributions!
```

## GitHub Releasesとの連携

### gh CLIでリリース作成

```bash
# リリース作成
gh release create v1.0.0 \
  --title "Version 1.0.0" \
  --notes-file RELEASE_NOTES.md

# CHANGELOGから自動生成
gh release create v1.0.0 \
  --generate-notes

# プレリリース
gh release create v1.0.0-beta.1 \
  --prerelease \
  --notes "Beta release for testing"
```

### リリースノートの自動生成

GitHub Actionsでの自動化：

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0

      - name: Generate Changelog
        id: changelog
        run: |
          echo "## What's Changed" > release_notes.md
          git log $(git describe --tags --abbrev=0 HEAD^)..HEAD --pretty=format:"- %s (%h)" >> release_notes.md

      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body_path: release_notes.md
```

## CHANGELOGメンテナンスのワークフロー

### 1. 開発中

```bash
# Conventional Commitsでコミット
git commit -m "feat(auth): add OAuth2 support"
git commit -m "fix(ui): resolve button alignment issue"
```

### 2. リリース準備

```bash
# CHANGELOGを自動生成
conventional-changelog -p angular -i CHANGELOG.md -s

# または
standard-version

# 手動で編集（必要に応じて）
vim CHANGELOG.md
```

### 3. リリース

```bash
# タグ作成
git tag -a v1.0.0 -m "Release version 1.0.0"

# プッシュ
git push origin v1.0.0

# GitHub Releasesを作成
gh release create v1.0.0 --notes-file RELEASE_NOTES.md
```

### 4. リリース後

```bash
# 次の開発サイクル開始
# CHANGELOG.mdの[Unreleased]セクションに新しい変更を追加
```

## トラブルシューティング

### Q: Conventional Commitsに従っていない古いコミットがある

**A**: 手動でCHANGELOGを編集するか、フィルタリングする

```bash
# 特定のパターンにマッチするコミットのみ抽出
git log --grep="^feat\|^fix" --pretty=format:"%s"
```

### Q: マージコミットが多くてノイズになる

**A**: `--no-merges`オプションを使用

```bash
git log --no-merges --oneline
```

### Q: リリースごとにバージョン番号を決めるのが大変

**A**: semantic-releaseを使用した完全自動化

```bash
npm install -g semantic-release-cli
semantic-release-cli setup
```

## 参考資料

- [Keep a Changelog](https://keepachangelog.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [conventional-changelog](https://github.com/conventional-changelog/conventional-changelog)
- [standard-version](https://github.com/conventional-changelog/standard-version)
- [semantic-release](https://github.com/semantic-release/semantic-release)
