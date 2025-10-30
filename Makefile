# Simple helpers. Use tabs for commands.
SHELL := /bin/bash

.PHONY: up down logs restart diag backup arch

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f zabbix-server zabbix-web-service postgres

restart:
	docker compose restart

diag:
	bash scripts/zbxdiag.sh || true

backup:
	bash scripts/backup.sh || true

# Render architecture SVG from Graphviz DOT
arch:
	dot -Tsvg docs/zabbix_architecture_public.dot -o docs/zabbix_architecture_public.svg