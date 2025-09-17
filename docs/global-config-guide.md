# グローバル設定ガイド

チーム全体で統一されたAI設定を使用するための詳細ガイドです。

## 🌍 グローバル設定とは

グローバル設定は、ユーザーのホームディレクトリに配置され、すべてのプロジェクトで自動的に適用される設定です。

### 設定ファイルの場所

```
~/
├── .claude/
│   └── CLAUDE.md         # Claudeの全プロジェクト共通設定（本リポジトリが提供）
└── (任意) .cursor/
    └── .cursorrules      # Cursorのグローバル設定（必要な場合のみ／手動管理）

※ Cursor向けテンプレートは `install-project.sh` で各プロジェクト配下の `.cursor/rules/*.mdc` に配置する方式を推奨しています。
```

### メリット

1. **一貫性**: すべてのプロジェクトで同じルールを適用
2. **効率性**: プロジェクトごとに設定する必要なし
3. **保守性**: 一箇所を更新すれば全体に反映
4. **チーム統一**: メンバー全員が同じ設定を使用

## 🚀 セットアップ方法

### 方法1: ワンコマンドインストール（推奨）

```bash
# すべての言語テンプレートを取得（非対話モードでもOK）
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh | bash

# Java + Spring Boot のみ取得したい場合（環境変数で制御）
LANGUAGE_CHOICE=1 curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh | bash

# 実行前に差分や影響を確認したい場合
bash <(curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh) --plan
LANGUAGE_CHOICE=1 curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh | bash -s -- --dry-run
```

### 方法2: 手動インストール

```bash
# ディレクトリ作成
mkdir -p ~/.claude

# ファイルをダウンロード
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/global-config/claude-import/CLAUDE.md \
  -o ~/.claude/CLAUDE.md

# Cursorのグローバル設定が必要な場合のみ（オプション）
# mkdir -p ~/.cursor
# curl -fsSL https://example.com/.cursorrules -o ~/.cursor/.cursorrules
```

### 方法3: Gitで管理

```bash
# 設定リポジトリをクローン
git clone https://github.com/your-team/ai-configs.git ~/.ai-configs

# シンボリックリンクを作成（Claude）
ln -s ~/.ai-configs/CLAUDE.md ~/.claude/CLAUDE.md

# Cursorのグローバル設定を共有したい場合のみ（任意）
# ln -s ~/.ai-configs/.cursorrules ~/.cursor/.cursorrules
```

## 📊 優先順位

AIツールは以下の優先順位で設定を読み込みます：

1. **プロジェクトローカル設定**（最優先）
   - `./CLAUDE.md`
   - `./.cursor/rules/*.mdc`

2. **グローバル設定**
   - `~/.claude/CLAUDE.md`
   - `~/.cursor/.cursorrules`（必要な場合のみ）

3. **デフォルト設定**
   - AIツールの標準設定

## 🔄 設定の更新

### チーム設定の更新を受け取る

```bash
# 最新版に更新（既存設定は自動バックアップ）
curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh | bash

# または、Gitで管理している場合
cd ~/.ai-configs && git pull
```
- 適用前に差分を確認したい場合は `--plan` または `--dry-run` を付与（例: `curl ... | bash -s -- --plan`）。

### 更新の通知

```bash
# ~/.zshrc または ~/.bashrc に追加
alias ai-update='curl -fsSL https://raw.githubusercontent.com/sk8metalme/ai-agent-setup/main/install-global.sh | bash'
```

## 🎯 ベストプラクティス

### 1. チーム設定の構成

```markdown
# ~/.claude/CLAUDE.md の例

# チーム共通設定
## 言語とスタイル
- 日本語で応答
- コードコメントは日本語

## コーディング規約
- [会社のコーディング規約へのリンク]
- ESLint設定に従う

## セキュリティポリシー
- APIキーをハードコードしない
- 個人情報を扱う際は注意

## 技術スタック（デフォルト）
- TypeScript 5.0+
- React 18+
- Node.js 20 LTS
```

### 2. プロジェクト固有の拡張

```bash
# プロジェクトディレクトリで
cd my-special-project

# グローバル設定を継承しつつカスタマイズ
cat > CLAUDE.md << 'EOF'
# プロジェクト固有設定

## グローバル設定を継承
※ ~/.claude/CLAUDE.md の設定も適用されます

## このプロジェクト特有の設定
- GraphQL APIを使用
- Prismaでデータベース管理
- Next.js 14のApp Router
EOF
```

### 3. 環境変数での制御

```bash
# 一時的にグローバル設定を無効化
export CLAUDE_IGNORE_GLOBAL=1
export CURSOR_IGNORE_GLOBAL=1
```

## 🛠️ トラブルシューティング

### 設定が読み込まれない

1. **ファイルの存在確認**
   ```bash
   ls -la ~/.claude/CLAUDE.md
   ls -la ~/.cursor/.cursorrules   # 使用している場合のみ
   ```

2. **権限の確認**
   ```bash
   chmod 644 ~/.claude/CLAUDE.md
   chmod 644 ~/.cursor/.cursorrules   # 使用している場合のみ
   ```

3. **AIツールの再起動**
   - Claude: プロジェクトを再度開く
   - Cursor: エディタを再起動

### バックアップからの復元

```bash
# バックアップファイルを探す
ls ~/.claude/CLAUDE.md.backup.*
ls ~/.cursor/.cursorrules.backup.*   # 使用している場合のみ

# 復元
cp ~/.claude/CLAUDE.md.backup.20240101_120000 ~/.claude/CLAUDE.md
```

## 🔐 セキュリティ考慮事項

1. **機密情報の扱い**
   - APIキーや認証情報は含めない
   - 会社固有の情報は慎重に扱う

2. **アクセス制御**
   ```bash
   # 自分だけが読み書きできるように
   chmod 600 ~/.claude/CLAUDE.md
   chmod 600 ~/.cursor/.cursorrules   # 使用している場合のみ
   ```

3. **監査ログ**
   ```bash
   # 設定変更を記録
   echo "[$(date)] Updated AI configs" >> ~/.ai-configs.log
   ```

## 📈 運用のヒント

### 定期的な見直し

```bash
# 月次レビュー用スクリプト
cat > ~/bin/ai-config-review << 'EOF'
#!/bin/bash
echo "=== AI設定レビュー ==="
echo "最終更新:"
stat -f "%Sm" ~/.claude/CLAUDE.md
stat -f "%Sm" ~/.cursor/.cursorrules
echo ""
echo "差分確認:"
diff ~/.claude/CLAUDE.md ~/.ai-configs/CLAUDE.md || true
EOF

chmod +x ~/bin/ai-config-review
```

### チーム全体への展開

```bash
# Slackでの共有例
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"AI設定を更新しました。以下のコマンドで更新してください:\n```\ncurl -fsSL https://our-team/install.sh | bash\n```"}' \
  YOUR_SLACK_WEBHOOK_URL
```

## まとめ

グローバル設定により、チーム全体で一貫したAI支援を受けられるようになります。定期的な更新と改善により、開発効率を継続的に向上させることができます。
