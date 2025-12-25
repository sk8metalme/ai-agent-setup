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
   - `/review` でコードレビューを実行
   - `/security-review` でセキュリティレビューを実行
   - 指摘があればユーザーに修正確認→修正→再レビュー（ループ）

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

# ステップ2.5: コードレビュー・セキュリティレビュー
# Claude Code実行時の処理:
# 1. git diff main...HEAD の結果を取得
# 2. /review スキルでコードレビューを実行
# 3. /security-review スキルでセキュリティレビューを実行
# 4. 指摘事項がある場合:
#    a. AskUserQuestionツールで修正するか確認
#       - 修正する: 修正を実施し、ステップ2.5を再実行
#       - スキップ: 次のステップへ進む
# 5. 指摘事項がない場合: 次のステップへ進む
#
# 注意: このループは指摘事項がなくなるまで繰り返される

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
  # xmllintを使用してプロジェクトレベルの<version>を抽出（推奨）
  # 注意: xmllintが利用できない場合、親プロジェクトのバージョンを誤って取得する可能性があります
  current_version=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' pom.xml 2>/dev/null)
  if [ -z "$current_version" ]; then
    # xmllintが利用できない場合の代替手段（制限あり）
    # 親タグと同じ行にない<version>タグのみを抽出
    current_version=$(awk '/<parent>/,/<\/parent>/ {next} /<version>/ {match($0, /<version>(.*)<\/version>/, arr); if (arr[1]) {print arr[1]; exit}}' pom.xml)
  fi
  echo "検出: Java Maven プロジェクト"
  echo "現在のバージョン: $current_version"

# Java (Gradle)
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  # build.gradle.ktsを優先、なければbuild.gradle
  if [ -f "build.gradle.kts" ]; then
    version_file="build.gradle.kts"
    current_version=$(grep -E '^\s*version\s*[=:]' build.gradle.kts | head -1 | sed 's/.*version\s*[=:]\s*['\''\"]\(.*\)['\''\"].*/\1/')
  else
    version_file="build.gradle"
    current_version=$(grep -E '^\s*version\s*[=:]' build.gradle | head -1 | sed "s/.*version\s*[=:]\s*['\"]\\(.*\\)['\"].*/\1/")
  fi
  echo "検出: Java Gradle プロジェクト"
  echo "現在のバージョン: $current_version"

# Python
elif [ -f "pyproject.toml" ]; then
  version_file="pyproject.toml"
  # 単一引用符と二重引用符の両方に対応
  current_version=$(grep '^version' pyproject.toml | sed "s/version\s*=\s*['\"]\\(.*\\)['\"].*/\1/")
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

  # Claude Code実行時の処理:
  # 1. AskUserQuestionツールで以下を確認:
  #    - スキップ: バージョン更新しない
  #    - PATCH: パッチバージョンを上げる
  #    - MINOR: マイナーバージョンを上げる
  #    - MAJOR: メジャーバージョンを上げる
  #
  # 2. ユーザーが更新を選択した場合:
  #    a. 該当ファイルを編集してバージョンを更新
  #    b. git add <version_file>
  #    c. git commit -m "chore: bump version to <new_version>"
  #
  # 注意: このスクリプトはドキュメント例です。
  # 実際の実行はClaude Codeが上記の手順に従って行います。
fi

# ステップ4: ターゲットブランチをユーザーに確認
# Claude Code実行時の処理:
# AskUserQuestionツールで以下を確認:
#   - main（推奨）: メインブランチにマージ
#   - develop: 開発ブランチにマージ
#   - その他: ユーザーが指定したブランチ
# デフォルト: main
target_branch="main"  # 実際はユーザーの選択によって決定

# ステップ5: リモートにプッシュ
git push -u origin "$current_branch"

# ステップ6: PR作成
# $target_branchは実際にはステップ4で確認したブランチ名
gh pr create --base "$target_branch" --title "コミット履歴をまとめた概要を端的に説明したタイトル" --body "コミット履歴のサマリー、変更ファイル一覧、テストプラン（必要に応じて）"
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
