#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " Zabbix Docker Diagnostics"
echo "======================================"
echo ""

echo "Timestamp:"
date
echo ""

echo "Docker version:"
docker --version || true
echo ""

echo "Docker Compose version:"
docker compose version || true
echo ""

echo "Compose validation:"
if docker compose config >/dev/null 2>&1; then
  echo "OK: docker-compose.yml is valid"
else
  echo "ERROR: docker-compose.yml validation failed"
fi
echo ""

echo "Container status:"
docker compose ps || true
echo ""

echo "Running containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || true
echo ""

echo "Docker networks:"
docker network ls || true
echo ""

echo "Docker volumes:"
docker volume ls | grep zabbix || true
echo ""

echo "Port checks:"
for port in 8180 10051; do
  if ss -tulpn | grep -q ":${port} "; then
    echo "OK: Port ${port} is listening"
  else
    echo "WARN: Port ${port} is not listening"
  fi
done
echo ""

echo "Database readiness:"
if docker ps --format '{{.Names}}' | grep -q '^zbx-db$'; then
  docker exec zbx-db pg_isready || true
else
  echo "WARN: zbx-db is not running"
fi
echo ""

echo "Recent database logs:"
docker compose logs --tail=20 db || true
echo ""

echo "Recent server logs:"
docker compose logs --tail=20 server || true
echo ""

echo "Recent web logs:"
docker compose logs --tail=20 web || true
echo ""

echo "Recent agent logs:"
docker compose logs --tail=20 agent || true
echo ""

echo "Resource usage:"
docker stats --no-stream || true
echo ""

echo "Diagnostics complete."
