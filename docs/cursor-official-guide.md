# Cursor公式仕様準拠ガイド

[Cursor公式ドキュメント](https://docs.cursor.com/ja/context/rules)に基づいた、Project Rulesの正しい使い方を説明します。

## 📋 Cursorのルールシステム

Cursorは4種類のルールをサポートしています：

### 1. Project Rules（推奨）
- **場所**: `.cursor/rules/*.mdc`
- **特徴**: メタデータ付き、細かい制御、バージョン管理
- **形式**: MDC（Markdown with metadata）

### 2. AGENTS.md
- **場所**: プロジェクトルート
- **特徴**: シンプルなMarkdown、メタデータなし
- **用途**: 小規模プロジェクト、簡単な指示

### 3. User Rules
- **場所**: Cursor設定（グローバル）
- **特徴**: 全プロジェクトに適用
- **用途**: 個人の好み、共通設定

### 4. .cursorrules（非推奨）
- **場所**: プロジェクトルート
- **状態**: レガシー、今後廃止予定

## 🏗️ 推奨されるプロジェクト構造

```
my-project/
├── .cursor/
│   └── rules/                    # Project Rules ディレクトリ
│       ├── general.mdc          # 常に適用されるルール
│       ├── typescript.mdc       # TypeScript用（glob自動適用）
│       ├── api-patterns.mdc     # API設計パターン（AI判断）
│       └── workflows.mdc        # 特殊ワークフロー（手動）
├── backend/
│   └── .cursor/
│       └── rules/               # バックエンド固有ルール
│           └── database.mdc
├── frontend/
│   └── .cursor/
│       └── rules/               # フロントエンド固有ルール
│           └── react.mdc
└── AGENTS.md                    # オプション（シンプルな代替）
```

## 📝 MDCファイルの構造

```mdc
---
description: TypeScript開発のベストプラクティス
globs:
  - "**/*.ts"
  - "**/*.tsx"
alwaysApply: false
---

# TypeScript Development Rules

ここにMarkdown形式でルールを記述...
```

### メタデータフィールド

| フィールド | 説明 | 必須 |
|-----------|------|------|
| `description` | ルールの説明（AI判断時に使用） | Agent Requestedの場合 |
| `globs` | 自動適用するファイルパターン | Auto Attachedの場合 |
| `alwaysApply` | 常に適用するか（デフォルト: false） | いいえ |

## 🎯 ルールタイプの使い分け

### Always（常に適用）
```mdc
---
description: プロジェクト全体の基本ルール
alwaysApply: true
---
```
**使用例**: コーディング規約、セキュリティポリシー

### Auto Attached（glob自動適用）
```mdc
---
description: React コンポーネント開発ルール
globs:
  - "**/*.tsx"
  - "**/components/**"
alwaysApply: false
---
```
**使用例**: 言語固有のルール、フレームワーク固有のパターン

### Agent Requested（AI判断）
```mdc
---
description: GraphQL API実装のベストプラクティス
alwaysApply: false
---
```
**使用例**: 特定の実装パターン、アーキテクチャガイドライン

### Manual（手動適用）
```mdc
---
description: データベースマイグレーション手順
alwaysApply: false
---
```
**使用例**: 特殊なワークフロー、危険な操作

## 💡 ベストプラクティス

### 1. ルールの整理
- 機能ごとに別々の`.mdc`ファイルに分割
- わかりやすいファイル名を使用
- 適切なディレクトリ構造で整理

### 2. メタデータの活用
- `description`は明確で具体的に
- `globs`は必要最小限に
- `alwaysApply`は慎重に使用

### 3. ネストされたルール
```
backend/
  .cursor/rules/     # バックエンド開発時のみ適用
frontend/
  .cursor/rules/     # フロントエンド開発時のみ適用
```

### 4. ルールの参照
- チャット内で`@ruleName`で特定のルールを参照
- ファイル参照を含める: `@filename.ts`

## 🚀 実装例

### 基本的な開発ルール（general.mdc）
```mdc
---
description: 全プロジェクト共通の開発ルール
alwaysApply: true
---

# 基本開発ルール

- 日本語で応答してください
- クリーンコードの原則に従う
- テスト駆動開発を実践
```

### TypeScript専用ルール（typescript.mdc）
```mdc
---
description: TypeScript固有の開発パターン
globs:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.d.ts"
alwaysApply: false
---

# TypeScript開発

- strictモードを有効化
- any型の使用禁止
- 型推論を活用
```

### API設計ルール（api-design.mdc）
```mdc
---
description: RESTful API設計のガイドライン
alwaysApply: false
---

# API設計ガイド

AIがこのルールを適用すべきと判断した場合に使用
```

## 🔄 移行ガイド

### .cursorrulesからの移行

1. `.cursor/rules/`ディレクトリを作成
2. 既存の`.cursorrules`を適切な`.mdc`ファイルに分割
3. メタデータを追加
4. `.cursorrules`を削除

### グローバル設定からの移行

以前の`~/.cursor/.mdc`などのグローバル設定は、User Rules（Cursor設定）に移行するか、各プロジェクトの`.cursor/rules/`にコピーしてください。

## 📚 参考資料

- [Cursor公式ドキュメント - ルール](https://docs.cursor.com/ja/context/rules)
- [コミュニティルールコレクション](https://github.com/PatrickJS/awesome-cursorrules)

---

このガイドは2024年のCursor最新仕様に基づいています。
