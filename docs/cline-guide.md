# Clineルールガイド

このガイドでは、VSCode拡張機能「Cline」用のルール設定について説明します。

## 📖 Clineとは

Clineは、VSCode/Cursor用のAIコーディングアシスタント拡張機能です。プロジェクトルールやグローバルルールを定義することで、AIエージェントの振る舞いをカスタマイズできます。

**公式ドキュメント**: https://docs.cline.bot/features/cline-rules

## 🎯 このプロジェクトでのClineサポート

本プロジェクトでは、既存の`.cursor/rules/`配下のルールをCline用に変換して提供しています。

### 対応ルール（7ファイル）

| ファイル名 | 説明 |
|-----------|------|
| `general.md` | 全般的な開発ルール |
| `jujutsu.md` | Jujutsuバージョン管理ルール（SSOT） |
| `java-spring.md` | Java + Spring Boot |
| `php.md` | PHP |
| `python.md` | Python |
| `perl.md` | Perl |
| `database.md` | データベース設計 |

## 📁 ルールファイルの配置場所

Clineは2種類のルール配置場所をサポートしています。

### 1. グローバルルール

**配置場所（macOS）**: `~/Documents/Cline/Rules/`

**用途**: すべてのプロジェクトで共通のルール

**インストール方法**:
```bash
# このリポジトリで実行
./install-global.sh
```

グローバルルールは自動的に `~/Documents/Cline/Rules/` にインストールされます。

### 2. プロジェクトルール

**配置場所**: プロジェクトルートの `.clinerules/`

**用途**: 特定のプロジェクト固有のルール

**インストール方法**:
- `install-global.sh` を実行すると、カレントディレクトリの `.clinerules/` にも同時にインストールされます
- または、このリポジトリの `.clinerules/` をコピー

## 🚀 使用開始手順

### Step 1: Cline拡張機能をインストール

VSCodeの拡張機能マーケットプレースから「Cline」をインストール

### Step 2: ルールファイルをインストール

```bash
cd /path/to/ai-agent-setup
./install-global.sh
```

インストール完了後、以下にルールファイルが配置されます：
- グローバル: `~/Documents/Cline/Rules/`
- プロジェクト: `.clinerules/`

### Step 3: Clineを起動

VSCodeでClineを起動すると、自動的にルールファイルが読み込まれます。

## 🔄 Cursorルール (.mdc) との違い

### ファイル形式

**Cursor（.mdc）:**
```yaml
---
description: ルールの説明
alwaysApply: true
globs:
  - "**/*.ts"
---
# Markdown本文
```

**Cline（.md）:**
```markdown
# Markdown本文のみ
```

### 変換内容

本プロジェクトでは、以下の変換を行っています：

1. **.mdc → .md**: 拡張子変更
2. **frontmatter削除**: YAML形式のメタデータ（`---`で囲まれた部分）を削除
3. **Markdown本文維持**: ルール内容はそのまま

### SSOTの原則

**重要**: `.cursor/rules/jujutsu.mdc` が正規ソース（SSOT）です。

- `.cursor/rules/jujutsu.mdc` → Cursor用（SSOT）
- `.clinerules/jujutsu.md` → Cline用（SSO

Tから変換）
- `.claude/jujutsu/jujutsu-rule.md` → Claude用（SSO Tから参照）

## 🛠️ カスタマイズ

### 言語固有ルールの有効化

プロジェクトで使用する言語に応じて、不要なルールファイルを削除できます：

```bash
# 例: Java Spring Bootのみ使用する場合
cd .clinerules
rm php.md python.md perl.md
```

### ルールの追加

プロジェクト固有のルールを追加する場合：

1. `.clinerules/` 配下に新しい `.md` ファイルを作成
2. Markdown形式でルールを記述
3. Clineを再起動

**例**: `.clinerules/project-specific.md`
```markdown
# プロジェクト固有ルール

## 特殊な命名規則
- テーブル名は必ず `tbl_` プレフィックスを付ける
- APIエンドポイントは `/api/v2/` で始まる

## チーム固有の制約
- レビューなしでmainにマージ禁止
- CI/CD完了までマージ不可
```

## 📝 更新方法

### グローバルルールの更新

このリポジトリの最新版を取得して、再度インストール：

```bash
cd /path/to/ai-agent-setup
git pull
./install-global.sh
```

既存ファイルは自動的にバックアップされます（`.backup.日時`形式）。

### プロジェクトルールの更新

プロジェクトごとに更新：

```bash
cd /path/to/your-project
# このリポジトリのルールをコピー
cp -r /path/to/ai-agent-setup/.clinerules/ .
```

## ⚙️ トラブルシューティング

### ルールが反映されない

1. **配置場所を確認**
   ```bash
   ls ~/Documents/Cline/Rules/
   ls .clinerules/
   ```

2. **Clineを再起動**

3. **ファイル形式を確認**
   - 拡張子は `.md` か
   - frontmatterが残っていないか

### ルールの優先順位

Clineの公式ドキュメントでは優先順位が明示されていませんが、一般的には：
1. プロジェクトルール（`.clinerules/`）
2. グローバルルール（`~/Documents/Cline/Rules/`）

の順で読み込まれると考えられます。

## 🔗 関連リンク

- [Cline公式サイト](https://docs.cline.bot/)
- [Clineルール機能](https://docs.cline.bot/features/cline-rules)
- [Cursorルールガイド](.cursor/rules/README.md)
- [Claude設定ガイド](claude-import-guide.md)

## 💡 ベストプラクティス

1. **グローバルルールは最小限に**
   - チーム共通のルールのみグローバルに配置
   - プロジェクト固有のルールは `.clinerules/` に配置

2. **定期的な更新**
   - チームのルールが変更されたらグローバルルールを更新
   - `git pull` + `./install-global.sh` で最新化

3. **SSOT原則の遵守**
   - `.cursor/rules/` が正規ソース
   - Cline用ルールは自動変換で生成
   - 手動編集は `.cursor/rules/` のみ

4. **バージョン管理**
   - `.clinerules/` はプロジェクトにコミット
   - チーム全員が同じルールを共有

---

**最終更新**: 2025-11-20
