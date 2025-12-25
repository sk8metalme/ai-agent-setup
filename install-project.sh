#!/bin/bash

# このスクリプトは非推奨です
# プラグインシステムへ移行してください

set -e

# 色の定義
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⚠️  このスクリプトは非推奨です${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Claude Code の公式プラグインシステムへ移行してください。"
echo ""
echo -e "${GREEN}推奨インストール方法:${NC}"
echo ""
echo "  プロジェクトの .claude/CLAUDE.md を参照して、"
echo "  必要なプラグインをインストールしてください。"
echo ""
echo "  例:"
echo "  /plugin install team-standards@ai-agent-setup"
echo "  /plugin install development-toolkit@ai-agent-setup"
echo ""
echo -e "${GREEN}詳細情報:${NC}"
echo "  README.md を参照してください"
echo "  マイグレーションガイド: docs/migration-guide.md（準備中）"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

exit 1
