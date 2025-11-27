
# データベース設計ルール

## 命名規則
- テーブル名: 複数形のsnake_case（users, order_items）
- カラム名: snake_case（user_name, created_at）
- 主キー: id（整数型）
- 外部キー: テーブル名_id（user_id）
- インデックス: idx_テーブル名_カラム名

## テーブル設計
```sql
-- 基本的なテーブル構造
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP -- 論理削除用
);

-- インデックスの作成
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status) WHERE deleted_at IS NULL;
```

## ベストプラクティス
- 正規化を適切に行う（通常は第3正規形まで）
- 適切なデータ型を選択する
- NOT NULL制約を適切に使用する
- ユニーク制約で一意性を保証する
- 外部キー制約でデータ整合性を保つ

## インデックス戦略
- WHERE句で頻繁に使用されるカラムにインデックス
- JOIN条件に使用されるカラムにインデックス
- 複合インデックスはカラムの順序を考慮
- 部分インデックスで効率化
- 定期的にインデックスの使用状況を分析

## クエリ最適化
```sql
-- 良い例：必要なカラムのみ選択
SELECT id, name, email 
FROM users 
WHERE status = 'active' 
  AND deleted_at IS NULL
LIMIT 100;

-- 避けるべき：SELECT *
-- SELECT * FROM users;

-- EXPLAINで実行計画を確認
EXPLAIN ANALYZE
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY u.id, u.name;
```

## トランザクション管理
```sql
BEGIN;
    -- 複数の関連する操作
    INSERT INTO orders (user_id, total) VALUES (1, 1000);
    UPDATE users SET last_order_at = NOW() WHERE id = 1;
COMMIT;
```

## パフォーマンス対策
- N+1問題を避ける（EagerLoadingを使用）
- バッチ処理で大量データを扱う
- 適切なコネクションプーリング
- 読み取り専用のレプリカを活用
- キャッシュ戦略を実装

## セキュリティ
- SQLインジェクション対策（プリペアドステートメント使用）
- 適切な権限設定
- 機密データの暗号化
- 監査ログの実装
- バックアップとリカバリ計画
