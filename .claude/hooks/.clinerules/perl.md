
# Perl開発ルール

## Perl設定
- Perl 5.32以降を対象とする
- use strict と use warnings を常に使用
- use utf8 でUnicodeを適切に扱う
- モダンPerlのイディオムを使用する

## コードスタイル
```perl
#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use feature ':5.32';
```

## 命名規則
- パッケージ: PascalCase (MyApp::Controller)
- サブルーチン: snake_case (get_user_data)
- 変数: snake_case ($user_name)
- 定数: UPPER_SNAKE_CASE (MAX_SIZE)
- プライベートサブルーチン: _leading_underscore

## モダンPerlの機能
```perl
# シグネチャを使用
use feature 'signatures';
no warnings 'experimental::signatures';

sub calculate($x, $y) {
    return $x + $y;
}

# sayを使用
say "Hello, World!";

# stateで永続的な変数
sub counter {
    state $count = 0;
    return ++$count;
}
```

### オブジェクト指向 (Moo/Moose)
```perl
package MyClass;
use Moo;
use Types::Standard qw(Str Int);

has name => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);
```

## ベストプラクティス
- CPAN モジュールを活用する
- Perlbrew/plenv で環境を管理
- Carton で依存関係を管理
- perltidy でコードを整形
- perlcritic でコード品質をチェック

## エラーハンドリング
```perl
# Try::Tiny を使用
use Try::Tiny;

try {
    dangerous_operation();
} catch {
    warn "エラーが発生しました: $_";
};
```

## テスト
- Test::More でテストを書く
- Test::Exception で例外をテスト
- カバレッジ95%以上を維持
- prove でテストを実行
