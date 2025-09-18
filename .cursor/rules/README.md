# Cursor Rules Examples

このディレクトリには、Cursor公式仕様に準拠したProject Rules（`.mdc`形式）のサンプルが含まれています。

## 📁 ディレクトリ構造

```
.cursor/
└── rules/
    ├── general.mdc      # 全般的な開発ルール
    ├── java-spring.mdc  # Java Spring Boot用ルール
    ├── php.mdc         # PHP開発用ルール
    ├── perl.mdc        # Perl開発用ルール
    ├── python.mdc      # Python開発用ルール
    └── database.mdc    # データベース設計ルール
```

## 🔧 ルールの種類

[Cursor公式ドキュメント](https://docs.cursor.com/ja/context/rules)に基づく4つのタイプ：

| タイプ | 説明 | 使用例 |
|--------|------|--------|
| **Always** | 常にコンテキストに含まれる | 基本的なコーディング規約 |
| **Auto Attached** | globパターンで自動適用 | 言語固有のルール |
| **Agent Requested** | AIが判断して適用 | 特定の機能実装パターン |
| **Manual** | @ruleNameで明示的に適用 | 特殊なワークフロー |

## 📝 .mdc ファイルの構造

```mdc
---
description: ルールの説明（Agent Requestedの場合必須）
globs:
  - "**/*.ts"              # 対象ファイルパターン
  - "**/*.tsx"
alwaysApply: false         # 常に適用するか
---

# ルールの内容

ここにMarkdown形式でルールを記述
```

## 🚀 使い方

### 1. プロジェクトへの適用

> **💡 推奨**: 方法Aのインストールスクリプトを使用すると、対話的に必要なルールを選択でき、最も簡単です。

#### 方法A: インストールスクリプト使用（推奨）
```bash
# プロジェクトルートで実行
bash <(curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-project.sh)
```

#### 方法B: 直接ダウンロード
```bash
# プロジェクトルートで実行
mkdir -p .cursor/rules

# 基本ルール
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/.cursor/rules/general.mdc -o .cursor/rules/general.mdc

# 言語固有ルール（例：Python）
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/.cursor/rules/python.mdc -o .cursor/rules/python.mdc
```

#### 方法C: リポジトリクローン後コピー
```bash
# 一時的にクローン
git clone https://github.com/sk8metalme/ai-agent-setup.git /tmp/ai-agent-setup
mkdir -p .cursor/rules
cp /tmp/ai-agent-setup/.cursor/rules/*.mdc .cursor/rules/
rm -rf /tmp/ai-agent-setup
```

**各方法の特徴:**
- **方法A**: 対話的選択、言語別インストール、AGENTS.mdも同時取得可能
- **方法B**: 必要なファイルのみ選択的取得、軽量
- **方法C**: 全ファイル一括取得、オフライン作業可能

### 2. ネストされたルール

```
project/
  .cursor/rules/           # プロジェクト全体
  backend/
    .cursor/rules/         # バックエンド固有
  frontend/
    .cursor/rules/         # フロントエンド固有
```

### 3. ルールの参照

チャット内で：
- `@general` - 特定のルールを参照
- ファイル編集時に自動でglobマッチングされたルールが適用

## 🆚 他の方式との比較

| 方式 | 場所 | 特徴 | 推奨度 |
|------|------|------|--------|
| **Project Rules** | `.cursor/rules/*.mdc` | 細かい制御、バージョン管理 | ✅ 推奨 |
| **AGENTS.md** | プロジェクトルート | シンプル、Markdown形式 | ⭕ シンプルな用途 |
| **User Rules** | Cursor設定 | グローバル適用 | ⭕ 個人設定 |
| **.cursorrules** | プロジェクトルート | レガシー | ❌ 非推奨 |

## 💡 ベストプラクティス

1. **モジュール化**: 機能ごとに別々の`.mdc`ファイルに分割
2. **明確な説明**: `description`フィールドを活用
3. **適切なスコープ**: `globs`でファイルパターンを指定
4. **バージョン管理**: `.cursor/rules`をGitで管理

## 🔗 参考リンク

- [Cursor公式ドキュメント - ルール](https://docs.cursor.com/ja/context/rules)
- [コミュニティルールコレクション](https://github.com/PatrickJS/awesome-cursorrules)
