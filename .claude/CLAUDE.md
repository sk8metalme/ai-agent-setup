# プロジェクト設定テンプレート

このファイルはプロジェクトテンプレートです。実際のプロジェクトでは、必要なプラグインをインストールして使用してください。

## 必要なプラグインのインストール

このプロジェクトテンプレートを使用するには、以下のプラグインをインストールしてください：

### 基本プラグイン（推奨）

```
/plugin install team-standards@ai-agent-setup
/plugin install development-toolkit@ai-agent-setup
```

### 言語別プラグイン（該当言語の場合のみ）

```
/plugin install lang-java-spring@ai-agent-setup  # Java + Spring Boot
/plugin install lang-python@ai-agent-setup       # Python + FastAPI
/plugin install lang-php@ai-agent-setup          # PHP + Slim
/plugin install lang-perl@ai-agent-setup         # Perl + Mojolicious
```

### その他の機能プラグイン（必要に応じて）

```
/plugin install jujutsu-workflow@ai-agent-setup  # Jujutsu (jj) VCS
/plugin install ci-cd-tools@ai-agent-setup       # CI/CD トラブルシューティング
/plugin install design-review@ai-agent-setup     # UI/UX デザインレビュー
/plugin install e2e-planning@ai-agent-setup      # E2Eファースト開発計画
/plugin install oss-compliance@ai-agent-setup    # OSSライセンスチェック
/plugin install version-audit@ai-agent-setup     # 技術スタックバージョン監査
```

---

## プロジェクト固有の設定

### プロジェクト情報
- **プロジェクト名**: [プロジェクト名を入力]
- **開始日**: [開始日を入力]
- **主要言語**: [使用する言語を指定]
- **フレームワーク**: [使用するフレームワークを指定]

### このプロジェクト特有のルール

1. **特別な要件**
   - [プロジェクト固有の要件を記載]

2. **技術的制約**
   - [制約事項を記載]

3. **パフォーマンス目標**
   - [目標値を記載]

---

## カスタム拡張

### プロジェクト専用のサブエージェント

<!-- 必要に応じて定義 -->

### プロジェクト専用のコマンド

<!-- 必要に応じて定義 -->

---

注: このファイルはプロジェクトテンプレートです。
実際の設定はプラグインシステムによって提供されます。
