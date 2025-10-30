# Zabbix‑Docker Architecture

This document explains how the stack is composed, how traffic flows, and where optional components (reverse proxy and SSO) fit in. The project uses a `.lab` domain to model an internal environment (e.g., `monitor.lab`).

## High‑Level Diagram

The Graphviz source lives at `docs/zabbix_architecture_public.dot`. Render it to SVG/PNG with `dot` (see below).

### Components

- **Zabbix Server** — Core monitoring engine for items, triggers, events
- **Zabbix Web** — PHP/Nginx frontend for UI and API
- **PostgreSQL** — Primary datastore for configuration and history
- **Zabbix Proxy** *(optional)* — Decouples remote sites/segments and buffers data
- **Zabbix Agent(s)** — Installed on monitored hosts and optionally on the Docker host
- **Reverse Proxy** *(optional: Caddy or Traefik)* — TLS termination, pretty URL
- **Authentik** *(optional)* — Identity provider for SSO via SAML or forward‑auth

## Traffic Flow (at a glance)

1. User → `https://monitor.lab` (via Caddy/Traefik) → Zabbix Web
2. Zabbix Web ↔ PostgreSQL for config/history
3. Zabbix Server ↔ PostgreSQL
4. Zabbix Server ↔ Agents/Proxies for metrics and availability
5. (SSO) Zabbix Web ↔ Authentik (SAML) or Proxy ↔ Authentik (forward‑auth)

## SSO Patterns

**SAML (recommended)**  
- Authentik is the IdP; Zabbix is the SP.  
- ACS: `https://monitor.lab/index_sso.php`  
- Map attributes: `mail`, `givenName`, `sn`, `groups` (optional)  
- Keep a break‑glass local Admin account.

**Forward‑Auth (proxy)**  
- Proxy enforces auth with Authentik outpost and forwards identity headers.  
- Zabbix uses HTTP auth and trusts the proxy headers.

## Render the Diagram

```bash
# SVG
dot -Tsvg docs/zabbix_architecture_public.dot -o docs/zabbix_architecture_public.svg

# PNG
dot -Tpng docs/zabbix_architecture_public.dot -o docs/zabbix_architecture_public.png
```