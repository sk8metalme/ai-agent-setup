# Claude Settings Configuration

このディレクトリには、Claude Desktop/Web用の推奨設定ファイルが含まれています。

## 📁 ファイル構成

```
claude-settings/
├── settings.json          # Claude設定ファイル
└── README.md             # このファイル
```

## 🎯 設定内容

### 基本設定
- **テーマ**: ダークモード
- **エディタ**: Markdown既定、行折り返し有効
- **AI温度**: 0.5（バランスの取れた創造性）

### 開発ツール
- **有効ツール**: bash, read, edit, write, glob, grep
- **自動保存**: 有効

### セキュリティ設定
- **権限管理**: 安全なコマンドのみ許可
- **危険コマンド**: rm -rf, sudo等を拒否
- **機密情報**: コミット前スキャン有効

### Git統合
- **コミットメッセージ**: テンプレート使用
- **保護ブランチ**: main, master, production
- **プルリクエスト**: 必須

### チーム設定
- **コードレビュー**: 必須
- **レビュアー**: tech-lead, senior-dev
- **コードオーナー**: ディレクトリ別担当者設定

## 🚀 インストール方法

### 方法1: インストールスクリプト使用（推奨）
```bash
# Claude設定も含めてインストール
bash <(curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh)
```

### 方法2: 手動インストール
```bash
# Claude設定ディレクトリを作成
mkdir -p ~/.claude

# 設定ファイルをダウンロード
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/global-config/claude-settings/settings.json -o ~/.claude/settings.json
```

### 方法3: 既存設定のバックアップ付きインストール
```bash
# 既存設定をバックアップ
if [ -f ~/.claude/settings.json ]; then
    cp ~/.claude/settings.json ~/.claude/settings.json.backup.$(date +%Y%m%d_%H%M%S)
fi

# 新しい設定をインストール
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/global-config/claude-settings/settings.json -o ~/.claude/settings.json
```

## ⚙️ カスタマイズ

### チーム設定の調整
```json
{
  "team": {
    "reviewers": ["your-tech-lead", "your-senior-dev"],
    "codeOwners": {
      "src/frontend/": ["frontend-team"],
      "src/backend/": ["backend-team"],
      "infrastructure/": ["devops-team"]
    }
  }
}
```

### 権限設定の調整
```json
{
  "permissions": {
    "allowed": [
      // プロジェクト固有のコマンドを追加
      "Bash(make:*)",
      "Bash(docker:*)",
      "Bash(kubectl:*)"
    ],
    "denied": [
      // 追加で拒否したいコマンドがあれば追加
      "Bash(docker rm:*)",
      "Bash(kubectl delete:*)"
    ]
  }
}
```

## 🔧 設定項目詳細

### AI設定
- `temperature`: 0.0-1.0（0.5推奨）
- `model`: 使用するClaudeモデル指定

### 環境変数
- `MAX_THINKING_TOKENS`: 思考トークン数上限
- `ANTHROPIC_MODEL`: 使用モデル指定

### セキュリティ
- `preventSecretCommits`: 機密情報コミット防止
- `scanDependencies`: 依存関係脆弱性スキャン
- `requireCodeReview`: コードレビュー必須化

## 📋 注意事項

1. **既存設定**: インストール前に既存設定をバックアップしてください
2. **チーム設定**: reviewersやcodeOwnersは実際のチーム構成に合わせて調整してください
3. **権限設定**: プロジェクトの要件に応じて許可/拒否コマンドを調整してください
4. **モデル設定**: 使用可能なモデルに応じてANTHROPIC_MODELを調整してください

## 🤝 貢献

設定の改善提案や新しい設定項目の追加は、GitHubのIssueまたはPull Requestでお知らせください。
