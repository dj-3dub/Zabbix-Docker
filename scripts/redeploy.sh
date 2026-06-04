#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Safety: ensure we're in the zabbix project
test -f docker-compose.yml || { echo "docker-compose.yml not found"; exit 1; }

echo "==> Updating stack (compose already updated to remove 'version:' and unconfine agent AppArmor)..."

# Restart only agent first (fast path); if not running yet, bring all up
if docker compose ps --services --status running | grep -q '^agent$'; then
  docker compose rm -sf zbx-agent >/dev/null 2>&1 || true
  docker compose up -d zbx-agent
else
  docker compose up -d
fi

echo "==> Current status:"
docker compose ps

echo
echo "==> Recent agent logs:"
docker logs --tail=100 zbx-agent || true

echo
echo "Done. Open the UI at: http://$(hostname -I | awk '{print $1}'):${WEB_PORT:-8180}"
echo "Default login: Admin / zabbix"
