<p align=\"center\">
<img src="docs/images/zabbix_logo_500x131.png" alt="Zabbix Logo" width="220"/>
</p>

# Zabbix‑Docker — Production‑Ready Monitoring Stack 

A production-ready, containerized Zabbix monitoring stack built to showcase platform engineering and observability best practices.

---

## ✨ Highlights

- **Clean architecture**: Zabbix Server, Web, DB, Proxy (optional), Agent
- **Reproducible**: Docker Compose with env‑driven config and persistent volumes
- **Security‑minded**: TLS via Caddy/Traefik overlay, secrets outside Git, least privilege
- **Identity‑aware**: Optional **Authentik** SSO via **SAML** or **forward‑auth**
- **Portfolio‑grade**: Clear docs, scripts, and an operations checklist

---

## 🧭 Project Goals

Showcase the end‑to‑end journey of standing up an internal monitoring platform:
- Network/host/service visibility with Zabbix templates and agents
- Healthy container orchestration and stateful services on Docker
- Secure exposure with TLS and SSO (when enabled)
- Practical operations (backup/restore, diagnostics, troubleshooting)

---

## 🏗️ Architecture

See the dedicated doc and diagram:
<p align="center">
  <img src="./docs/zabbix_architecture_public.svg" alt="Zabbix Docker Architecture" width="100%">
  <sub>Having trouble viewing the SVG? View the PNG version <a href="./docs/zabbix_architecture_public.png">here</a>.</sub>
</p>

The architecture illustrates the full Zabbix monitoring stack running in Docker — including
Zabbix Server, Web Frontend, PostgreSQL, and optional integrations for Authentik SSO and
Caddy/Traefik for HTTPS termination.

---

## 🧰 Tech Stack

- **Zabbix** (Server, Web, Proxy, Agent)
- **PostgreSQL** (primary datastore)
- **Docker Compose v2**
- **Caddy** or **Traefik** *(optional)* for TLS + pretty URL (`https://monitor.lab`)
- **Authentik** *(optional)* for SSO (SAML or forward‑auth patterns)

---

## ⚙️ Prerequisites

- Linux host with Docker Engine 24+ and Docker Compose v2
- Local DNS/hosts entry for `monitor.lab` → Docker host IP
- (Optional) TLS certificates or ACME DNS for your `.lab` domain
- `git` and Graphviz (`dot`) if you want to render the diagram

---

## 🚀 Quick Start

```bash
git clone https://github.com/dj-3dub/Zabbix-Docker.git
cd Zabbix-Docker

# Copy and tailor environment files
cp .env.example .env
# edit DOMAIN=monitor.lab and strong passwords

# Bring up the base stack (no proxy, direct ports)
docker compose up -d

# Visit the UI on the published port or behind your proxy of choice
# Optional: enable Caddy/Traefik overlay compose for TLS + pretty URL
```

## 🔐 Optional: TLS + Reverse Proxy

- **Caddy overlay**: automatic HTTPS, minimal config
- **Traefik overlay**: Docker label routing, middlewares, mTLS, dashboards

---

## 🔑 Optional: Authentik SSO Integration

This deployment supports integration with **Authentik** as a centralized identity provider, enabling secure single sign-on (SSO) for the Zabbix web interface.

Two integration patterns are supported:

- **SAML-based authentication (recommended):**  
  Zabbix acts as a SAML Service Provider (SP) and Authentik as the Identity Provider (IdP).  
  This approach allows seamless user federation, centralized policy enforcement, and single sign-on without requiring a reverse proxy.  

- **Forward-auth via reverse proxy (Caddy or Traefik):**  
  Authentik can also protect the Zabbix frontend through a forward-auth middleware, authenticating requests at the proxy layer and passing verified identity headers to Zabbix’s HTTP authentication module.  

Both methods maintain compatibility with a local administrative account for break-glass access and support standard SSO attributes such as email, given name, and group membership.

See **docs/ARCHITECTURE.md** for diagrams and steps.

---

## 🧪 Diagnostics

- `scripts/zbxdiag.sh` — quick API sanity: login/auth, version, host lookup
- Container healthchecks for Server/Web/DB
- Suggested item/triggers for self‑monitoring Zabbix itself

---

## 🗃️ Backup & Restore

- Nightly `pg_dump` to `/backups` via helper script
- Store off‑box (NAS/S3/Restic). To restore, stop Zabbix Server, restore DB, start stack

---

## 🔐 Security Notes

- Enforce HTTPS when exposed; restrict HTTP
- Store secrets in `.env` / Docker secrets; **never** commit real credentials
- Limit container privileges and networks
- Set strong DB/Zabbix passwords and rotate routinely

---

## 🛣️ Roadmap

- Grafana dashboards via Zabbix data source (read‑only)
- CI/CD: compose lint + shellcheck + smoke API test
- Terraform module to provision host + DNS
- HA notes for Zabbix Server and DB

---

## 🧠 What I Learned

Building this project reinforced several key areas of my platform engineering and DevOps skill set:

- **End-to-end observability design:** Implemented a complete monitoring stack — from agent data collection to dashboards and alerting — mirroring real-world enterprise environments.  
- **Secure infrastructure practices:** Strengthened my understanding of TLS termination, container isolation, and least-privilege configurations in multi-service Docker environments.  
- **Identity and access integration:** Explored how SAML and forward-auth patterns connect application authentication to centralized identity providers like Authentik.  
- **Infrastructure-as-Code discipline:** Structured the project with reproducible Compose files, environment templates, and Makefile targets for consistent deployments.  
- **Documentation and presentation:** Learned to communicate complex architectures clearly through diagrams, structured READMEs, and professional repo organization.  

Each of these lessons translates directly into the way I approach designing, securing, and automating production-ready environments.

---

## 👤 About

Built by **Tim Heverin** (dj‑3dub).  
- GitHub: https://github.com/dj-3dub  
- LinkedIn: https://www.linkedin.com/in/tim-heverin/

MIT License.
