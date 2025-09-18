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

### 多言語対応セキュリティ設定

設定ファイルには、PHP、Java、Python、Perl、Node.jsを扱う際の危険なコマンドも含まれています：

#### パッケージ管理の危険操作
- **グローバルインストール**: `npm install -g`, `pip install --user`, `composer global require`
- **システム破壊**: `pip install --break-system-packages`, `cpanm --sudo`
- **パブリッシュ操作**: `mvn deploy`, `gradle publish`, `npm publish`

#### 任意コード実行の防止
- **インライン実行**: `php -r`, `python -c`, `perl -e`, `node -e`
- **一時ファイル実行**: `/tmp/`や`/var/tmp/`からのJAR実行
- **パイプ実行**: `curl|bash`, `wget|sh`等の危険なパイプライン

#### システムレベル操作
- **プロセス管理**: `kill -9`, `killall`, `systemctl`
- **ディスク操作**: `dd`, `mkfs`, `fdisk`
- **マウント操作**: `mount`, `umount`

## 🔧 設定項目詳細

### AI設定
- `temperature`: 0.0-1.0（0.5推奨）
- `model`: 使用するClaudeモデル指定

### 環境変数
- `MAX_THINKING_TOKENS`: 思考トークン数上限
- `ANTHROPIC_MODEL`: 使用モデル指定

### 許可コマンド（allowed）

#### **ファイル・ディレクトリ操作**
- **参照系**: `ls`, `cat`, `less`, `head`, `tail`, `tree`
- **検索系**: `grep`, `find`, `locate`, `which`, `whereis`
- **情報系**: `file`, `stat`, `diff`, `cmp`, `wc`, `du`

#### **システム情報**
- **基本情報**: `pwd`, `whoami`, `date`, `uptime`, `env`
- **プロセス**: `ps`, `top`, `htop`, `lsof`
- **ネットワーク**: `ping`, `nslookup`, `dig`, `netstat`, `ss`
- **ディスク**: `df`, `du`, `free`

#### **Git操作**
- **参照系**: `git status`, `git diff`, `git log`, `git show`, `git blame`
- **ブランチ**: `git branch`, `git checkout`, `git remote`, `git tag`
- **履歴**: `git stash list`, `git stash show`
- **同期**: `git pull`, `git push`, `git commit`, `git add`

#### **言語・パッケージ管理**
- **バージョン確認**: 各言語の`--version`コマンド
- **パッケージ情報**: `npm list`, `pip list`, `composer show`
- **セキュリティ**: `npm audit`, `yarn audit`, `pip check`
- **開発**: `npm run`, `npm test`, `yarn`コマンド

#### **テキスト処理**
- **編集系**: `sort`, `uniq`, `cut`, `awk`, `sed`, `tr`
- **出力系**: `echo`, `printf`
- **ハッシュ**: `md5sum`, `sha256sum`

#### **安全なネットワーク**
- **ヘッダー確認**: `curl -I`, `curl --head`
- **接続テスト**: `wget --spider`, `ping`

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
