#!/usr/bin/env bash
set -euo pipefail

echo "== Listening TCP/UDP Ports =="
sudo ss -tuln | grep LISTEN || true

echo
echo "== Docker Port Bindings =="
docker ps --format 'table {{.Names}}\t{{.Ports}}'
