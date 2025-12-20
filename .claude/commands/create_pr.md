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

3. **バージョン管理の確認**
   - バージョン管理ファイルの存在確認（package.json, VERSION, pyproject.toml等）
   - バージョンファイルが存在する場合、現在のバージョンを表示
   - ユーザーにバージョン更新が必要か確認
   - セマンティックバージョニングに基づく推奨：
     - **MAJOR (x.0.0)**: 破壊的変更（後方互換性のない変更）
     - **MINOR (0.x.0)**: 機能追加（後方互換性あり）
     - **PATCH (0.0.x)**: バグ修正、軽微な変更
   - 更新する場合はバージョンを更新してコミット

4. **ターゲットブランチの確認**
   - ユーザーにターゲットブランチを確認
   - デフォルト: main

5. **リモートへプッシュ**
   - 現在のブランチをリモートにプッシュ
   - まだプッシュしていない場合は `-u origin [ブランチ名]`

6. **PR作成**
   - `gh pr create` でPR作成
   - タイトル：最新のコミットメッセージから自動生成
   - 本文：変更内容のサマリーを自動生成
   - ブラウザでPRページを自動で開く

## 実行手順

このコマンドを実行すると、以下の処理を順番に実行します。

```bash
# ステップ1: 現在のブランチを確認
current_branch=$(git branch --show-current)

# main/masterブランチでないことを確認
if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
  echo "Error: main/masterブランチからはPRを作成できません"
  exit 1
fi

# ステップ2: 未コミット変更と差分の確認
git status

# mainブランチとの差分を確認
git log main..HEAD --oneline
git diff main...HEAD --stat

# ステップ3: バージョン管理ファイルの確認
# 各言語のバージョンファイルを検出
version_file=""
current_version=""

# Node.js/TypeScript
if [ -f "package.json" ]; then
  version_file="package.json"
  current_version=$(jq -r '.version' package.json 2>/dev/null || grep '"version"' package.json | sed 's/.*"version": "\(.*\)".*/\1/')
  echo "検出: Node.js/TypeScript プロジェクト"
  echo "現在のバージョン: $current_version"

# Java (Maven)
elif [ -f "pom.xml" ]; then
  version_file="pom.xml"
  current_version=$(grep '<version>' pom.xml | head -1 | sed 's/.*<version>\(.*\)<\/version>.*/\1/')
  echo "検出: Java Maven プロジェクト"
  echo "現在のバージョン: $current_version"

# Java (Gradle)
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  version_file="build.gradle"
  current_version=$(grep '^version' build.gradle 2>/dev/null | sed "s/version[= ]*['\"]\\(.*\\)['\"].*/\1/")
  echo "検出: Java Gradle プロジェクト"
  echo "現在のバージョン: $current_version"

# Python
elif [ -f "pyproject.toml" ]; then
  version_file="pyproject.toml"
  current_version=$(grep '^version' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
  echo "検出: Python プロジェクト"
  echo "現在のバージョン: $current_version"

# PHP
elif [ -f "composer.json" ]; then
  version_file="composer.json"
  current_version=$(jq -r '.version' composer.json 2>/dev/null || grep '"version"' composer.json | sed 's/.*"version": "\(.*\)".*/\1/')
  echo "検出: PHP プロジェクト"
  echo "現在のバージョン: $current_version"

# Ansible
elif [ -f "galaxy.yml" ]; then
  version_file="galaxy.yml"
  current_version=$(grep '^version:' galaxy.yml | awk '{print $2}')
  echo "検出: Ansible Collection"
  echo "現在のバージョン: $current_version"

# RPM
elif ls *.spec 1>/dev/null 2>&1; then
  version_file=$(ls *.spec | head -1)
  current_version=$(grep '^Version:' "$version_file" | awk '{print $2}')
  echo "検出: RPM パッケージ"
  echo "現在のバージョン: $current_version"

# Rust
elif [ -f "Cargo.toml" ]; then
  version_file="Cargo.toml"
  current_version=$(grep '^version' Cargo.toml | sed 's/version = "\(.*\)"/\1/')
  echo "検出: Rust プロジェクト"
  echo "現在のバージョン: $current_version"

# Ruby
elif ls *.gemspec 1>/dev/null 2>&1; then
  version_file=$(ls *.gemspec | head -1)
  current_version=$(grep "\.version" "$version_file" | sed "s/.*version[= ]*['\"]\\(.*\\)['\"].*/\1/")
  echo "検出: Ruby Gem"
  echo "現在のバージョン: $current_version"

# 汎用バージョンファイル
elif [ -f "VERSION" ]; then
  version_file="VERSION"
  current_version=$(cat VERSION)
  echo "検出: VERSION ファイル"
  echo "現在のバージョン: $current_version"

elif [ -f "version.txt" ]; then
  version_file="version.txt"
  current_version=$(cat version.txt)
  echo "検出: version.txt ファイル"
  echo "現在のバージョン: $current_version"
fi

# バージョン更新の確認
if [ -n "$version_file" ]; then
  echo ""
  echo "セマンティックバージョニング推奨:"
  echo "  - MAJOR (x.0.0): 破壊的変更（後方互換性のない変更）"
  echo "  - MINOR (0.x.0): 機能追加（後方互換性あり）"
  echo "  - PATCH (0.0.x): バグ修正、軽微な変更"
  echo ""
  # AskUserQuestionで確認（スキップ / PATCH / MINOR / MAJOR）
  # 更新する場合は該当ファイルを編集してコミット
fi

# ステップ4: ターゲットブランチをユーザーに確認
# AskUserQuestionで確認（デフォルト: main）

# ステップ5: リモートにプッシュ
git push -u origin "$current_branch"

# ステップ6: PR作成
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
- バージョン管理ファイルが存在しない場合、バージョン更新ステップは自動的にスキップされます
- サポートされるバージョンファイル：
  - Node.js/TypeScript: `package.json`
  - Java: `pom.xml` (Maven), `build.gradle` (Gradle)
  - Python: `pyproject.toml`
  - PHP: `composer.json`
  - Ansible: `galaxy.yml`
  - RPM: `*.spec`
  - Rust: `Cargo.toml`
  - Ruby: `*.gemspec`
  - 汎用: `VERSION`, `version.txt`
