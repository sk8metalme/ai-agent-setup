---
name: claude-md-creator
description: >
  Create, improve, and evaluate high-quality CLAUDE.md files for projects.
  Provides interactive creation workflow, quality validation, and best practices guidance.
  Use when: (1) Starting a new project and need to create CLAUDE.md,
  (2) Improving existing CLAUDE.md, (3) Evaluating CLAUDE.md quality,
  (4) User mentions 'CLAUDE.md', 'project setup', or 'create CLAUDE.md'
---

# Claude MD Creator

## Overview

このスキルは、プロジェクトのための品質の高いCLAUDE.mdファイルを作成・改善・評価するための総合的なサポートを提供します。対話的な作成ガイド、コードベース分析、品質チェック、ベストプラクティスに基づいたテンプレートを活用して、効果的なCLAUDE.mdを生成します。

## Core Capabilities

1. **Interactive Creation (対話的作成)** - ステップバイステップで質問しながらCLAUDE.mdを作成
2. **Codebase Analysis (コードベース分析)** - 既存のプロジェクト構造を分析し、適切なCLAUDE.mdを提案
3. **Quality Validation (品質検証)** - 構造の妥当性、ベストプラクティス準拠、プロジェクト適合性をチェック
4. **Template Library (テンプレートライブラリ)** - 8種類の用途別テンプレートを提供

## Usage Scenarios

- **新規プロジェクト開始時**: ゼロからCLAUDE.mdを作成
- **既存CLAUDE.md改善**: 既存のCLAUDE.mdを分析し、改善点を提案
- **品質評価**: CLAUDE.mdの品質を評価し、問題点を指摘
- **チーム標準作成**: 複数プロジェクトで使える標準テンプレートを作成

## Workflow

### 1. Interactive Creation (対話的作成)

段階的な対話を通じてCLAUDE.mdを作成します。

**作成順序**:
1. **プロジェクト概要** - プロジェクトタイプ、使用技術、品質要件
2. **開発・品質管理** - TDD、E2Eテスト、テスト戦略、コード品質担保施策
3. **CI/CD・ツール** - CI/CD設定、リント、フォーマッター、ビルドツール
4. **開発フロー** - バージョン管理、ブランチ戦略、プロジェクト構造

**手順**:
1. ユーザーに各セクションについて質問
2. 回答を元にセクションを生成
3. プレビューを表示して確認
4. ユーザー承認後に次のセクションへ進む
5. 全セクション完了後、最終プレビュー
6. 確認後にCLAUDE.mdとして保存

### 2. Codebase Analysis & Improvement (分析・改善)

既存のコードベースを分析し、適切なCLAUDE.mdを自動生成または既存のCLAUDE.mdを改善します。

**分析対象**:
- コードベース構造（ディレクトリ構成、ファイル構成）
- 使用技術スタック（言語、フレームワーク、ライブラリ）
- 既存の設定ファイル（.gitignore, .eslintrc, tsconfig.json, pytest.ini など）
- テスト構成（テストファイルの場所、テストフレームワーク）

**手順**:
1. プロジェクトディレクトリ構造をスキャン
2. package.json / pyproject.toml / pom.xml などから技術スタックを検出
3. 設定ファイルからツール設定を抽出
4. テストディレクトリとテストフレームワークを特定
5. 分析結果に基づいてCLAUDE.mdを生成
6. プレビューを表示して確認
7. ユーザー承認後に保存

### 3. Quality Check (品質検証)

既存のCLAUDE.mdの品質を検証し、改善提案を行います。

**チェック項目**:
- **構造の妥当性**: Markdown構文、必須セクションの有無、ファイル構成
- **ベストプラクティス準拠**: 推奨パターン、命名規則、構成標準
- **プロジェクト適合性**: 実際のコードベースとの整合性

**手順**:
1. `check_claude_md.py` スクリプトを実行
2. 検証結果レポートを表示
3. 問題点を優先度順にリスト化
4. 各問題に対する改善提案を提示
5. ユーザーが選択した項目を修正

詳細は `scripts/check_claude_md.py` を参照。

## Resources

### Scripts

**check_claude_md.py** - CLAUDE.mdの品質検証スクリプト

統合された検証ツールで、以下の機能を提供:
- Markdown構文チェック
- 必須セクションの検証
- 内容の充実度評価
- ベストプラクティス準拠チェック
- 詳細な改善提案レポート

使用例:
```bash
python scripts/check_claude_md.py /path/to/CLAUDE.md
```

### References

プロジェクトタイプに応じた詳細なガイダンス:

| ファイル | 説明 | 使用場面 |
|---------|------|---------|
| `best-practices.md` | CLAUDE.md作成のベストプラクティス集 | 原則・アンチパターンを確認したい時 |
| `structure-guide.md` | CLAUDE.mdの構造設計ガイド | セクション構成を決めたい時 |
| `examples.md` | 良いCLAUDE.mdの実例 | 完成イメージを確認したい時 |
| `common-patterns.md` | よく使われる設定パターン集 | 特定セクションのスニペットが必要な時 |
| `development-workflow.md` | TDD、E2Eテストを含む開発フロー | 開発フローセクションの詳細 |
| `quality-assurance.md` | テスト方法、リント、品質担保施策 | テスト・品質セクションの詳細 |
| `ci-cd-guide.md` | CI/CD設定のベストプラクティス | CI/CDセクションの詳細 |
| `project-structure.md` | プロジェクト構造パターン | ディレクトリ構成の参考 |
| `version-control.md` | Git/Jujutsuバージョン管理戦略 | バージョン管理セクションの詳細 |

**推奨参照順序**:
1. `examples.md` - 完成イメージを把握
2. `best-practices.md` - 原則を理解
3. `structure-guide.md` - 構成を決定
4. 各詳細ガイド - 必要なセクションのみ参照

### Assets (Templates)

8種類の用途別テンプレート（`assets/templates/` に格納）:

| テンプレート | 用途 |
|-------------|------|
| `frontend.md` | フロントエンド専門（React, Vue, Angular など） |
| `backend-api.md` | バックエンドAPI（REST, GraphQL など） |
| `pub-sub.md` | Pub/Subシステム（メッセージング、イベント駆動） |
| `proxy.md` | プロキシサーバー（リバースプロキシ、API Gateway） |
| `batch.md` | バッチ処理（定期実行、データ処理） |
| `library.md` | ライブラリ/パッケージ（npm, PyPI, Maven など） |
| `cli-tool.md` | CLIツール（コマンドラインアプリケーション） |
| `other.md` | その他/汎用（上記に当てはまらないプロジェクト） |

## Output Format

生成されたCLAUDE.mdは以下の形式で出力されます:

1. **プレビュー表示** - 生成内容を確認
2. **ユーザー承認** - 内容を確認して承認
3. **ファイル保存** - プロジェクトルートに `CLAUDE.md` として保存

## Best Practices

- **具体性**: 抽象的な説明ではなく、具体的なコマンドやファイル名を記載
- **一貫性**: セクション構成や用語を統一
- **実用性**: 実際の開発フローに即した内容
- **更新性**: プロジェクトの変更に応じて定期的に更新

詳細は `references/best-practices.md` を参照してください。
