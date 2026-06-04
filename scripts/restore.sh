#!/usr/bin/env bash
set -euo pipefail

if [[ -f ".env" ]]; then
  ENV_FILE=".env"
elif [[ -f ".env.example" ]]; then
  ENV_FILE=".env.example"
  echo "WARNING: .env not found, using .env.example"
else
  echo "ERROR: No environment file found."
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "ERROR: No backup file provided."
  echo ""
  echo "Usage:"
  echo "  make restore FILE=backups/<backup-file>.sql"
  echo ""
  echo "Available backups:"
  ls -lh backups/ 2>/dev/null || true
  exit 1
fi

BACKUP_FILE="$1"

if [[ ! -f "${BACKUP_FILE}" ]]; then
  echo "ERROR: Backup file not found: ${BACKUP_FILE}"
  exit 1
fi

if [[ ! -s "${BACKUP_FILE}" ]]; then
  echo "ERROR: Backup file is empty: ${BACKUP_FILE}"
  exit 1
fi

set -a
# shellcheck source=/dev/null
source "${ENV_FILE}"
set +a

echo "Starting Zabbix database restore..."
echo "Backup file: ${BACKUP_FILE}"

if ! docker ps --format '{{.Names}}' | grep -q '^zbx-db$'; then
  echo "ERROR: zbx-db container is not running."
  echo ""
  echo "Start the stack first:"
  echo "  make up"
  echo ""
  echo "Then verify:"
  echo "  make status"
  exit 1
fi

echo ""
echo "WARNING: This will restore data into the Zabbix database."
echo "Database: ${DB_NAME}"
echo "Container: zbx-db"
echo ""
read -r -p "Continue? [y/N] " CONFIRM

if [[ "${CONFIRM}" != "y" && "${CONFIRM}" != "Y" ]]; then
  echo "Restore cancelled."
  exit 0
fi

echo "Stopping Zabbix server and web containers..."
docker compose stop server web agent || true

echo "Dropping active database connections..."
docker exec -i zbx-db psql \
  -U "${DB_USER}" \
  -d postgres \
  -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${DB_NAME}' AND pid <> pg_backend_pid();" >/dev/null

echo "Recreating database..."
docker exec -i zbx-db psql \
  -U "${DB_USER}" \
  -d postgres \
  -c "DROP DATABASE IF EXISTS ${DB_NAME};"

docker exec -i zbx-db psql \
  -U "${DB_USER}" \
  -d postgres \
  -c "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};"

echo "Restoring backup..."
docker exec -i zbx-db psql \
  -U "${DB_USER}" \
  -d "${DB_NAME}" < "${BACKUP_FILE}"

echo "Starting Zabbix services..."
docker compose start server web agent

echo ""
echo "Restore completed successfully."
echo "Run the following to verify:"
echo "  make status"
echo "  make logs"
