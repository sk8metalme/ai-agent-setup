# SessionEnd フックの手動セットアップ

このフックは **macOS 専用** です。

## 推奨方法

`install-global.sh` を使用してください：

```bash
cd /path/to/ai-agent-setup
./install-global.sh
```

## 手動セットアップ（オプション）

1. フックスクリプトをコピー:
   ```bash
   cp ./hooks/guardrail-builder-hook.sh ~/.claude/hooks/
   ```

2. 実行権限を付与:
   ```bash
   chmod +x ~/.claude/hooks/guardrail-builder-hook.sh
   ```

3. settings.json に登録:
   ```bash
   # ~/.claude/settings.json の hooks.SessionEnd に追加
   # 詳細は global/settings.template.json を参照
   ```

## 動作確認

```bash
# フックが設定されているか確認
cat ~/.claude/settings.json | jq '.hooks.SessionEnd'

# フックスクリプトが存在するか確認
ls -la ~/.claude/hooks/guardrail-builder-hook.sh
```
