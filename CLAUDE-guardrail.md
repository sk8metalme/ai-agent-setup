# Guardrail - 学習済みルール

このファイルは、会話履歴から自動的に学習した内容を蓄積します。

## プロジェクト仕様

- **2026-01-13** Claude Code プラグインシステムの配布リポジトリ（12個のプラグインを管理）
  - plugin.json と marketplace.json の**2箇所**に skills を定義する必要がある
  - plugin.json: プラグイン本体の定義
  - marketplace.json: マーケットプレイス経由でのスキル登録（これがないと "Unknown skill" エラー）

- **2026-01-13** guardrail-builderはグローバルSessionEndフック実装（v1.7.0）
  - `global/hooks/guardrail-builder-hook.sh` で定義
  - `install-global.sh` でデフォルト有効化
  - `~/.claude/settings.json` の hooks.SessionEnd に登録
  - 注: v1.8.0のプラグインhooks.jsonアプローチは試験後、グローバル配布に置き換え

## エラー対応

- **2026-01-13** Claude Code の skills パスは `/SKILL.md` を含めると「Unknown skill」エラーになる
  - 正しい形式: `"./skills/changelog"` （ディレクトリのみ）
  - 誤った形式: `"./skills/changelog/SKILL.md"` （ファイル名を含む）
  - 理由: Claude Code はディレクトリパスを受け取り、その中の SKILL.md を**自動的に探索**する設計
  - 参考: 公式 anthropics/skills リポジトリの形式に準拠
  - 影響: 12個の全プラグインで修正が必要だった（Phase 0）

- **2026-01-13** SKILL.md の `description` は1行形式で記述する必要がある
  - 正しい形式: `description: "1行で説明を書く"`
  - 誤った形式: `description: |` （複数行パイプは非対応）
  - 参考: [Issue #9817](https://github.com/anthropics/claude-code/issues/9817)

- **2026-01-13** plugin.json の `hooks` 設定は現在非対応
  - フックを使用するには ~/.claude/settings.json で手動登録が必須
  - plugin.json に hooks を書いても無視される
  - 参考: CLAUDE.md の「SessionEnd フックの設定方法」セクション

- **2026-01-13** marketplace.json と plugin.json の version は必ず同期すること
  - 不一致があるとマーケットプレイスに古いバージョンが表示される
  - ユーザー混乱の原因になる
  - チェックコマンド: CLAUDE.md の「marketplace.json と plugin.json の version 同期」参照

- **2026-01-13** プラグイン名変更時は6箇所すべてで一貫性を保つこと
  - ディレクトリ名、plugin.json、marketplace.json、CLAUDE.md、README.md、global/CLAUDE.md
  - 特に marketplace.json の更新忘れに注意（これがないとマーケットプレイスで検索できない）
  - 実例: deep-dive プラグインで dd → deep-dive に変更時に発生

- **2026-01-13** スキルStopフックはライフサイクルスコープの制約がある
  - スキルのフロントマター（SKILL.md）で定義したStopフックは、**スキルがアクティブな時のみ**実行される
  - 単にプラグインを読み込んだだけでは発火しない（スキルを明示的に呼び出す必要がある）
  - 完全自動化には**グローバルSessionEndフック**（`install-global.sh`）を使用する

- **2026-01-13** AppleScript内のhere-string (`<<<`) は変数展開が不安定
  - 問題: `claude --resume \"$SESSION_ID\" -p <<<'/guardrail-builder'` がAppleScript do script内で動作しない
  - 原因: here-stringのエスケープが複雑になり、変数展開が失敗
  - 解決: `echo '/guardrail-builder' | claude --resume \"$SESSION_ID\" -p` を使用（標準パイプ）

## コーディング規約

- **2026-01-13** プラグイン関連ファイルを修正したら必ずバージョンを更新する
  - 対象: plugin.json, commands/, agents/, skills/, hooks/
  - Semantic Versioning: MAJOR (破壊的変更) / MINOR (新機能) / PATCH (バグ修正)
  - Skills パス修正は PATCH (1.5.6 → 1.5.7)
  - guardrail-builder 追加は MINOR (1.5.7 → 1.6.0)

- **2026-01-13** main/master ブランチへの直接 push/commit は禁止
  - 作業は feature/, bugfix/, hotfix/ ブランチで行う
  - force push は厳禁

- **2026-01-13** プラグインhooks.jsonの構造（Phase 2で試験、v1.8.0→v1.7.0で削除）
  - `plugins/<name>/hooks/hooks.json` にフック定義を配置
  - `plugin.json` に `"hooks": "./hooks/hooks.json"` を追加
  - `${CLAUDE_PLUGIN_ROOT}` でプラグインルートディレクトリを参照
  - 注: グローバル配布アプローチ（`~/.claude/hooks/`）に置き換えられた

## Tips

- **2026-01-13** skills パスに SKILL.md が含まれていないか確認するコマンド
  - `jq -r '.skills[]' plugins/*/.claude-plugin/plugin.json | grep -i 'SKILL\.md'`
  - 検出されなければ OK

- **2026-01-13** 全プラグインの version 一致確認コマンド
  - CLAUDE.md の「marketplace.json と plugin.json の version 同期」セクション参照
  - plugin.json と marketplace.json の version が一致しているかチェック

- **2026-01-13** SessionEnd フックでの無限ループ対策
  - フック内で claude コマンドを実行すると再度フックが発火する
  - 環境変数でガード: `if [ "${MY_HOOK_RUNNING:-}" = "1" ]; then exit 0; fi`
  - 実例: guardrail-builder-hook.sh の `GUARDRAIL_BUILDER_RUNNING` 変数

- **2026-01-13** プロジェクトルート検出の4段階フォールバック
  - 1) CLAUDE_PROJECT_DIR 環境変数
  - 2) ~/.claude/settings.json の project_dir
  - 3) git root
  - 4) pwd（最終フォールバック）
  - 参考: guardrail-builder-hook.sh の実装

- **2026-01-13** 公式 anthropics/skills リポジトリを参考にする
  - Skills の正しいパス形式、ディレクトリ構造を確認できる
  - URL: https://github.com/anthropics/skills

- **2026-01-13** `claude --plugin-dir` でローカルプラグインを直接読み込んでテスト可能
  - マーケットプレイス経由不要、開発中の変更を即座にテスト
  - プラグインキャッシュを気にせず最新版を読み込める
  - 例: `claude --plugin-dir ./plugins/development-toolkit`
  - 開発ワークフローとして理想的

- **2026-01-13** SessionEnd vs Stop フックの違い
  - SessionEnd: セッション終了後に発火、常時有効（プラグインインストール時から）、会話コンテキストへのアクセス対象外
  - Stop: 応答終了時に発火、スキルライフサイクルにスコープ、応答停止制御用途
  - 用途: SessionEnd＝クリーンアップ・ロギング用途、Stop＝停止制御用途（スキル実行が前提）

---

最終更新: 2026-01-13
このファイルは `/guardrail-builder` スキルにより自動更新されます。
