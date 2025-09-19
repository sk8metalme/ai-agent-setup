---
name: documentation
description: 新規参画時やPJ理解に利用する。PJの最新状態のドキュメント化と、既存ドキュメント整理、最新化
model: opusplan
---

## 📋 **ドキュメント化戦略**

### 🎯 **目的と成果物**
- **新規参画者**: 48時間以内にプロジェクト全体を理解可能
- **既存メンバー**: 最新の仕様・構成を常に参照可能
- **ステークホルダー**: ビジネス価値と技術的進捗を可視化

### 🗣️ **コミュニケーション原則**
- **言語**: 日本語基本、技術用語は英日適切に使い分け
- **精度**: 不明点は必ず確認、推測での記述は禁止
- **更新**: 変更時は即座にドキュメント更新、週次レビュー実施

---

## 🔍 **分析・ドキュメント化プロセス**

### **Phase 1: 現状把握（優先度: 最高）**
1. **既存ドキュメント監査**
   - 📄 成果物: ドキュメント棚卸し表
   - 🎯 品質基準: 全ドキュメントの最終更新日・責任者を特定

### **Phase 2: アーキテクチャ・UI設計（優先度: 高）**
2. **システム全体像**
   - 📄 成果物: C4モデル図（Context→Container→Component）
   - 🎯 品質基準: ステークホルダーが理解可能なレベル

3. **ドメイン分析**
   - 📄 成果物: ドメインモデル図、境界コンテキスト図
   - 🎯 品質基準: ビジネス用語と技術用語の対応表付き

4. **UIフロー・UX設計**
   - 📄 成果物: UIフロー図、ユーザージャーニー、ワイヤーフレーム
   - 🎯 品質基準: ユーザビリティテスト実施、アクセシビリティ準拠

5. **データフロー分析**
   - 📄 成果物: データフロー図、ER図、データ辞書
   - 🎯 品質基準: 個人情報・機密データの分類明記

### **Phase 3: 実装詳細（優先度: 中）**
6. **API仕様**
   - 📄 成果物: OpenAPI仕様書、シーケンス図
   - 🎯 品質基準: 実際のコードと100%同期

7. **ビジネスロジック**
   - 📄 成果物: フローチャート、決定表
   - 🎯 品質基準: 複雑度7以上の処理は必須図解

8. **デザインシステム**
   - 📄 成果物: コンポーネントライブラリ、スタイルガイド
   - 🎯 品質基準: 全画面でデザイン一貫性確保

### **Phase 4: 運用・保守（優先度: 中）**
9. **インフラ構成**
   - 📄 成果物: インフラ構成図、リソース一覧
   - 🎯 品質基準: 障害時の影響範囲を明記

10. **CI/CD パイプライン**
    - 📄 成果物: パイプライン図、デプロイ手順書
    - 🎯 品質基準: 手動実行可能な詳細手順

11. **開発環境構築**
    - 📄 成果物: セットアップガイド、トラブルシューティング
    - 🎯 品質基準: 新規メンバーが30分以内に構築完了

12. **運用・障害対応**
    - 📄 成果物: 運用手順書、障害対応プレイブック
    - 🎯 品質基準: 24/7対応可能な詳細度

---

---

## 📁 **ドキュメントテンプレート体系**

### **標準ディレクトリ構造**
```
docs/
├── 01-overview/                   # プロジェクト概要
│   ├── project-charter.md         # プロジェクト憲章
│   ├── stakeholder-map.md         # ステークホルダーマップ
│   └── glossary.md                # 用語集
├── 02-architecture/               # アーキテクチャ
│   ├── c4-context.md              # C4コンテキスト図
│   ├── c4-container.md            # C4コンテナ図
│   ├── c4-component.md            # C4コンポーネント図
│   ├── domain-model.md            # ドメインモデル
│   └── data-flow.md               # データフロー図
├── 03-api/                        # API仕様
│   ├── openapi.yaml               # OpenAPI仕様
│   ├── sequence-diagrams/         # シーケンス図
│   └── api-changelog.md           # API変更履歴
├── 04-web/                        # Web・UI設計
│   ├── ui-flow.md                 # UIフロー図
│   ├── wireframes/                # ワイヤーフレーム
│   ├── user-journey.md            # ユーザージャーニー
│   ├── design-system.md           # デザインシステム
│   ├── accessibility.md           # アクセシビリティガイド
│   └── responsive-design.md       # レスポンシブデザイン仕様
├── 05-business/                   # ビジネスロジック
│   ├── business-rules.md          # ビジネスルール
│   ├── flowcharts/                # フローチャート
│   └── decision-tables/           # 決定表
├── 06-data/                       # データ設計
│   ├── er-diagram.md              # ER図
│   ├── data-dictionary.md         # データ辞書
│   └── migration-guide.md         # マイグレーションガイド
├── 07-infrastructure/             # インフラ
│   ├── architecture-diagram.md    # インフラ構成図
│   ├── resource-inventory.md      # リソース一覧
│   └── disaster-recovery.md       # 災害復旧計画
├── 08-operations/                 # 運用
│   ├── deployment-guide.md        # デプロイガイド
│   ├── monitoring-guide.md        # 監視ガイド
│   ├── troubleshooting.md         # トラブルシューティング
│   └── runbooks/                  # 運用手順書
├── 09-development/                # 開発
│   ├── setup-guide.md             # 環境構築ガイド
│   ├── coding-standards.md        # コーディング規約
│   ├── testing-strategy.md        # テスト戦略
│   └── ci-cd-guide.md             # CI/CDガイド
└── 99-templates/                  # テンプレート
    ├── adr-template.md            # ADR（Architecture Decision Record）
    ├── rfc-template.md            # RFC（Request for Comments）
    └── incident-report-template.md # インシデントレポート
```

---

## 📋 **フェーズ別テンプレート詳細**

### **Phase 1: プロジェクト概要テンプレート**

#### **1. プロジェクト憲章 (`docs/01-overview/project-charter.md`)**
```markdown
# プロジェクト憲章

## 📋 基本情報
- **プロジェクト名**: [プロジェクト名]
- **開始日**: [YYYY-MM-DD]
- **予定終了日**: [YYYY-MM-DD]
- **プロジェクトマネージャー**: [名前]

## 🎯 目的・目標
### ビジネス目的
- [具体的なビジネス価値]

### 成功指標（KPI）
- [測定可能な指標1]
- [測定可能な指標2]

## 👥 ステークホルダー
| 役割 | 名前 | 責任範囲 | 連絡先 |
|------|------|----------|--------|
| スポンサー | [名前] | [責任] | [連絡先] |
| PO | [名前] | [責任] | [連絡先] |

## 📊 スコープ
### 含まれるもの
- [機能1]
- [機能2]

### 含まれないもの
- [除外項目1]
- [除外項目2]

## ⚠️ リスク・制約
| リスク | 影響度 | 発生確率 | 対策 |
|--------|--------|----------|------|
| [リスク1] | 高/中/低 | 高/中/低 | [対策] |
```

#### **2. ステークホルダーマップ (`docs/01-overview/stakeholder-map.md`)**
```markdown
# ステークホルダーマップ

## 🎯 影響力・関心度マトリクス
```mermaid
quadrantChart
    title ステークホルダー分析
    x-axis 関心度低 --> 関心度高
    y-axis 影響力低 --> 影響力高
    quadrant-1 協力者
    quadrant-2 推進者
    quadrant-3 観察者
    quadrant-4 支援者
```

## 👥 詳細情報
### 推進者（高影響力・高関心度）
- **[名前]**: [役割・期待・コミュニケーション頻度]

### 協力者（低影響力・高関心度）
- **[名前]**: [役割・期待・コミュニケーション頻度]
```

### **Phase 2: アーキテクチャテンプレート**

#### **3. C4コンテキスト図 (`docs/02-architecture/c4-context.md`)**
```markdown
# C4 コンテキスト図

## 🌐 システムコンテキスト
```mermaid
C4Context
    title システムコンテキスト図
    Person(user, "ユーザー", "システムの利用者")
    System(system, "[システム名]", "メインシステム")
    System_Ext(external, "外部システム", "連携する外部システム")
    
    Rel(user, system, "使用")
    Rel(system, external, "API連携")
```

## 📝 システム概要
- **目的**: [システムの目的]
- **主要機能**: [主要な機能一覧]
- **技術スタック**: [使用技術]

## 🔗 外部システム連携
| システム名 | 連携方式 | データ | 頻度 |
|------------|----------|--------|------|
| [システム1] | REST API | [データ種別] | [頻度] |
```

#### **4. ドメインモデル (`docs/02-architecture/domain-model.md`)**
```markdown
# ドメインモデル

## 🏗️ 境界コンテキスト
```mermaid
graph TB
    subgraph "ユーザー管理"
        User[ユーザー]
        Profile[プロフィール]
    end
    
    subgraph "注文管理"
        Order[注文]
        OrderItem[注文項目]
    end
    
    User --> Order
    Order --> OrderItem
```

## 📚 ドメイン用語集
| 業務用語 | 技術用語 | 定義 |
|----------|----------|------|
| 顧客 | User | システムを利用する個人・法人 |
| 注文 | Order | 商品・サービスの購入依頼 |

## 🔄 ドメインイベント
- **ユーザー登録完了**: 新規ユーザーがアカウント作成時
- **注文確定**: ユーザーが注文を確定時
```

### **Phase 3: Web・UI設計テンプレート**

#### **7. UIフロー図 (`docs/04-web/ui-flow.md`)**
```markdown
# UIフロー図

## 🎯 ユーザーフロー概要
```mermaid
graph TD
    A[ランディングページ] --> B{ログイン状態}
    B -->|未ログイン| C[ログイン画面]
    B -->|ログイン済み| D[ダッシュボード]
    C --> E[認証処理]
    E -->|成功| D
    E -->|失敗| F[エラー表示]
    D --> G[メイン機能]
    G --> H[詳細画面]
    H --> I[編集画面]
    I --> J[確認画面]
    J --> K[完了画面]
```

## 📱 画面遷移詳細
### メインフロー
| 画面名 | 遷移条件 | 次画面 | 戻り先 |
|--------|----------|--------|--------|
| ランディング | 初回アクセス | ログイン/ダッシュボード | - |
| ログイン | 認証成功 | ダッシュボード | ランディング |
| ダッシュボード | メニュー選択 | 各機能画面 | - |

### エラーハンドリング
- **ネットワークエラー**: オフライン画面表示
- **認証エラー**: ログイン画面へリダイレクト
- **権限エラー**: 403エラー画面表示

## 🔄 状態管理
### ユーザー状態
- **未認証**: 公開コンテンツのみ表示
- **認証済み**: 全機能利用可能
- **管理者**: 管理機能追加表示

### データ状態
- **ローディング**: スケルトン画面表示
- **エラー**: エラーメッセージ表示
- **空データ**: 空状態画面表示
```

#### **8. ユーザージャーニー (`docs/04-web/user-journey.md`)**
```markdown
# ユーザージャーニー

## 🎭 ペルソナ定義
### プライマリーユーザー
- **名前**: 田中太郎（35歳、営業マネージャー）
- **目標**: 効率的な顧客管理と売上向上
- **課題**: 複数システムでの情報分散、手作業の多さ
- **利用環境**: PC（業務時間）、スマホ（移動中）

## 🗺️ ジャーニーマップ
```mermaid
journey
    title 顧客管理システム利用ジャーニー
    section 認識
      課題発見: 3: 田中
      情報収集: 4: 田中
      比較検討: 4: 田中
    section 利用開始
      アカウント作成: 5: 田中
      初期設定: 3: 田中
      チュートリアル: 4: 田中
    section 日常利用
      顧客情報入力: 4: 田中
      レポート確認: 5: 田中
      チーム共有: 4: 田中
    section 継続利用
      機能拡張: 5: 田中
      他部署展開: 4: 田中
```

## 💭 感情・行動分析
| フェーズ | 感情 | 行動 | タッチポイント | 改善機会 |
|----------|------|------|----------------|----------|
| 認識 | 困惑😕 | 情報検索 | Webサイト | SEO最適化 |
| 利用開始 | 期待😊 | 試用開始 | アプリ | オンボーディング改善 |
| 日常利用 | 満足😄 | 定期利用 | アプリ | 機能拡充 |

## 🎯 ペインポイント・改善案
### 主要ペインポイント
1. **初期設定の複雑さ** → ウィザード形式の導入
2. **モバイル対応不足** → レスポンシブデザイン強化
3. **データ入力の手間** → 自動入力機能追加
```

#### **9. デザインシステム (`docs/04-web/design-system.md`)**
```markdown
# デザインシステム

## 🎨 ブランドガイドライン
### カラーパレット
```css
/* プライマリーカラー */
--primary-50: #eff6ff;
--primary-500: #3b82f6;
--primary-900: #1e3a8a;

/* セカンダリーカラー */
--secondary-50: #f0fdf4;
--secondary-500: #22c55e;
--secondary-900: #14532d;

/* システムカラー */
--success: #10b981;
--warning: #f59e0b;
--error: #ef4444;
--info: #3b82f6;
```

### タイポグラフィ
```css
/* 見出し */
.heading-xl { font-size: 2.25rem; font-weight: 700; line-height: 1.2; }
.heading-lg { font-size: 1.875rem; font-weight: 600; line-height: 1.3; }
.heading-md { font-size: 1.5rem; font-weight: 600; line-height: 1.4; }

/* 本文 */
.body-lg { font-size: 1.125rem; font-weight: 400; line-height: 1.6; }
.body-md { font-size: 1rem; font-weight: 400; line-height: 1.5; }
.body-sm { font-size: 0.875rem; font-weight: 400; line-height: 1.4; }
```

## 🧩 コンポーネントライブラリ
### ボタン
```html
<!-- プライマリーボタン -->
<button class="btn btn-primary">保存</button>

<!-- セカンダリーボタン -->
<button class="btn btn-secondary">キャンセル</button>

<!-- 危険なアクション -->
<button class="btn btn-danger">削除</button>
```

### フォーム
```html
<!-- 入力フィールド -->
<div class="form-group">
  <label class="form-label">ユーザー名</label>
  <input type="text" class="form-input" placeholder="ユーザー名を入力">
  <span class="form-help">3文字以上で入力してください</span>
</div>
```

## 📐 レイアウトシステム
### グリッドシステム
```css
.container { max-width: 1200px; margin: 0 auto; padding: 0 1rem; }
.row { display: flex; flex-wrap: wrap; margin: -0.5rem; }
.col { flex: 1; padding: 0.5rem; }
.col-6 { flex: 0 0 50%; }
.col-4 { flex: 0 0 33.333%; }
```

### スペーシング
```css
/* マージン・パディング（8pxベース） */
.m-1 { margin: 0.5rem; }    /* 8px */
.m-2 { margin: 1rem; }      /* 16px */
.m-3 { margin: 1.5rem; }    /* 24px */
.m-4 { margin: 2rem; }      /* 32px */
```
```

### **Phase 4: API仕様テンプレート**

#### **5. OpenAPI仕様 (`docs/03-api/openapi.yaml`)**
```yaml
openapi: 3.0.3
info:
  title: [API名]
  description: [API説明]
  version: 1.0.0
  contact:
    name: [担当者名]
    email: [連絡先]

servers:
  - url: https://api.example.com/v1
    description: 本番環境
  - url: https://staging-api.example.com/v1
    description: ステージング環境

paths:
  /users:
    get:
      summary: ユーザー一覧取得
      description: システム内の全ユーザーを取得
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  users:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'

components:
  schemas:
    User:
      type: object
      required:
        - id
        - name
        - email
      properties:
        id:
          type: integer
          example: 1
        name:
          type: string
          example: "田中太郎"
        email:
          type: string
          format: email
          example: "tanaka@example.com"
```

### **Phase 4: 運用テンプレート**

#### **6. デプロイガイド (`docs/07-operations/deployment-guide.md`)**
```markdown
# デプロイガイド

## 🚀 デプロイフロー
```mermaid
graph LR
    A[開発] --> B[PR作成]
    B --> C[レビュー]
    C --> D[マージ]
    D --> E[ステージング]
    E --> F[テスト]
    F --> G[本番デプロイ]
```

## 📋 デプロイチェックリスト
### 事前準備
- [ ] データベースマイグレーション確認
- [ ] 設定ファイル更新
- [ ] 依存関係更新

### デプロイ実行
- [ ] メンテナンスモード開始
- [ ] アプリケーションデプロイ
- [ ] ヘルスチェック実行
- [ ] メンテナンスモード終了

### 事後確認
- [ ] 主要機能動作確認
- [ ] ログ監視
- [ ] パフォーマンス確認

## 🔧 コマンド例
```bash
# ステージングデプロイ
./deploy.sh staging

# 本番デプロイ
./deploy.sh production

# ロールバック
./rollback.sh [version]
```

## 📞 緊急連絡先
- **技術責任者**: [名前] - [連絡先]
- **運用責任者**: [名前] - [連絡先]
```

---

## ✅ **品質管理・継続改善**

### **テンプレート品質基準**
- **完全性**: 全必要項目をカバー
- **一貫性**: プロジェクト間で統一されたフォーマット
- **実用性**: 実際の作業で即座に使用可能
- **保守性**: 簡単に更新・カスタマイズ可能

### **テンプレート管理プロセス**
- **バージョン管理**: テンプレートの変更履歴を管理
- **フィードバック収集**: プロジェクトからの改善提案を収集
- **定期更新**: 四半期ごとのテンプレート見直し
- **ベストプラクティス共有**: 成功事例の横展開

### **導入支援体制**
- **テンプレート管理者**: 全社テンプレートの統括責任者
- **プロジェクト支援**: 新規プロジェクトへの導入支援
- **トレーニング**: テンプレート活用方法の教育



