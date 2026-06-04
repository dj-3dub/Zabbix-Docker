# Zabbix Docker Lab - Operational Helper Makefile
# Use tabs, not spaces, for command indentation.

SHELL := /bin/bash

COMPOSE := docker compose
BACKUP_DIR := backups
ARCH_DOT := docs/architecture.dot
ARCH_SVG := docs/architecture.svg

.PHONY: help up down restart logs status health validate pull update \
	backup restore backup-list clean diag report security arch

help:
	@echo "Zabbix Docker Lab Commands"
	@echo ""
	@echo "  make up            Start the Zabbix stack"
	@echo "  make down          Stop the Zabbix stack"
	@echo "  make restart       Restart all services"
	@echo "  make logs          Follow logs for db, server, web, and agent"
	@echo "  make status        Show container status"
	@echo "  make health        Show container status and resource usage"
	@echo "  make validate      Validate docker-compose.yml"
	@echo "  make pull          Pull updated images"
	@echo "  make update        Pull images and recreate containers"
	@echo "  make backup        Run database backup script"
	@echo "  make restore       Restore database backup: make restore FILE=backups/file.sql"
	@echo "  make backup-list   List available backups"
	@echo "  make diag          Run Zabbix diagnostic script"
	@echo "  make report        Show operational report"
	@echo "  make security      Scan images with Trivy if installed"
	@echo "  make arch          Render architecture diagram"
	@echo "  make clean         Stop stack and remove volumes"

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart

logs:
	$(COMPOSE) logs -f db server web agent

status:
	$(COMPOSE) ps

health:
	@echo "Container status:"
	@$(COMPOSE) ps
	@echo ""
	@echo "Resource usage:"
	@docker stats --no-stream

validate:
	@$(COMPOSE) config >/dev/null
	@echo "Compose file is valid."

pull:
	$(COMPOSE) pull

update: pull
	$(COMPOSE) up -d
	$(COMPOSE) ps

backup:
	@mkdir -p $(BACKUP_DIR)
	@if [[ -x scripts/backup.sh ]]; then \
		bash scripts/backup.sh; \
	else \
		echo "scripts/backup.sh not found or not executable."; \
		exit 1; \
	fi

restore:
	@if [[ -x scripts/restore.sh ]]; then \
		bash scripts/restore.sh $(FILE); \
	else \
		echo "scripts/restore.sh not found or not executable."; \
		exit 1; \
	fi

backup-list:
	@mkdir -p $(BACKUP_DIR)
	@ls -lh $(BACKUP_DIR) || true

diag:
	@if [[ -x scripts/zbxdiag.sh ]]; then \
		bash scripts/zbxdiag.sh; \
	else \
		echo "scripts/zbxdiag.sh not found or not executable."; \
		exit 1; \
	fi

report:
	@echo "=== Docker Compose Status ==="
	@$(COMPOSE) ps
	@echo ""
	@echo "=== Docker Networks ==="
	@docker network ls
	@echo ""
	@echo "=== Docker Volumes ==="
	@docker volume ls
	@echo ""
	@echo "=== Resource Usage ==="
	@docker stats --no-stream

security:
	@if command -v trivy >/dev/null 2>&1; then \
		trivy image zabbix/zabbix-server-pgsql:alpine-7.4.11; \
		trivy image zabbix/zabbix-web-nginx-pgsql:alpine-7.4.11; \
		trivy image zabbix/zabbix-agent2:alpine-7.4.11; \
		trivy image timescale/timescaledb:2.17.2-pg16; \
	else \
		echo "Trivy is not installed."; \
		echo "Install with: sudo apt install trivy -y"; \
	fi

arch:
	@if command -v dot >/dev/null 2>&1; then \
		if [[ -f "$(ARCH_DOT)" ]]; then \
			dot -Tsvg "$(ARCH_DOT)" -o "$(ARCH_SVG)"; \
			echo "Architecture diagram rendered to $(ARCH_SVG)"; \
		else \
			echo "$(ARCH_DOT) not found."; \
			exit 1; \
		fi \
	else \
		echo "Graphviz is not installed."; \
		echo "Install with: sudo apt install graphviz -y"; \
	fi

clean:
	@echo "WARNING: This will stop the stack and remove volumes."
	@read -p "Continue? [y/N] " confirm; \
	if [[ "$$confirm" == "y" || "$$confirm" == "Y" ]]; then \
		$(COMPOSE) down -v; \
	else \
		echo "Aborted."; \
	fi
