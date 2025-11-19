---
name: suggest-claude-md
description: 会話履歴を分析してCLAUDE.mdの更新提案を自動生成するコマンド
model: opusplan
---

## 概要

このコマンドは、Claude会話履歴を分析して`CLAUDE.md`ファイルの更新提案を自動生成します。
SessionEndフックやPreCompactフックと連携して、プロジェクトコンテキストの自動更新を支援します。

## 主な機能

### 1. 会話履歴分析
- Claude会話のトランスクリプトを解析
- 新しいプロジェクト情報、技術的決定、重要な議論を抽出
- 既存のCLAUDE.mdとの差分を識別

### 2. 更新提案生成
- 構造化された更新提案を生成
- セクション別の変更内容を整理
- 重要度に応じた優先順位付け

### 3. 自動化サポート
- フックスクリプトとの連携
- 無限ループ防止機構
- 新しいターミナルウィンドウでの実行

## 使用方法

### 手動実行
```bash
# 直接コマンド実行
claude suggest-claude-md

# 特定の会話履歴を指定
claude suggest-claude-md --transcript-path /path/to/transcript.json
```

### 自動実行（フック連携）
`.claude/settings.json`で以下のフック設定が必要：

```json
{
  "hooks": {
    "SessionEnd": ".claude/bin/suggest-claude-md-hook-global.sh",
    "PreCompact": ".claude/bin/suggest-claude-md-hook-global.sh"
  }
}
```

## 分析対象

### プロジェクト情報
- 新しい技術スタック
- アーキテクチャの変更
- 依存関係の追加・変更
- 設定ファイルの更新

### 開発プロセス
- ワークフローの変更
- 新しいツールの導入
- テスト戦略の更新
- デプロイメント手順の変更

### 重要な決定事項
- 技術的な選択理由
- 制約事項や注意点
- パフォーマンス考慮事項
- セキュリティ要件

## 出力形式

### 更新提案構造
```markdown
# CLAUDE.md更新提案

## 新規追加セクション
- [セクション名]: [追加理由]
- [内容概要]

## 既存セクション更新
- [セクション名]: [変更理由]
- [変更内容]

## 削除推奨セクション
- [セクション名]: [削除理由]

## 優先度
- 高: [即座に更新が必要な項目]
- 中: [次回更新時に検討する項目]
- 低: [将来的に検討する項目]
```

## 設定オプション

### 分析の深度
- `--depth shallow`: 基本的な変更のみ抽出
- `--depth medium`: 中程度の詳細分析（デフォルト）
- `--depth deep`: 詳細な分析と提案

### フィルタリング
- `--include-technical`: 技術的な詳細を含める
- `--exclude-temporary`: 一時的な変更を除外
- `--focus-architecture`: アーキテクチャ変更に焦点

## 注意事項

### 無限ループ防止
- 環境変数`SUGGEST_CLAUDE_MD_RUNNING`で実行状態を管理
- フック内でのClaude実行時の再帰呼び出しを防止

### プライバシー考慮
- 機密情報の自動除外
- 個人情報のマスキング
- 外部サービス情報の保護

### 品質保証
- 提案内容の妥当性チェック
- 既存情報との整合性確認
- 重複情報の除去

## トラブルシューティング

### よくある問題
1. **フックが動作しない**
   - `.claude/settings.json`の設定確認
   - スクリプトの実行権限確認

2. **無限ループが発生**
   - 環境変数の設定確認
   - フックスクリプトのバージョン確認

3. **分析結果が不正確**
   - 会話履歴の形式確認
   - 分析対象の範囲調整

### ログ確認
```bash
# フック実行ログ
tail -f ~/.claude/logs/suggest-claude-md.log

# エラーログ
tail -f ~/.claude/logs/error.log
```

## 関連ファイル

- `.claude/bin/suggest-claude-md-hook-global.sh`: フックスクリプト
- `.claude/settings.json`: フック設定
- `project-config/claude-import/CLAUDE.md`: 更新対象ファイル
- `install-project.sh`: 自動配布スクリプト
