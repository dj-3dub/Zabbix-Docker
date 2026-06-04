#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="backups"
TIMESTAMP="$(date +%Y-%m-%d_%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/zabbix_backup_${TIMESTAMP}.sql"

if [[ -f ".env" ]]; then
  ENV_FILE=".env"
elif [[ -f ".env.example" ]]; then
  ENV_FILE=".env.example"
  echo "WARNING: .env not found, using .env.example"
else
  echo "ERROR: No environment file found."
  exit 1
fi

set -a
# shellcheck source=/dev/null
source "${ENV_FILE}"
set +a

mkdir -p "${BACKUP_DIR}"

echo "Starting Zabbix database backup..."
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

docker exec zbx-db pg_dump \
  -U "${DB_USER}" \
  -d "${DB_NAME}" \
  > "${BACKUP_FILE}"

if [[ ! -s "${BACKUP_FILE}" ]]; then
  echo "ERROR: Backup file was not created or is empty."
  exit 1
fi

chmod 600 "${BACKUP_FILE}"

echo "Backup completed successfully."
echo "Location: ${BACKUP_FILE}"
echo "Size: $(du -h "${BACKUP_FILE}" | awk '{print $1}')"
