# Claude @import 構文を活用した設定管理ガイド

Claudeの`@path/to/file`インポート構文を使用することで、モジュール化された柔軟な設定管理が可能になります。

## 📋 @import構文とは

Claudeは設定ファイル内で`@path/to/file.md`という構文を使用して、他のマークダウンファイルをインポートできます。これにより：

- **設定の再利用**: 共通設定を一箇所で管理
- **モジュール化**: 機能別に設定を分割
- **継承と拡張**: 基本設定を継承して拡張
- **保守性向上**: 変更が必要な箇所を限定

## 🏗️ 推奨ディレクトリ構造

```
~/.claude/
├── CLAUDE.md                 # メインエントリーポイント
├── base/                     # 基本設定
│   ├── CLAUDE-base.md       # 全プロジェクト共通
│   └── CLAUDE-company.md    # 会社固有設定
├── team/                     # チーム設定
│   ├── CLAUDE-team-standards.md
│   └── CLAUDE-team-tools.md
├── security/                 # セキュリティ設定
│   └── CLAUDE-security-policy.md
├── languages/                # 言語別設定
│   ├── java-spring/
│   │   └── CLAUDE-java-spring.md
│   ├── php/
│   │   └── CLAUDE-php.md
│   └── perl/
│       └── CLAUDE-perl.md
└── projects/                 # プロジェクト別設定
    ├── project-a/
    └── project-b/
```

## 🔧 基本的な使用方法

### 1. メインファイル（~/.claude/CLAUDE.md）

```markdown
# グローバル設定

## 基本設定をインポート
@base/CLAUDE-base.md

## チーム標準をインポート
@team/CLAUDE-team-standards.md

## セキュリティポリシーをインポート
@security/CLAUDE-security-policy.md

## プロジェクト固有の追加設定
ここにプロジェクト固有の設定を記載
```

### 2. 言語固有設定の条件付きインポート

```markdown
# プロジェクト設定

## 共通設定
@base/CLAUDE-base.md

## 言語別設定（使用する言語のコメントを外す）

<!-- Java開発の場合 -->
<!-- @languages/java-spring/CLAUDE-java-spring.md -->

<!-- PHP開発の場合 -->
<!-- @languages/php/CLAUDE-php.md -->

<!-- 複数言語を使用する場合は複数インポート可能 -->
```

### 3. 継承チェーンの例

```markdown
# languages/java-spring/CLAUDE-java-spring.md

## 基本設定を継承
@../../base/CLAUDE-base.md

## セキュリティポリシーを継承
@../../security/CLAUDE-security-policy.md

## Java固有の設定
ここにJava特有の設定を追加
```

## 🎯 実践的な使用パターン

### パターン1: 組織全体の統一設定

```
~/.claude/
├── CLAUDE.md → @company/CLAUDE-company-wide.md
├── company/
│   ├── CLAUDE-company-wide.md
│   ├── CLAUDE-coding-standards.md
│   └── CLAUDE-security-requirements.md
```

### パターン2: プロジェクトタイプ別テンプレート

```markdown
# Webアプリケーションテンプレート
@base/CLAUDE-base.md
@templates/web-app/CLAUDE-frontend.md
@templates/web-app/CLAUDE-backend.md
@templates/web-app/CLAUDE-database.md
```

### パターン3: 環境別設定

```markdown
# 開発環境設定
@base/CLAUDE-base.md
@environments/CLAUDE-development.md

# デバッグモードの有効化
デバッグ情報を詳細に出力してください
```

## 📝 ベストプラクティス

### 1. 相対パスの使用

```markdown
# 良い例（相対パス）
@../base/CLAUDE-base.md
@./modules/CLAUDE-auth.md

# 避けるべき例（絶対パス）
@/home/user/.claude/base/CLAUDE-base.md
```

### 2. 循環参照の回避

```markdown
# file1.md
@file2.md  # file2.mdがfile1.mdを参照していると循環参照

# 解決策: 共通部分を別ファイルに抽出
@common/shared-config.md
```

### 3. 設定の階層化

```
基本設定（全体共通）
  ↓
チーム設定（チーム共通）
  ↓
言語設定（言語固有）
  ↓
プロジェクト設定（個別）
```

### 4. バージョン管理との連携

```bash
# 設定ファイルをGitで管理
cd ~/.claude
git init
git add .
git commit -m "Initial Claude configuration"

# チーム間で共有
git remote add origin https://github.com/team/claude-configs
git push -u origin main
```

## 🚀 高度な活用例

### 動的設定の切り替え

```bash
#!/bin/bash
# プロジェクトタイプに応じて設定を切り替え

project_type=$1

cat > ~/.claude/CLAUDE.md << EOF
# 動的生成された設定

@base/CLAUDE-base.md
@team/CLAUDE-team-standards.md

# プロジェクトタイプ: $project_type
$(case $project_type in
  "java") echo "@languages/java-spring/CLAUDE-java-spring.md";;
  "php") echo "@languages/php/CLAUDE-php.md";;
  "perl") echo "@languages/perl/CLAUDE-perl.md";;
esac)
EOF
```

### プロジェクトローカル設定との組み合わせ

```markdown
# プロジェクトルートの CLAUDE.md

# グローバル設定を継承
@~/.claude/CLAUDE.md

# このプロジェクト専用の追加設定
## 特別な要件
- GraphQL APIを使用
- マイクロサービスアーキテクチャ
```

## 🛠️ トラブルシューティング

### インポートが機能しない場合

1. **パスの確認**
   - 相対パスが正しいか
   - ファイルが存在するか
   - 拡張子（.md）を含めているか

2. **構文の確認**
   - `@`で始まっているか
   - 前後に余計なスペースがないか

3. **Claudeの再起動**
   - 設定変更後はプロジェクトを再度開く

### パフォーマンスの考慮

- 深いネストは避ける（3-4階層まで）
- 大きなファイルは分割する
- 不要なインポートは削除する

## 📊 メリットとデメリット

### メリット
- ✅ DRY原則の実現
- ✅ 設定の一元管理
- ✅ チーム間での標準化
- ✅ 柔軟な拡張性

### デメリット
- ⚠️ 初期設定がやや複雑
- ⚠️ ファイル数が増える
- ⚠️ デバッグが難しくなる場合がある

## まとめ

`@import`構文を活用することで、Claudeの設定を効率的に管理できます。小規模プロジェクトでは単一ファイルで十分ですが、チーム開発や複数プロジェクトを扱う場合は、この機能を活用することで大幅な効率化が可能です。
