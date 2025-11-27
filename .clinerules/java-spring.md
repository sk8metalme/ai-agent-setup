
# Java Spring Boot 開発

## アーキテクチャ
- レイヤードアーキテクチャに従う（Controller → Service → Repository）
- ドメイン駆動設計の原則を適用する
- コンストラクタ経由で依存性注入を使用する
- 適切な例外処理を実装する
- Gradle 8.xでビルド管理
- Rocky Linux 9でのデプロイを想定

## Springの慣習
```java
@RestController
@RequestMapping("/api/v1/resource")
@RequiredArgsConstructor
public class ResourceController {
    private final ResourceService service;
}
```

## ベストプラクティス
- `@Service`、`@Repository`、`@Component`を適切に使用する
- `@RestControllerAdvice`でグローバル例外ハンドリングを実装する
- 入力検証にはBean Validationを使用する
- 適切なトランザクション境界を設定する

## テスト
- JUnit 5とMockitoでユニットテスト
- `@SpringBootTest`で統合テスト
- Springコンテキストテストには`@MockBean`を使用
- コードカバレッジ95%以上を維持

## セキュリティ
- Spring Securityを適切に実装する
- ステートレス認証にはJWTを使用する
- 必要に応じてメソッドレベルのセキュリティを適用する
- ログに機密情報を公開しない

## Null安全性
- NullAwayによる静的解析を有効化
- `@Nullable`と`@NonNull`アノテーションを適切に使用
- Optionalを返り値に活用
- Objects.requireNonNullで事前条件をチェック
- コンストラクタインジェクションで非null保証

## ビルドとデプロイ

### Gradleコマンド
- `./gradlew clean build` - クリーンビルド
- `./gradlew bootRun` - アプリケーション実行
- `./gradlew test` - テスト実行
- `./gradlew bootJar` - JAR作成
- `./gradlew dependencyUpdates` - 依存関係更新チェック

### Dockerサポート
- マルチステージビルド
- Rocky Linuxベースイメージ
- JVM最適化
- 非rootユーザー実行

### Rocky Linuxデプロイ
- systemdサービス設定
- Nginxリバースプロキシ
- Java 17 OpenJDK使用
