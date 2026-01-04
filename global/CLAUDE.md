# グローバルClaude設定

## 基本設定のインポート

@base/CLAUDE-base.md

## チーム標準のインポート

@team/CLAUDE-team-standards.md

## セキュリティポリシーのインポート

@security/CLAUDE-security-policy.md

---

## 推奨プラグイン

### michi（推奨）

設計からリリースまでの包括的なワークフローをサポートします。

**インストール方法:**
```
/plugin marketplace add sk8metalme/michi
/plugin install michi@sk8metalme
npm install -g @sk8metal/michi-cli
```

詳細: https://github.com/sk8metalme/michi

### 基本プラグイン（michiが無い場合）

```
/plugin marketplace add sk8metalme/ai-agent-setup
/plugin install development-toolkit@ai-agent-setup
```

### 言語別プラグイン

```
/plugin install lang-java-spring@ai-agent-setup  # Java + Spring Boot
/plugin install lang-python@ai-agent-setup       # Python + FastAPI
/plugin install lang-php@ai-agent-setup          # PHP + Slim
/plugin install lang-perl@ai-agent-setup         # Perl + Mojolicious
```

### 機能プラグイン

```
/plugin install jujutsu-workflow@ai-agent-setup  # Jujutsu (jj) VCS
/plugin install ci-cd-tools@ai-agent-setup       # CI/CD トラブルシューティング
/plugin install design-review@ai-agent-setup     # UI/UX デザインレビュー
/plugin install e2e-planning@ai-agent-setup      # E2Eファースト開発計画
/plugin install oss-compliance@ai-agent-setup    # OSSライセンスチェック
/plugin install version-audit@ai-agent-setup     # 技術スタックバージョン監査
```

---

## 開発フロー

### michiワークフロー（推奨）

michiがインストールされている場合は、cc-sdd（仕様駆動開発）ワークフローを使用します：

```
Phase 0.0: /kiro:spec-init "description"     - 仕様初期化
Phase 0.1: /kiro:spec-requirements {feature} - 要件定義
Phase 0.2: /michi:spec-design {feature}      - 設計（テスト計画ガイド付き）
Phase 0.3-0.4: /michi:test-planning {feature} - テスト計画
Phase 0.5: /michi:spec-tasks {feature}       - タスク分割（JIRA同期確認付き）
Phase 2: /michi:spec-impl {feature}          - TDD実装 + 5フェーズ品質自動化
```

**michi固有機能:**
- 5フェーズ品質自動化（ライセンス監査→TDD→コードレビュー→カバレッジ95%→アーカイブ）
- PRサイズ監視（500行超過時に警告）
- JIRA/Confluence自動連携

### マルチリポジトリワークフロー

複数リポジトリにまたがるプロジェクトの場合：

```
/michi-multi-repo:spec-init "<説明>" --jira KEY --confluence-space SPACE
/michi-multi-repo:spec-requirements {project}  - 要件定義（EARS形式）
/michi-multi-repo:spec-design {project}        - 設計（C4モデル）
/michi-multi-repo:spec-review {project}        - クロスリポ整合性検証
/michi-multi-repo:propagate-specs {project}    - 各リポへ仕様展開（並列実行）
/michi-multi-repo:impl-all {project}           - 全リポ並行TDD実装
```

### 基本ワークフロー（development-toolkit）

michiが無い場合：

**計画フェーズ（SDD: 仕様駆動開発）**
```
/plan を実行 → 以下のフローが開始

1. 要件定義 - ステークホルダー確認、受入条件明確化
2. 計画立案 - スコープ定義、工数見積もり、リスク分析
3. 計画レビュー - 実現可能性確認
4. 詳細設計 - アーキテクチャ、インターフェース、データモデル
5. 設計レビュー - 技術的妥当性、セキュリティ確認
6. タスク分割 - 1-3日単位、依存関係マッピング
7. チケット作成 - JIRA等への登録
```

**開発フェーズ（TDD: テスト駆動開発）**
```
/dev を実行 → 以下のフローが開始

8. ブランチ作成 - feature/[タスク番号]-[説明]
9. TDD実装 - Red→Green→Refactor（1回最大100行変更）
10. PR作成 - ghコマンドでPR作成、CI確認
11. コードレビュー - 品質・セキュリティ確認
12. マージ - Squash and merge
```

---

## コマンドリファレンス

### michi コマンド（推奨）

| コマンド | 説明 | 使いどころ |
|---------|------|----------|
| `/michi:spec-design` | 設計書作成（テスト計画ガイド付き） | 設計フェーズ |
| `/michi:test-planning` | テスト計画（Phase 0.3-0.4統合） | 設計レビュー後 |
| `/michi:spec-tasks` | タスク分割（JIRA同期確認付き） | 設計完了後 |
| `/michi:spec-impl` | TDD実装 + 5フェーズ品質自動化 | 実装作業時 |
| `/michi:validate-design` | 設計レビュー（テスト計画確認付き） | 設計検証時 |
| `/michi:confluence-sync` | Confluenceに仕様書を同期 | 承認ワークフロー時 |
| `/michi:pr-resolve` | PRレビューコメント対応支援 | レビュー対応時 |
| `/michi:project-switch` | プロジェクト切り替え | マルチPJ時 |

### michi-multi-repo コマンド

| コマンド | 説明 | 使いどころ |
|---------|------|----------|
| `/michi-multi-repo:spec-init` | マルチリポPJ初期化 | 新規マルチリポPJ開始時 |
| `/michi-multi-repo:spec-requirements` | 要件定義書生成（EARS形式） | 要件定義フェーズ |
| `/michi-multi-repo:spec-design` | 設計書生成（C4モデル） | 設計フェーズ |
| `/michi-multi-repo:spec-review` | クロスリポ整合性検証 | 設計検証時 |
| `/michi-multi-repo:propagate-specs` | 各リポへ仕様展開（並列実行） | 仕様確定後 |
| `/michi-multi-repo:impl-all` | 全リポ並行TDD実装 | 実装作業時 |

### development-toolkit コマンド

| コマンド | 説明 | 使いどころ |
|---------|------|----------|
| `/plan` | 計画・設計フロー開始 | 新機能開発開始時 |
| `/dev` | TDD開発フロー開始 | 実装作業時 |
| `/create_pr` | PR作成+コードレビュー | 実装完了後 |
| `/git_sync` | mainブランチ同期 | PRマージ後 |
| `/documentation` | ドキュメント整理 | 新規参画時 |
| `/suggest-claude-md` | CLAUDE.mdルール提案 | 繰り返しパターン発見時 |

---

## エージェント（自動実行）

### michi エージェント

| エージェント | 機能 | トリガー |
|------------|------|---------|
| `mermaid-validator` | Mermaid図の構文検証・自動修正 | ドキュメント編集時（PROACTIVE） |
| `pr-resolver` | PRコメントのresolve処理 | `/michi:pr-resolve`実行時 |
| `pr-size-monitor` | PRサイズ監視・分割提案 | 500行超過時に警告 |

### development-toolkit / 機能プラグイン エージェント

| エージェント | プラグイン | 機能 | トリガー |
|------------|----------|------|---------|
| `changelog-generator` | development-toolkit | CHANGELOG自動生成 | リリース時 |
| `pr-resolver` | development-toolkit | PRコメント解決 | レビュー対応後 |
| `design-reviewer` | design-review | UIアクセシビリティ検証 | UI実装時 |
| `e2e-first-planner` | e2e-planning | 縦割りタスク分割 | 計画フェーズ |
| `oss-license-checker` | oss-compliance | ライセンス監査 | 依存追加時 |
| `stable-version-auditor` | version-audit | EOLチェック | 定期監査時 |

---

## スキル

### michi スキル

| スキル | 用途 |
|-------|------|
| `/michi:mermaid-validator` | Mermaid図の構文検証・自動修正 |

### 言語別スキル

| スキル | プラグイン | 用途 |
|-------|----------|------|
| `/java-spring` | lang-java-spring | NullAway, JUnit5, Spring Boot |
| `/python-dev` | lang-python | ruff, mypy, FastAPI |
| `/php-dev` | lang-php | PHPStan, PSR-12, Slim |
| `/perl-dev` | lang-perl | perlcritic, Mojolicious |

### 機能スキル

| スキル | プラグイン | 用途 |
|-------|----------|------|
| `/ci-cd` | ci-cd-tools | GitHub Actions/Screwdriver |
| `/design-review` | design-review | WCAG 2.1, Core Web Vitals |
| `/e2e-first-planning` | e2e-planning | Walking Skeleton設計 |
| `/oss-license` | oss-compliance | ライセンス確認ガイド |
| `/stable-version` | version-audit | LTS/EOL確認 |
| `/jujutsu-workflow` | jujutsu-workflow | jj VCS操作 |
| `/secrets-guard` | development-toolkit | 秘密情報管理（多層防御） |

---

## MCP活用による品質向上

### review-dojo-mcp（レビュー知見の自動蓄積）

PRレビューコメントから知見を自動収集・蓄積します。

- `search_knowledge`: カテゴリ・言語・重要度でフィルタ
- `generate_pr_checklist`: 変更ファイルから関連知見をチェックリスト化

詳細: https://github.com/sk8metalme/review-dojo-mcp

### context7（最新ライブラリドキュメント）

リアルタイムのライブラリドキュメントをプロンプトに自動挿入します。

- "use context7" をプロンプトに追加するだけで動作
- Next.js、MongoDB等30以上のライブラリに対応

詳細: https://github.com/upstash/context7

**設定例（CLAUDE.mdに追記）:**
```
コード関連の質問時は自動的にcontext7を活用すること
```

---

## バイブコーディングのベストプラクティス

### コンテキスト管理

- `docs/tmp/context.md` で作業状態を維持
- `docs/tmp/plan.md` で計画を文書化
- セッション開始時にこれらを確認・更新

### AIとの効果的な対話

1. **明確な指示**: 曖昧さを排除し、具体的な要件を伝える
2. **段階的な確認**: 大きな変更前に設計意図を確認
3. **エラー時の対応**: エラーメッセージを完全に共有

### 効率化テクニック

- `/suggest-claude-md` で繰り返しパターンを自動検出
- エージェントの自動実行を活用
- コマンドチェーンで作業を効率化
- review-dojo-mcpで過去の知見を活用
- context7で最新ドキュメントを参照
