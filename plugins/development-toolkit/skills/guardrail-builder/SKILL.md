---
name: guardrail-builder
description: "Automatically extracts learnings from conversation history and appends them to CLAUDE-guardrail.md. Categorizes content into Project Specs, Error Response, Coding Rules, and Tips to prevent repeated mistakes."
allowed-tools: Read, Write, Edit, Grep, Glob
---

# guardrail-builder スキル

**あなたの役割**: 会話履歴を分析し、学習内容を自動的に `CLAUDE-guardrail.md` に追記すること。

## 目的

プロジェクト固有のルール、エラー対応、コーディング規約、Tipsを自動記録し、同じ間違いを繰り返さないようにする。

---

## 実行タイミング

1. **手動実行**: `/guardrail-builder` コマンド
2. **自動実行**: SessionEnd フック（Claude Code 終了時）

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

---

## 重複チェック

**重要**: 既存の CLAUDE-guardrail.md の内容と**セマンティック（意味的）な重複**をチェックし、類似内容は追記しない。

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

### CLAUDE-guardrail.md の構造

```markdown
# Guardrail - 学習済みルール

このファイルは、会話履歴から自動的に学習した内容を蓄積します。

## プロジェクト仕様
<!-- リポジトリ独自の仕様、開発スタイル、設計方針 -->

## エラー対応
<!-- 誤った作業、やり直した作業、ハマったポイント -->

## コーディング規約
<!-- 指摘されたコーディングルール、スタイルガイド -->

## Tips
<!-- 調査して得られた知見、覚えておくべき情報 -->

---

最終更新: YYYY-MM-DD
このファイルは `/guardrail-builder` スキルにより自動更新されます。
```

### 追記形式

各カテゴリ内に、以下の形式で箇条書きで追記：

```markdown
## カテゴリ名

- **[日付]** 学習内容（簡潔に1-2行）
  - 詳細や理由（必要に応じて）
  - 参考: [Issue #XXX](URL) など
```

**例**:
```markdown
## エラー対応

- **2026-01-13** Claude Code の skills パスは `/SKILL.md` を含めると「Unknown skill」エラーになる
  - 正しい形式: `"./skills/changelog"` （ディレクトリのみ）
  - 誤った形式: `"./skills/changelog/SKILL.md"` （ファイル名を含む）
  - 参考: 公式 anthropics/skills リポジトリの形式に準拠
```

---

## 実行フロー

### 1. CLAUDE-guardrail.md の存在確認

```bash
if [ -f "./CLAUDE-guardrail.md" ]; then
  # 既存ファイル → 追記モード
else
  # 新規作成 → テンプレート生成
fi
```

### 2. 会話履歴の分析

- 現在の会話履歴全体を分析
- 4カテゴリに分類
- 重複チェック（既存 CLAUDE-guardrail.md との比較）

### 3. CLAUDE-guardrail.md への追記

- 新しい学習内容を該当カテゴリに追記
- 最終更新日を更新

### 4. CLAUDE.md への自動リンク（初回のみ）

CLAUDE.md に `@CLAUDE-guardrail.md` が含まれていない場合、以下を追記：

```markdown
## 学習済みルール

@CLAUDE-guardrail.md
```

---

## 実行例

### 手動実行
```
/guardrail-builder

> 会話履歴を分析しました。
>
> CLAUDE-guardrail.md を更新しました：
> - エラー対応: 2件追加
> - Tips: 1件追加
>
> CLAUDE.md に @CLAUDE-guardrail.md を追記しました。
```

### 自動実行（SessionEnd フック）
```
# Claude Code 終了時に自動実行
# 新しいターミナルウィンドウで処理
# macOS 通知で結果を表示

通知: "guardrail.md を更新しました（エラー対応: 2件、Tips: 1件）"
```

---

## 除外基準

以下の内容は追記**しない**：

- 一時的な判断や個別ケースの対応
- 既に CLAUDE-guardrail.md に記載されている内容（重複）
- 個人の好みや一時的な試行
- 不明確または曖昧な指示
- プロジェクト外の一般的な知識

---

## 出力メッセージ

### 成功時
```
CLAUDE-guardrail.md を更新しました：
- プロジェクト仕様: X件追加
- エラー対応: Y件追加
- コーディング規約: Z件追加
- Tips: W件追加

総計: N件の新しい学習内容を記録しました。
```

### 重複のみの場合
```
会話履歴を分析しましたが、新しい学習内容は見つかりませんでした。
既存の CLAUDE-guardrail.md に同様の内容が記録されています。
```

### エラー時
```
エラー: CLAUDE-guardrail.md の更新に失敗しました。
詳細: [エラーメッセージ]
```

---

## 注意事項

1. **CLAUDE-guardrail.md は Git 管理対象**
   - リポジトリにコミットし、チームで共有
   - .gitignore に追加しない

2. **重複チェックは必須**
   - 同じ内容が何度も追記されないようにする
   - セマンティックな類似性を AI で判断

3. **カテゴリ分類は厳密に**
   - 1つの学習内容は1つのカテゴリのみに追記
   - 複数カテゴリにまたがる場合は、最も適切なカテゴリを選択

4. **簡潔に記述**
   - 1つの学習内容は1-2行で簡潔に
   - 詳細は箇条書きで追記

---

## トラブルシューティング

### Q: CLAUDE.md に @CLAUDE-guardrail.md が追記されない

**A**: 以下を確認：
- CLAUDE.md が存在するか
- CLAUDE.md が書き込み可能か
- 既に @CLAUDE-guardrail.md が含まれていないか

### Q: 同じ内容が何度も追記される

**A**: 重複チェックのロジックを確認：
- 既存ファイルを正しく読み込んでいるか
- セマンティック類似性の判定が機能しているか

### Q: SessionEnd フックが動作しない

**A**: フック設定を確認：
- settings.json に正しく登録されているか
- スクリプトに実行権限があるか
- ログファイル（.claude/logs/guardrail-builder-*.log）を確認

---

このスキルは suggest-claude-md コマンドの後継として設計されています。
