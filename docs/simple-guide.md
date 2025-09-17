# シンプルセットアップガイド

AIエージェント（Claude、Cursor）の設定を最小限の手間で行う方法です。

## 🚀 5分でセットアップ

### 新しいセットアップ方法

#### Claude グローバル設定
```bash
# チーム共通のClaude設定をインストール
curl -fsSL https://raw.githubusercontent.com/arigatatsuya/ai-agent-setup/main/install-global.sh | bash
```

#### プロジェクト用設定（Cursor/AGENTS.md）
```bash
# プロジェクト固有の設定をインストール
curl -fsSL https://raw.githubusercontent.com/arigatatsuya/ai-agent-setup/main/install-project.sh | bash
```

### ステップ1: グローバル設定（Claude用）

1. **インストール実行**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/arigatatsuya/ai-agent-setup/main/install-global.sh | bash
   ```

2. **言語選択**
   - Java + Spring Boot
   - PHP
   - Perl
   - すべて

3. **設定場所**: `~/.claude/`

### ステップ2: プロジェクト設定（Cursor/AGENTS.md用）

1. **プロジェクトルートで実行**
   ```bash
   cd your-project/
   curl -fsSL https://raw.githubusercontent.com/arigatatsuya/ai-agent-setup/main/install-project.sh | bash
   ```

2. **設定タイプ選択**
   - Cursor Project Rules (.mdc)
   - AGENTS.md (シンプル)
   - 両方

3. **言語選択**
   - Java + Spring Boot
   - PHP
   - Perl
   - すべて

### ステップ3: 設定確認

#### Claude設定
```
~/.claude/
├── CLAUDE.md                    # メインエントリーポイント
├── base/CLAUDE-base.md         # 基本設定
├── team/CLAUDE-team-standards.md # チーム標準
├── security/CLAUDE-security-policy.md # セキュリティ
└── languages/
    ├── java-spring/CLAUDE-java-spring.md
    ├── php/CLAUDE-php.md
    └── perl/CLAUDE-perl.md
```

#### プロジェクト設定
```
your-project/
├── .cursor/
│   └── rules/                # Project Rules
│       ├── general.mdc       # 基本ルール
│       └── java-spring.mdc   # 言語固有
├── AGENTS.md                 # シンプルな代替手段
└── src/                      # ソースコード
```

### ステップ4: カスタマイズ

必要に応じて設定ファイルを編集：

#### Claude設定のカスタマイズ
```bash
# 言語設定のコメントを外す
vi ~/.claude/CLAUDE.md

# 例: Java + Spring Boot を有効化
<!-- Java + Spring Boot -->
@languages/java-spring/CLAUDE-java-spring.md
```

#### プロジェクト設定のカスタマイズ
```bash
# Cursor Project Rules
vi .cursor/rules/general.mdc

# AGENTS.md
vi AGENTS.md
```

## 📝 最小限の設定例

### 手動設定の場合

#### 超シンプル版 CLAUDE.md
```markdown
# プロジェクト設定

- 日本語で応答
- Java + Spring Boot
- テスト駆動開発
- カバレッジ95%以上
```

#### 超シンプル版 AGENTS.md
```markdown
# AI Agent Instructions

## 基本設定
- 日本語で応答してください
- Java + Spring Boot を使用
- テストを必ず書く
- クリーンコードを心がける

## コーディング規約
- Google Java Style Guide準拠
- Spring Bootベストプラクティス
- 依存性注入はコンストラクタ経由
```

## 💡 便利なTips

### 1. 設定の更新
```bash
# グローバル設定の再インストール
curl -fsSL https://raw.githubusercontent.com/arigatatsuya/ai-agent-setup/main/install-global.sh | bash

# プロジェクト設定の再インストール
curl -fsSL https://raw.githubusercontent.com/arigatatsuya/ai-agent-setup/main/install-project.sh | bash
```

### 2. Gitで管理
```bash
# プロジェクト設定をバージョン管理に含める
git add .cursor/rules/ AGENTS.md
git commit -m "Add AI agent project configurations"
```

### 3. 設定の検証

**Claude**:
1. プロジェクトを開く
2. グローバル設定 (`~/.claude/CLAUDE.md`) が自動読み込み
3. プロジェクト固有設定があれば追加で読み込み

**Cursor**:
1. Cursorでプロジェクトを開く
2. `.cursor/rules/*.mdc` が自動適用
3. Cmd/Ctrl + K → "Rules"で設定内容を確認

## 🔧 トラブルシューティング

### 設定が反映されない

1. **ファイル名を確認**
   - Claude: `CLAUDE.md`（大文字）
   - Cursor: `.cursor/rules/*.mdc`
   - AGENTS.md: `AGENTS.md`

2. **ファイルの場所**
   - Claude: `~/.claude/` (グローバル)
   - Cursor/AGENTS.md: プロジェクトルート

3. **エンコーディング**
   - UTF-8で保存

### インストールエラー
```bash
# ネットワーク接続を確認
curl -I https://raw.githubusercontent.com/arigatatsuya/ai-agent-setup/main/install-global.sh

# 権限エラーの場合
chmod +x install-global.sh
chmod +x install-project.sh
```

### 日本語が文字化けする
```bash
# ファイルのエンコーディングを確認
file -I ~/.claude/CLAUDE.md

# UTF-8に変換
iconv -f SHIFT-JIS -t UTF-8 ~/.claude/CLAUDE.md > ~/.claude/CLAUDE.md.new
mv ~/.claude/CLAUDE.md.new ~/.claude/CLAUDE.md
```

## 🎯 次のステップ

1. **基本設定で始める**
   - まずは推奨インストーラーを使用
   - 必要に応じてカスタマイズ

2. **チームで共有**
   - プロジェクト設定をGitにコミット
   - グローバル設定はチーム標準として統一

3. **定期的に更新**
   - 設定ファイルの更新を確認
   - 新しい要件に合わせて調整

## 📚 参考リンク

- [Claude Projects](https://support.anthropic.com/ja/articles/9517075)
- [Cursor Documentation](https://docs.cursor.com/)
- [Cursor Project Rules](https://docs.cursor.com/ja/context/rules)

---

新しい構成では、グローバル設定とプロジェクト設定が明確に分離され、より使いやすくなりました！