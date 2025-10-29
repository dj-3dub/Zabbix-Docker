<p align="center">
  <img src="https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/ps_black_64.svg" width="90" alt="PowerShell Logo"/>
</p>

# Zabbix Test Stack (Docker)

Spin up a disposable Zabbix environment (TimescaleDB + Zabbix Server + Web + Agent2) to kick the tires on your existing Docker host. Defaults avoid collisions on busy homelab boxes.

## Quick start

```bash
# 1) Copy this folder to your Docker host
cd zabbix-test-scaffold

# 2) (Optional) adjust .env (ports, passwords)
nano .env

# 3) Launch
docker compose up -d

# 4) Open the UI
# http://<host-ip>:8180  (user: Admin  pass: zabbix)
```

## Make targets (optional)

```bash
make up       # docker compose up -d
make down     # docker compose down -v
make logs     # tail logs
make ps       # list containers
make status   # check key ports in use
make clean    # prune dangling images/volumes (careful)
```

## Ports

- **Web UI:** `${WEB_PORT:-8180}` → container 8080  
- **Server:** `${ZBX_PORT:-10051}` → container 10051

Adjust these in `.env` if your host already uses them.

## Caddy snippet (optional)

```
zabbix.lab.pizza {
  encode zstd gzip
  reverse_proxy 127.0.0.1:${WEB_PORT}
}
```

## Tear down

```bash
docker compose down -v
```

## Notes

- This is **not** tuned for production. It’s intentionally lightweight.
- If you plan to keep data between runs, remove the `-v` flag in `down` to preserve volumes.
- TimescaleDB is used for better trends/compression if you later keep this around.
```

