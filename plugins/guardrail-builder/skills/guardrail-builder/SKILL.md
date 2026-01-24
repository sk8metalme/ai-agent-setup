---
name: guardrail-builder
description: "会話履歴から学習内容を自動抽出し、.claude/rules/ 以下にカテゴリ別の個別Markdownファイルとして保存（プロジェクトメモリとして自動読み込み）。プロジェクト仕様、エラー対応、コーディング規約、Tipsに分類し、同じ間違いを防止。"
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# guardrail-builder スキル

**あなたの役割**: 会話履歴を分析し、学習内容を `.claude/rules/` 以下にカテゴリ別の個別Markdownファイルとして保存すること。

## 目的

プロジェクト固有のルール、エラー対応、コーディング規約、Tipsを「1ルール1Markdown」形式で自動記録し、同じ間違いを繰り返さないようにする。

**重要**: これらのファイルは `.claude/rules/` ディレクトリに配置され、Claude Code により**自動的にプロジェクトメモリとして読み込まれます**。CLAUDE.md への `@` インポートは不要です。

**v2.0.0の変更点**: 単一ファイル（guardrail.md）から、カテゴリ別ディレクトリ構造（1ルール1MD）に移行しました。既存の guardrail.md は引き続き読み込まれます。

---

## 実行タイミング

- **手動実行**: `/guardrail-builder` コマンド

---

## 分析基準

### 対象となる内容

以下の4カテゴリに該当する内容を抽出：

#### 1. プロジェクト仕様
- リポジトリ独自の仕様、設計方針
- プロジェクト固有のアーキテクチャパターン
- 「このプロジェクトでは〜を使う」という指示

**例**:
- 環境変数は Config モジュール経由で取得する
- Controller内でparamsを直接渡さないルール
- ORMの標準メソッドではなく、既存のfinderメソッドを使う

#### 2. エラー対応
- 誤った作業、やり直した作業
- ハマったポイント、解決した問題
- 「これは動かない」「こうすると失敗する」という学習

**例**:
- Claude Code の skills パスは `/SKILL.md` を含めると動かない
- YAML の `description: |` 形式は Claude Code で解析できない
- marketplace.json と plugin.json のバージョンは必ず同期する

#### 3. コーディング規約
- 指摘されたコーディングルール
- スタイルガイド、命名規則
- 「こう書くべき」という指示

**例**:
- テストファイルは `*.test.ts` 形式を使用
- 関数名は動詞から始める
- エラーハンドリングは必ず try-catch で囲む

#### 4. Tips
- 調査して得られた知見
- 覚えておくべき情報
- 便利なツール・コマンド

**例**:
- `claude --plugin-dir` でローカルテストが可能
- `jq -r '.plugins[] | .name'` でプラグイン一覧を取得
- GitHub Issue #9817 で skills の問題が報告されている

### パス固有ルールの判断

ルールが特定のファイルタイプやディレクトリに限定されるか判断：

**paths を設定すべきケース**:
- 「API ファイルでは〜」→ `paths: src/api/**/*`
- 「テストファイルでは〜」→ `paths: **/*.test.ts`
- 「React コンポーネントでは〜」→ `paths: **/*.tsx`
- 「src/ 以下では〜」→ `paths: src/**/*`

**paths を省略すべきケース**:
- プロジェクト全体に適用されるルール
- 特定のファイルタイプに限定されないルール
- 汎用的なコーディング規約

**グロブパターンの活用**:
- `**/*.{ts,tsx}` - 複数の拡張子
- `{src,lib}/**/*.ts` - 複数のディレクトリ
- `tests/**/*.test.ts` - 特定のパターン

---

## 重複チェック

**重要**: 既存の guardrail.md の内容と**セマンティック（意味的）な重複**をチェックし、類似内容は追記しない。

### 重複判定基準

- **完全一致**: 同じテキストが既にある → スキップ
- **意味的類似**: 同じ内容を別の表現で書いている → スキップ
- **新しい情報**: 既存内容に追加情報がある → 追記

**例**:
- 既存: 「skills パスに /SKILL.md を含めない」
- 新規: 「スキルパスはディレクトリのみ指定する」
- 判定: **意味的に同じ → スキップ**

- 既存: 「description は1行で書く」
- 新規: 「description は1行で書く。複数行パイプ `|` は非対応」
- 判定: **追加情報あり → 追記**

---

## 出力フォーマット

### ディレクトリ構造

学習内容は以下のディレクトリ構造で保存されます：

```
.claude/rules/
├── project-specs/           # プロジェクト仕様
│   └── config-module-usage.md
├── error-responses/         # エラー対応
│   └── skills-path-format.md
├── coding-rules/            # コーディング規約
│   └── test-file-naming.md
└── tips/                    # Tips
    └── plugin-local-testing.md
```

**カテゴリマッピング**:
- プロジェクト仕様 → `project-specs/`
- エラー対応 → `error-responses/`
- コーディング規約 → `coding-rules/`
- Tips → `tips/`

### 個別ルールファイルの形式

各ルールは独立したMarkdownファイルとして保存されます：

**汎用ルールの例**（全ファイルに適用）:
```markdown
---
date: 2026-01-24
tags:
  - claude-code
  - skills
---

# Skills パスに /SKILL.md を含めない

## 概要

Claude Code の skills パスは `/SKILL.md` を含めると「Unknown skill」エラーになる。

## 詳細

- **正しい形式**: `"./skills/changelog"` （ディレクトリのみ）
- **誤った形式**: `"./skills/changelog/SKILL.md"` （ファイル名を含む）

## 参考

- 公式 anthropics/skills リポジトリの形式に準拠
- [Issue #49](https://github.com/sk8metalme/ai-agent-setup/issues/49)
```

**パス固有ルールの例**（特定のファイルにのみ適用）:
```markdown
---
paths: src/api/**/*.ts
date: 2026-01-24
tags:
  - api
  - validation
---

# API エンドポイントには入力バリデーションを実装する

## 概要

すべての API エンドポイントには入力バリデーションを実装すること。

## 詳細

- リクエストパラメータは必ず検証
- バリデーションエラーは適切なステータスコードで返却（400 Bad Request）
- 型安全性を保つため、Zodなどのスキーマバリデータを使用

## 参考

- プロジェクトのバリデーションガイドライン
```

**ファイル名**: slug形式（kebab-case）で、内容を端的に表現
- 例: `skills-path-format.md`, `config-module-usage.md`

**フロントマター**:
- `paths`: 適用対象のファイルパターン（オプション、省略時は全ファイルに適用）
- `date`: 作成日（YYYY-MM-DD）
- `tags`: 関連タグ（オプション）

**paths の指定例**:
| パターン | マッチ |
|---------|-------|
| `**/*.ts` | すべての TypeScript ファイル |
| `src/api/**/*` | src/api/ 以下のすべてのファイル |
| `**/*.{ts,tsx}` | TypeScript と TSX ファイル |
| `tests/**/*.test.ts` | テストファイル |

`paths` を省略すると、すべてのファイルに適用される汎用ルールになります。

---

## 実行フロー

### 1. カテゴリディレクトリの作成

```bash
mkdir -p .claude/rules/project-specs
mkdir -p .claude/rules/error-responses
mkdir -p .claude/rules/coding-rules
mkdir -p .claude/rules/tips
```

### 2. 会話履歴の分析

- 現在の会話履歴全体を分析
- 4カテゴリに分類
- 各学習内容にタイトルとslugを生成

### 3. 重複チェック（複数ファイル横断）

既存の `.claude/rules/` 以下のすべてのMarkdownファイルを確認：
- 同じカテゴリ内の既存ファイルを読み込み
- セマンティックな重複をチェック
- 重複する場合はスキップ

**重複判定基準**:
- 完全一致: 同じタイトル・内容 → スキップ
- 意味的類似: 同じ内容を別表現 → スキップ
- 新しい情報: 既存に追加情報 → 新規ファイル作成

### 4. 個別ファイルの保存

各学習内容を個別のMarkdownファイルとして保存：
- ファイル名: `{slug}.md`（例: `skills-path-format.md`）
- 保存先: `.claude/rules/{category}/`
- フロントマター付きMarkdown形式

---

## 実行例

### 手動実行
```
/guardrail-builder

> 会話履歴を分析しました。
>
> .claude/rules/ に新しいルールを保存しました：
>
> error-responses/
>   - skills-path-format.md
>   - marketplace-version-sync.md
>
> tips/
>   - plugin-local-testing.md
>
> 総計: 3件の新しい学習内容を記録しました。
> これらのファイルは Claude Code により自動的にプロジェクトメモリとして読み込まれます。
```

---

## 除外基準

以下の内容は追記**しない**：

- 一時的な判断や個別ケースの対応
- 既に guardrail.md に記載されている内容（重複）
- 個人の好みや一時的な試行
- 不明確または曖昧な指示
- プロジェクト外の一般的な知識

---

## 出力メッセージ

### 成功時
```
.claude/rules/ に新しいルールを保存しました：

project-specs/
  - config-module-usage.md

error-responses/
  - skills-path-format.md
  - marketplace-version-sync.md

coding-rules/
  - test-file-naming.md

総計: 4件の新しい学習内容を記録しました。
これらのファイルは Claude Code により自動的にプロジェクトメモリとして読み込まれます。
```

### 重複のみの場合
```
会話履歴を分析しましたが、新しい学習内容は見つかりませんでした。
既存の .claude/rules/ に同様の内容が記録されています。
```

### エラー時
```
エラー: .claude/rules/ へのファイル保存に失敗しました。
詳細: [エラーメッセージ]
```

---

## 注意事項

1. **.claude/rules/ は Git 管理対象**
   - すべてのルールファイルをリポジトリにコミット
   - チームで知見を共有
   - .gitignore に追加しない

2. **重複チェックは複数ファイル横断**
   - 同じカテゴリ内の既存ファイルをすべて確認
   - セマンティックな類似性を AI で判断
   - 重複する場合は新規ファイルを作成しない

3. **1ルール1ファイル原則**
   - 1つの学習内容は1つの独立したMarkdownファイル
   - ファイル名は内容を端的に表現（slug形式）
   - カテゴリは1つのみ選択

4. **既存 guardrail.md との共存**
   - v1.x で作成した guardrail.md は引き続き読み込まれる
   - 新規ルールは個別ファイルとして保存
   - マイグレーションは不要

---

## トラブルシューティング

### Q: カテゴリディレクトリが作成されない

**A**: 以下を確認：
- プロジェクトルートで実行しているか
- ディレクトリ作成権限があるか
- Bash ツールが許可されているか

### Q: 同じ内容が何度も個別ファイルとして作成される

**A**: 重複チェックのロジックを確認：
- 既存の .claude/rules/ 内のファイルを正しく読み込んでいるか
- セマンティック類似性の判定が機能しているか
- ファイル名の重複チェックも実施

### Q: 個別ファイルが自動読み込みされない

**A**: ファイル配置を確認：
- `.claude/rules/{category}/` に配置されているか
- ファイル拡張子は `.md` か
- `/memory` コマンドで読み込み状況を確認

### Q: v1.x の guardrail.md はどうなる？

**A**: 既存ファイルは引き続き読み込まれます：
- `.claude/rules/guardrail.md` は自動読み込み継続
- 新規ルールは個別ファイルとして保存
- マイグレーション不要

---

このスキルは suggest-claude-md コマンドの後継として設計されています。
v2.0.0 で「1ルール1Markdown」構造に移行しました。
