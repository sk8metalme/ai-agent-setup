# Claude Project Configuration

このファイルは、プロジェクト固有のClaude設定です。
プロジェクトルートの`.claude/`ディレクトリに配置して使用します。

## 基本設定

@import base/CLAUDE-base.md

## プロジェクト固有設定

### プロジェクト情報
- **プロジェクト名**: このプロジェクトの名前
- **技術スタック**: 使用している言語・フレームワーク
- **開発フェーズ**: 開発段階（設計/開発/テスト/運用）

### 開発ルール
- プロジェクト固有のコーディング規約
- アーキテクチャパターン
- 命名規則
- ディレクトリ構造

### 言語設定（必要に応じてコメントアウト）

<!-- Java + Spring Boot -->
<!-- @import languages/java-spring/CLAUDE-java-spring.md -->

<!-- PHP -->
<!-- @import languages/php/CLAUDE-php.md -->

<!-- Perl -->
<!-- @import languages/perl/CLAUDE-perl.md -->

<!-- Python -->
<!-- @import languages/python/CLAUDE-python.md -->

## セキュリティポリシー

@import security/CLAUDE-security-policy.md

## チーム標準

@import team/CLAUDE-team-standards.md

## jujutsuのルールインポート

@import jujutsu/jujutsu-rule.md

## プロジェクト固有の指示

### 開発方針
- このプロジェクトで重視する品質基準
- 特別な制約や要件
- 優先すべき非機能要件

### 禁止事項
- プロジェクト固有の禁止事項
- 使用してはいけないライブラリ・パターン
- セキュリティ上の注意点

### 推奨事項
- 推奨するライブラリ・ツール
- ベストプラクティス
- 効率化のためのヒント

---

**注意**: このファイルはプロジェクト固有の設定です。
グローバル設定は `~/.claude/CLAUDE.md` を使用してください。
