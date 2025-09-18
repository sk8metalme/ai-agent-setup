# Claude Project Settings Configuration

このディレクトリには、プロジェクト固有のClaude Desktop/Web用設定ファイルが含まれています。

## 📁 ファイル構成

```
claude-settings/
├── settings.json          # プロジェクト用Claude設定ファイル
└── README.md             # このファイル
```

## 🎯 プロジェクト設定の特徴

### グローバル設定との違い
- **保護ブランチ**: `develop`ブランチも追加で保護
- **チーム設定**: プロジェクト固有のレビュアー・コードオーナー
- **コードオーナー**: プロジェクト構造に最適化されたディレクトリ別担当者

### プロジェクト固有設定
```json
{
  "git": {
    "protectedBranches": ["main", "master", "production", "develop"]
  },
  "team": {
    "reviewers": ["project-lead", "senior-dev"],
    "codeOwners": {
      "src/": ["development-team"],
      "tests/": ["qa-team"],
      "docs/": ["documentation-team"],
      "config/": ["devops-team"]
    }
  }
}
```

## 🚀 インストール方法

### 方法1: インストールスクリプト使用（推奨）
```bash
# プロジェクトルートで実行
bash <(curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-project.sh)
```

### 方法2: 手動インストール
```bash
# プロジェクトルートで実行
mkdir -p .claude

# 設定ファイルをダウンロード
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/project-config/claude-settings/settings.json -o .claude/settings.json
```

### 方法3: 既存設定のバックアップ付きインストール
```bash
# 既存設定をバックアップ
if [ -f .claude/settings.json ]; then
    cp .claude/settings.json .claude/settings.json.backup.$(date +%Y%m%d_%H%M%S)
fi

# 新しい設定をインストール
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/project-config/claude-settings/settings.json -o .claude/settings.json
```

## ⚙️ プロジェクト固有カスタマイズ

### チーム設定の調整
```json
{
  "team": {
    "reviewers": ["あなたのプロジェクトリーダー", "シニア開発者"],
    "codeOwners": {
      "frontend/": ["フロントエンドチーム"],
      "backend/": ["バックエンドチーム"],
      "mobile/": ["モバイルチーム"],
      "infrastructure/": ["DevOpsチーム"]
    }
  }
}
```

### 保護ブランチの調整
```json
{
  "git": {
    "protectedBranches": ["main", "staging", "production", "release/*"]
  }
}
```

### プロジェクト固有権限
```json
{
  "permissions": {
    "allowed": [
      // プロジェクト固有のコマンドを追加
      "Bash(make:*)",
      "Bash(docker:*)",
      "Bash(kubectl:*)",
      "Bash(terraform:*)"
    ]
  }
}
```

## 🔧 設定の優先順位

Claude設定の読み込み優先順位：
1. **プロジェクト設定**: `.claude/settings.json`（最優先）
2. **グローバル設定**: `~/.claude/settings.json`
3. **デフォルト設定**: Claude内蔵設定

## 📋 プロジェクト設定のメリット

### 🎯 **プロジェクト最適化**
- プロジェクト固有のワークフローに最適化
- チーム構成に合わせたレビュー体制
- プロジェクトのブランチ戦略に対応

### 🔒 **セキュリティ強化**
- プロジェクト固有の保護ブランチ設定
- ディレクトリ別コードオーナー管理
- プロジェクト要件に応じた権限制御

### 👥 **チーム協業**
- プロジェクトメンバー全員で統一された設定
- 新メンバーの即座な環境構築
- 設定の一元管理とバージョン管理

## 🤝 グローバル設定との併用

### 推奨構成
```
~/.claude/
├── CLAUDE.md              # グローバル設定（基本ルール）
├── settings.json          # グローバル設定（基本権限）
└── ...

my-project/
├── .claude/
│   ├── CLAUDE.md          # プロジェクト設定（固有ルール）
│   └── settings.json      # プロジェクト設定（固有権限）
└── ...
```

### 設定の使い分け
- **グローバル**: 全プロジェクト共通の基本ルール・権限
- **プロジェクト**: 特定プロジェクトの固有ルール・権限

## 📝 注意事項

1. **設定の競合**: プロジェクト設定がグローバル設定を上書きします
2. **チーム共有**: `.claude/`ディレクトリはGitで管理してチーム共有してください
3. **機密情報**: 設定ファイルに機密情報を含めないでください
4. **定期更新**: プロジェクトの進行に合わせて設定を更新してください

## 🎊 これで、プロジェクト固有の最適化されたClaude環境が構築できます！
