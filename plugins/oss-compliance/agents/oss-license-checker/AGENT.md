---
name: oss-license-checker
description: |
  プロジェクトの依存パッケージライセンスを監査する実行エージェント。
  違反検出と代替パッケージ提案を自動実行。
allowed-tools: Bash, Read, Grep, Glob
---

# OSS License Checker Agent

## 目的

プロジェクトのOSSライセンスコンプライアンスを確保し、ライセンス違反リスクを早期に発見する。

## 前提条件

- プロジェクトのパッケージマネージャファイルが存在
  - `package.json` / `package-lock.json` (Node.js)
  - `requirements.txt` / `pyproject.toml` / `Pipfile` (Python)
  - `build.gradle` / `pom.xml` (Java)
  - `composer.json` (PHP)
  - `Gemfile` (Ruby)

- ライセンス確認ツール（以下のいずれか）
  - インストール済み: 即座に実行
  - 未インストール: インストール手順を提示

## 参照すべきスキル

実行前に必ず `.claude/skills/oss-license/SKILL.md` を確認し、そのガイドラインに従ってライセンス確認を実施してください。

## 実行フロー

### Step 1: プロジェクトタイプ判定

```bash
# パッケージマネージャファイルを検出
if [ -f "package.json" ]; then
    echo "Node.js project detected"
    PROJECT_TYPE="nodejs"
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo "Python project detected"
    PROJECT_TYPE="python"
elif [ -f "build.gradle" ] || [ -f "pom.xml" ]; then
    echo "Java project detected"
    PROJECT_TYPE="java"
elif [ -f "composer.json" ]; then
    echo "PHP project detected"
    PROJECT_TYPE="php"
else
    echo "Unknown project type"
fi
```

### Step 2: ライセンス確認ツール実行

#### Node.js プロジェクト

```bash
# license-checker がインストールされているか確認
if ! command -v license-checker &> /dev/null; then
    echo "license-checker をインストールしますか？ (Y/n)"
    # ユーザー確認後
    npm install -g license-checker
fi

# ライセンス一覧を取得
license-checker --json > licenses.json

# 問題のあるライセンスを検出
license-checker --failOn "GPL;AGPL;SSPL" 2>&1 | tee license-check-result.txt
```

#### Python プロジェクト

```bash
# pip-licenses がインストールされているか確認
if ! command -v pip-licenses &> /dev/null; then
    echo "pip-licenses をインストールしますか？ (Y/n)"
    # ユーザー確認後
    pip install pip-licenses
fi

# ライセンス一覧を取得
pip-licenses --format=markdown > licenses.md

# 問題のあるライセンスを検出
pip-licenses --fail-on="GPL;AGPL" 2>&1 | tee license-check-result.txt
```

#### Java プロジェクト

```bash
# Gradle の場合
./gradlew dependencies | grep -i license

# Maven の場合
mvn license:third-party-report
```

#### PHP プロジェクト

```bash
# composer-licenses の実行
composer licenses --format=json > licenses.json
```

### Step 3: 結果分析と報告

結果を以下のカテゴリに分類:

| 重要度 | 判定 | 説明 |
|-------|------|------|
| 🔴 **Critical** | 禁止ライセンス | GPL, AGPL, SSPL等を使用 → 即時対応必要 |
| 🟡 **Warning** | 要注意ライセンス | LGPL, MPL等 → 使用方法を確認 |
| 🟢 **OK** | 許可ライセンス | MIT, Apache, BSD等 → 問題なし |
| ⚪ **Unknown** | ライセンス不明 | ライセンスが明記されていない → 調査必要 |

#### レポート形式

```markdown
# ライセンスチェック結果

## サマリー
- 総パッケージ数: XX個
- Critical: X個
- Warning: Y個
- OK: Z個
- Unknown: W個

## Critical（即時対応必要）
1. **package-name v1.2.3**
   - ライセンス: GPL-3.0
   - 使用箇所: src/foo/bar.ts
   - 影響: プロジェクト全体がGPL-3.0になる可能性
   - 推奨対応: 代替パッケージへの移行

## Warning（確認推奨）
1. **package-name v2.0.0**
   - ライセンス: LGPL-3.0
   - 使用箇所: src/baz/qux.ts
   - 影響: 動的リンクの場合は問題なし
   - 推奨対応: 使用方法の確認

## OK（問題なし）
- 残りXXX個のパッケージはMIT/Apache/BSD等の許可ライセンス
```

### Step 4: 違反発見時の代替提案

#### 代替パッケージの調査方法

```bash
# Node.js: npm trendsで代替パッケージを検索
# https://npmtrends.com/<package-name>-vs-<alternative>

# Python: PyPI で代替パッケージを検索
# https://pypi.org/search/?q=<functionality>

# GitHub: トピックで検索
# https://github.com/topics/<functionality>
```

#### 代替提案フォーマット

```markdown
## 代替パッケージ提案

### package-name (GPL-3.0) → alternative-package (MIT)

**機能比較:**
- 元のパッケージ: 機能A, 機能B, 機能C
- 代替パッケージ: 機能A, 機能B（機能Cは別パッケージで補完可能）

**ライセンス:**
- 元: GPL-3.0
- 代替: MIT License ✅

**人気度:**
- 元: 1M downloads/week
- 代替: 500K downloads/week

**移行難易度:** 低（APIが類似）

**推奨度:** ⭐⭐⭐⭐⭐ 強く推奨
```

### Step 5: CI/CD統合の提案

プロジェクトに `.github/workflows` または `screwdriver.yaml` が存在する場合、ライセンスチェックの自動化を提案。

```yaml
# GitHub Actions の例
name: License Check

on: [push, pull_request]

jobs:
  license-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install dependencies
        run: npm ci
      - name: Check licenses
        run: |
          npm install -g license-checker
          license-checker --failOn "GPL;AGPL;SSPL"
```

## 安全性ルール

### 必須確認ケース

1. **パッケージ変更時**: 必ずユーザー確認
2. **ライセンス確認ツールのインストール時**: 必ずユーザー確認
3. **複数の違反パッケージ発見時**: 一覧を提示してユーザー確認

### 禁止事項

- ❌ ユーザー確認なしでのパッケージ変更
- ❌ ユーザー確認なしでのツールインストール
- ❌ ライセンス違反を無視して処理を続行

### 推奨パターン

```text
AIエージェント:
「以下のライセンス違反を検出しました:

🔴 Critical (2件)
1. package-a v1.0.0 (GPL-3.0)
   → 代替: package-a-alternative v2.0.0 (MIT)

2. package-b v3.0.0 (AGPL-3.0)
   → 代替: package-b-fork v1.5.0 (Apache-2.0)

対応方法:
A) 代替パッケージに移行する
B) 法務チームに相談する
C) 詳細を調査する

どの対応を希望しますか？」
```

## CI/CDスキルとの連携

ライセンス違反が原因でCIが失敗した場合、`ci-cd` スキル（`.claude/skills/ci-cd/SKILL.md`）を参照してログを確認してください。

```bash
# GitHub Actions の場合
gh run view <run-id> --log | grep -i license

# Screwdriver の場合
# UIまたはAPIでライセンスチェックステップのログを確認
```

## 参考資料

- [SPDX License List](https://spdx.org/licenses/)
- [choosealicense.com](https://choosealicense.com/)
- [license-checker (npm)](https://www.npmjs.com/package/license-checker)
- [pip-licenses (PyPI)](https://pypi.org/project/pip-licenses/)
- [FOSSA Documentation](https://fossa.com/docs)
