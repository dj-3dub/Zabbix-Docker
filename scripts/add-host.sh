#!/usr/bin/env bash
set -euo pipefail

# Defaults (override with env or flags)
ZBX_URL="${ZBX_URL:-http://192.168.2.51:8180/api_jsonrpc.php}"
ZBX_USER="${ZBX_USER:-Admin}"
ZBX_PASS="${ZBX_PASS:-zabbix}"
ZBX_GROUP="Linux servers"
ZBX_TEMPLATE="Linux by Zabbix agent"

usage() {
  cat <<EOF
Usage: $(basename "$0") <hostname> [ip] [--group "<group name>"] [--template "<template name>"]
Env overrides:
  ZBX_URL    (default: $ZBX_URL)
  ZBX_USER   (default: $ZBX_USER)
  ZBX_PASS   (default: ****)

Examples:
  $(basename "$0") ubuntu-workstation 192.168.2.30
  ZBX_USER=Admin ZBX_PASS=zabbix $(basename "$0") myhost 10.0.0.5 --group "Linux servers"
EOF
}

# Args
[[ ${1:-} == "-h" || ${1:-} == "--help" ]] && { usage; exit 0; }
HOSTNAME="${1:-}"
HOSTIP="${2:-}"

shift $(( $# > 0 ? 1 : 0 ))
[[ -n "${HOSTIP:-}" ]] && shift || true

# Parse optional flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --group)    ZBX_GROUP="${2:-}"; shift 2 ;;
    --template) ZBX_TEMPLATE="${2:-}"; shift 2 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

# Basic validation
if [[ -z "$HOSTNAME" ]]; then
  echo "Error: hostname is required."; usage; exit 1
fi
if [[ -z "${HOSTIP:-}" ]]; then
  # auto-detect primary IP on this machine
  HOSTIP="$(hostname -I | awk '{print $1}')"
  [[ -z "$HOSTIP" ]] && { echo "Error: Unable to auto-detect IP. Pass it explicitly."; exit 1; }
fi

# Dependencies
for bin in curl jq; do
  command -v "$bin" >/dev/null 2>&1 || { echo "Missing dependency: $bin (try: sudo apt install -y $bin)"; exit 1; }
done

json() { jq -c "." <<<"$*"; }  # compacts JSON safely

echo "==> Zabbix URL: $ZBX_URL"
echo "==> Hostname  : $HOSTNAME"
echo "==> IP        : $HOSTIP"
echo "==> Group     : $ZBX_GROUP"
echo "==> Template  : $ZBX_TEMPLATE"

# 1) Authenticate
AUTH_TOKEN="$(curl -s -H "Content-Type: application/json-rpc" -X POST \
  -d "$(json \
    "{\"jsonrpc\":\"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\"$ZBX_USER\",\"password\":\"$ZBX_PASS\"},\"id\":1}")" \
  "$ZBX_URL" | jq -r '.result')"

if [[ -z "$AUTH_TOKEN" || "$AUTH_TOKEN" == "null" ]]; then
  echo "Error: Failed to authenticate. Check ZBX_URL/ZBX_USER/ZBX_PASS." >&2
  exit 1
fi

# Helper to call API with auth
api_call() {
  local method="$1"; shift
  local params="$1"; shift
  curl -s -H "Content-Type: application/json-rpc" -X POST \
    -d "$(json "{\"jsonrpc\":\"2.0\",\"method\":\"$method\",\"params\":$params,\"auth\":\"$AUTH_TOKEN\",\"id\":1}")" \
    "$ZBX_URL"
}

# 2) Ensure host group exists; get groupid
GROUPID="$(api_call "hostgroup.get" "$(json "{\"filter\":{\"name\":[\"$ZBX_GROUP\"]}}")" | jq -r '.result[0].groupid')"
if [[ -z "$GROUPID" || "$GROUPID" == "null" ]]; then
  echo "==> Host group not found, creating: $ZBX_GROUP"
  GROUPID="$(api_call "hostgroup.create" "$(json "{\"name\":\"$ZBX_GROUP\"}")" | jq -r '.result.groupids[0]')"
fi
[[ -z "$GROUPID" || "$GROUPID" == "null" ]] && { echo "Error: Could not obtain groupid."; exit 1; }

# 3) Find template id (try exact host name, then search by name)
TEMPLATEID="$(api_call "template.get" "$(json "{\"filter\":{\"host\":[\"$ZBX_TEMPLATE\"]}}")" | jq -r '.result[0].templateid')"
if [[ -z "$TEMPLATEID" || "$TEMPLATEID" == "null" ]]; then
  TEMPLATEID="$(api_call "template.get" "$(json "{\"search\":{\"name\":\"$ZBX_TEMPLATE\"},\"limit\":1}")" | jq -r '.result[0].templateid')"
fi
[[ -z "$TEMPLATEID" || "$TEMPLATEID" == "null" ]] && { echo "Error: Could not find template \"$ZBX_TEMPLATE\"."; exit 1; }

# 4) Create host (idempotent-ish: if exists, we warn and exit)
EXISTING_ID="$(api_call "host.get" "$(json "{\"filter\":{\"host\":[\"$HOSTNAME\"]}}")" | jq -r '.result[0].hostid')"
if [[ -n "$EXISTING_ID" && "$EXISTING_ID" != "null" ]]; then
  echo "==> Host \"$HOSTNAME\" already exists (id: $EXISTING_ID). Updating interface & templates…"
  # Ensure an agent interface exists with current IP
  INTERFACE_ID="$(api_call "hostinterface.get" "$(json "{\"hostids\":[\"$EXISTING_ID\"],\"filter\":{\"type\":1}}")" | jq -r '.result[0].interfaceid')"
  if [[ -n "$INTERFACE_ID" && "$INTERFACE_ID" != "null" ]]; then
    api_call "hostinterface.update" "$(json "{\"interfaceid\":\"$INTERFACE_ID\",\"ip\":\"$HOSTIP\",\"dns\":\"\",\"port\":\"10050\",\"main\":1,\"useip\":1}")" >/dev/null
  else
    api_call "hostinterface.create" "$(json "{\"hostid\":\"$EXISTING_ID\",\"type\":1,\"main\":1,\"useip\":1,\"ip\":\"$HOSTIP\",\"dns\":\"\",\"port\":\"10050\"}")" >/dev/null
  fi
  # Link template if not already linked
  api_call "template.massadd" "$(json "{\"templates\":[{\"templateid\":\"$TEMPLATEID\"}],\"hosts\":[{\"hostid\":\"$EXISTING_ID\"}]}")" >/dev/null
  echo "==> Updated host \"$HOSTNAME\" (id: $EXISTING_ID). Done."
  exit 0
fi

CREATE_PAYLOAD="$(json "{
  \"host\": \"$HOSTNAME\",
  \"interfaces\": [{
    \"type\": 1,
    \"main\": 1,
    \"useip\": 1,
    \"ip\": \"$HOSTIP\",
    \"dns\": \"\",
    \"port\": \"10050\"
  }],
  \"groups\": [{\"groupid\": \"$GROUPID\"}],
  \"templates\": [{\"templateid\": \"$TEMPLATEID\"}]
}")"

RESP="$(api_call "host.create" "$CREATE_PAYLOAD")"
NEW_ID="$(jq -r '.result.hostids[0] // empty' <<<"$RESP")"

if [[ -n "$NEW_ID" ]]; then
  echo "==> Host created: \"$HOSTNAME\" (id: $NEW_ID)"
else
  echo "API error:"
  echo "$RESP" | jq
  exit 1
fi
