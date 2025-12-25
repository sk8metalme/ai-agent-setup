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
echo "  # 基本プラグイン（推奨）"
echo "  /plugin install team-standards@ai-agent-setup"
echo "  /plugin install development-toolkit@ai-agent-setup"
echo ""
echo "  # 言語別プラグイン（該当言語の場合のみ）"
echo "  /plugin install lang-java-spring@ai-agent-setup  # Java + Spring Boot"
echo "  /plugin install lang-python@ai-agent-setup       # Python + FastAPI"
echo "  /plugin install lang-php@ai-agent-setup          # PHP + Slim"
echo "  /plugin install lang-perl@ai-agent-setup         # Perl + Mojolicious"
echo ""
echo "  # その他の機能プラグイン（必要に応じて）"
echo "  /plugin install jujutsu-workflow@ai-agent-setup  # Jujutsu (jj) VCS"
echo "  /plugin install ci-cd-tools@ai-agent-setup       # CI/CD トラブルシューティング"
echo "  /plugin install design-review@ai-agent-setup     # UI/UX デザインレビュー"
echo "  /plugin install e2e-planning@ai-agent-setup      # E2Eファースト開発計画"
echo "  /plugin install oss-compliance@ai-agent-setup    # OSSライセンスチェック"
echo "  /plugin install version-audit@ai-agent-setup     # 技術スタックバージョン監査"
echo ""
echo -e "${GREEN}詳細情報:${NC}"
echo "  README.md を参照してください"
echo "  マイグレーションガイド: docs/migration-guide.md"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

exit 1
