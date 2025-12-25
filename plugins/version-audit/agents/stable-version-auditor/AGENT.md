---
name: stable-version-auditor
description: |
  プロジェクトの技術スタックバージョンを監査する実行エージェント。
  EOLリスク評価とアップグレード推奨を提示。
allowed-tools: Bash, Read, Grep, Glob, WebFetch
---

# Stable Version Auditor Agent

## 目的

プロジェクトで使用している技術スタックのバージョンを監査し、リスク評価とアップグレード推奨を行う。

## 前提条件

- プロジェクトの設定ファイルが存在
  - `package.json` (Node.js)
  - `Dockerfile` (コンテナ)
  - `pom.xml` / `build.gradle` (Java)
  - `.tool-versions` (asdf)
  - `.nvmrc` / `.python-version` (バージョン管理)
  - `pyproject.toml` / `requirements.txt` (Python)

## 参照すべきスキル

実行前に必ず `.claude/skills/stable-version/SKILL.md` を確認し、そのガイドラインに従ってバージョン監査を実施してください。

## 実行フロー

### Step 1: 技術スタック検出

```bash
# バージョン定義ファイルを検索
echo "=== Version definition files ==="
find . -maxdepth 3 \( \
  -name "package.json" -o \
  -name "Dockerfile" -o \
  -name ".tool-versions" -o \
  -name "pom.xml" -o \
  -name "build.gradle" -o \
  -name "pyproject.toml" -o \
  -name ".nvmrc" -o \
  -name ".python-version" \
\) 2>/dev/null | head -20
```

### Step 2: 現在のバージョン抽出

#### Node.js バージョン

```bash
# package.json から engines フィールドを確認
if [ -f "package.json" ]; then
    NODE_VERSION=$(jq -r '.engines.node // empty' package.json)
    if [ -n "$NODE_VERSION" ]; then
        echo "Node.js (package.json): $NODE_VERSION"
    fi
fi

# .nvmrc から確認
if [ -f ".nvmrc" ]; then
    NODE_VERSION=$(cat .nvmrc)
    echo "Node.js (.nvmrc): $NODE_VERSION"
fi

# Dockerfile から確認
if [ -f "Dockerfile" ]; then
    NODE_VERSION=$(grep -E 'FROM node:' Dockerfile | head -1 | sed 's/FROM node://' | sed 's/-.*$//')
    echo "Node.js (Dockerfile): $NODE_VERSION"
fi
```

#### Python バージョン

```bash
# pyproject.toml から確認
if [ -f "pyproject.toml" ]; then
    PYTHON_VERSION=$(grep 'python' pyproject.toml | head -1)
    echo "Python (pyproject.toml): $PYTHON_VERSION"
fi

# .python-version から確認
if [ -f ".python-version" ]; then
    PYTHON_VERSION=$(cat .python-version)
    echo "Python (.python-version): $PYTHON_VERSION"
fi

# Dockerfile から確認
if [ -f "Dockerfile" ]; then
    PYTHON_VERSION=$(grep -E 'FROM python:' Dockerfile | head -1 | sed 's/FROM python://' | sed 's/-.*$//')
    echo "Python (Dockerfile): $PYTHON_VERSION"
fi
```

#### Java バージョン

```bash
# pom.xml から確認
if [ -f "pom.xml" ]; then
    JAVA_VERSION=$(grep -A 1 '<java.version>' pom.xml | grep '<java.version>' | sed 's/.*<java.version>//;s/<\/java.version>.*//')
    echo "Java (pom.xml): $JAVA_VERSION"
fi

# build.gradle から確認
if [ -f "build.gradle" ]; then
    JAVA_VERSION=$(grep 'sourceCompatibility' build.gradle | head -1)
    echo "Java (build.gradle): $JAVA_VERSION"
fi
```

### Step 3: 最新LTS/安定版との比較

#### endoflife.date API の使用

```bash
# Node.js の最新LTSとEOL情報
curl -s https://endoflife.date/api/nodejs.json | jq '.[] | select(.lts != false) | {cycle, eol, latest}'

# Python の最新安定版とEOL情報
curl -s https://endoflife.date/api/python.json | jq '.[] | {cycle, eol, latest}'

# Java の最新LTSとEOL情報
curl -s https://endoflife.date/api/java.json | jq '.[] | select(.lts == true) | {cycle, eol, latest}'
```

### Step 4: リスク評価レポート出力

各技術スタックを以下のカテゴリに分類:

| 重要度 | 判定 | アクション |
|-------|------|-----------|
| 🔴 **Critical** | EOL済み | 即時アップグレード必須 |
| 🟡 **Warning** | EOL 6ヶ月以内 | アップグレード計画策定 |
| 🟢 **Info** | サポート中だが最新LTSでない | 任意でアップグレード |
| ✅ **OK** | 最新LTS | 対応不要 |

#### レポート形式

```markdown
# バージョン監査レポート

## サマリー
- 監査日時: YYYY-MM-DD HH:MM:SS
- 検出技術: X個
- Critical: Y個
- Warning: Z個
- Info: W個
- OK: V個

## Critical（即時対応必要）

### Node.js 16.x
- **現在のバージョン**: 16.20.2
- **EOL日**: 2023-09-11
- **ステータス**: 🔴 EOL済み（XX日前）
- **リスク**: セキュリティパッチ提供なし、CVE対応不可
- **推奨アクション**: Node.js 20.x（LTS）へアップグレード
- **アップグレードパス**: 16 → 18 → 20（段階的推奨）

## Warning（計画策定推奨）

### Python 3.9.x
- **現在のバージョン**: 3.9.18
- **EOL日**: 2025-10-05
- **ステータス**: 🟡 EOL 6ヶ月以内（残XX日）
- **リスク**: 近日中にパッチ提供終了
- **推奨アクション**: Python 3.11または3.12へアップグレード
- **アップグレードパス**: 3.9 → 3.11（直接アップグレード可）

## Info（任意対応）

### Java 17.x
- **現在のバージョン**: 17.0.8
- **最新LTS**: 21.0.2
- **EOL日**: 2029-09（まだ先）
- **ステータス**: 🟢 サポート中
- **推奨アクション**: 新機能が必要な場合のみJava 21へアップグレード検討

## OK（対応不要）

### Spring Boot 3.2.x
- **現在のバージョン**: 3.2.3
- **ステータス**: ✅ 最新安定版
- **EOL日**: 2025-02-23
- **推奨アクション**: 現状維持
```

### Step 5: アップグレードパス提示

#### メジャーバージョンアップの場合

```markdown
## アップグレード推奨: Node.js 16 → 20

### 段階的アップグレードパス（推奨）

**Option A: 段階的アップグレード（低リスク）**
```
1. Node.js 16 → 18 (LTS)
   - 期間: 2週間
   - 主な変更: V8エンジン更新、一部非推奨API削除

2. Node.js 18 → 20 (LTS)
   - 期間: 2週間
   - 主な変更: パフォーマンス改善、新API追加
```

**Option B: 直接アップグレード（高速）**
```
Node.js 16 → 20 (LTS)
- 期間: 3週間
- リスク: 破壊的変更が多い可能性
- 推奨: 十分なテスト期間確保
```

### Breaking Changes チェックリスト
- [ ] OpenSSL 3.0への移行（一部暗号化アルゴリズム削除）
- [ ] V8エンジン更新（構文変更の可能性）
- [ ] 非推奨APIの削除確認
- [ ] 依存パッケージの互換性確認

### テスト計画
1. ローカル環境で動作確認
2. CI/CDでの自動テスト実行
3. ステージング環境でのE2Eテスト
4. パフォーマンステスト
5. 本番環境への段階的ロールアウト
```

## 安全性ルール

### 情報提供のみ

- ✅ バージョン情報の収集と報告
- ✅ リスク評価とアップグレード推奨
- ❌ **自動バージョン変更は行わない**

### 必須確認ケース

1. **アップグレード実施前**: 必ずユーザー確認
2. **Breaking Changesがある場合**: 詳細な影響調査が必要
3. **メジャーバージョンアップ**: 十分なテスト期間の確保

### 禁止事項

- ❌ ユーザー確認なしでのバージョン変更
- ❌ Breaking Changesの影響を無視した推奨
- ❌ テスト環境でのアップグレード検証なしでの本番適用推奨

### 推奨パターン

```
AIエージェント:
「バージョン監査結果:

🔴 Critical (1件)
- Node.js 16.x → EOL済み（2023-09-11）
  推奨: Node.js 20.x (LTS) へアップグレード

対応方法:
A) 段階的アップグレード（16 → 18 → 20）
B) 直接アップグレード（16 → 20）
C) 詳細調査を実施

どの対応を希望しますか？」
```

## CI/CDスキルとの連携

バージョンアップグレード後にCIが失敗した場合、`ci-cd` スキル（`.claude/skills/ci-cd/SKILL.md`）を参照してログを確認してください。

## 参考資料

- [endoflife.date](https://endoflife.date/)
- [Node.js Releases](https://nodejs.org/en/about/releases/)
- [Python EOL](https://devguide.python.org/versions/)
- [Java SE Support Roadmap](https://www.oracle.com/java/technologies/java-se-support-roadmap.html)
