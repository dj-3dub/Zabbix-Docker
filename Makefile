SHELL := /bin/bash

.PHONY: up down logs ps status clean portcheck

up:
	docker compose up -d

down:
	docker compose down -v

logs:
	docker compose logs -f --tail=100

ps:
	docker compose ps

status: portcheck ps

portcheck:
	@./scripts/check-ports.sh || true

clean:
	docker system prune -f
	docker volume prune -f
