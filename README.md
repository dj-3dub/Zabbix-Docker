<p align="center">
  <img src="docs/images/zabbix_logo_500x131.png" alt="Zabbix Logo" width="220"/>
</p>

# Zabbix-Docker

### Production-Style Monitoring Stack

An enterprise-inspired monitoring platform built with Zabbix, PostgreSQL/TimescaleDB, and Docker Compose to demonstrate observability, infrastructure automation, security hardening, operational readiness, and identity integration.

---

## ✨ Highlights

- Clean architecture: Zabbix Server, Web Frontend, PostgreSQL, and Agent
- Reproducible deployments with Docker Compose and persistent storage
- Security-minded configuration and least-privilege controls
- Optional Authentik SSO integration
- Operational tooling for backup, restore, and diagnostics
- Portfolio-grade documentation and architecture diagrams

---

## 🚀 Project Features

- Docker Compose-based multi-container architecture
- PostgreSQL/TimescaleDB-backed monitoring platform
- Automated backup and restore tooling
- Operational diagnostics and health validation
- Security hardening using least-privilege principles
- GitHub Actions validation pipeline
- Architecture documentation and operational runbooks
- Identity integration patterns using Authentik

---

## 🧭 Project Goals

This project demonstrates how to design, deploy, operate, and secure a self-contained observability platform using modern infrastructure tooling.

- Network, host, and service visibility using Zabbix templates and agents
- Stateful containerized services using Docker Compose
- Secure service exposure through TLS and identity integration
- Operational readiness through diagnostics, backup, and recovery procedures
- Infrastructure documentation and repeatable deployment workflows

---

## 🏗️ Architecture

See the dedicated architecture documentation and diagrams.

- Zabbix Server
- Zabbix Web Frontend
- PostgreSQL / TimescaleDB
- Zabbix Agent
- Optional Authentik SSO
- Optional Caddy / Traefik reverse proxy for HTTPS

---

## 📚 Documentation

- Architecture Guide (`docs/ARCHITECTURE.md`)
- Operations Runbook (`docs/RUNBOOK.md`)
- Security Guide (`docs/SECURITY.md`)
- Backup & Restore Guide (`docs/BACKUP_RESTORE.md`)

---

## 🧰 Tech Stack

### Core Components

- Zabbix Server
- Zabbix Web Frontend
- Zabbix Agent 2
- PostgreSQL / TimescaleDB

### Platform Components

- Docker Engine
- Docker Compose v2
- GitHub Actions

### Optional Integrations

- Authentik
- Caddy
- Traefik

---

## ⚙️ Prerequisites

- Linux host running Docker Engine 24+
- Docker Compose v2
- Git
- Graphviz (optional)

---

## 🚀 Quick Start

```bash
git clone https://github.com/dj-3dub/Zabbix-Docker.git
cd Zabbix-Docker
cp .env.example .env
docker compose up -d
```

---

## ⚙️ Operations

```bash
make validate
make up
make down
make status
make logs
make diag
make backup
make restore FILE=backups/<backup-file>.sql
```

---

## 🔐 Optional TLS and Reverse Proxy

Supports Caddy or Traefik for HTTPS termination and secure exposure.

---

## 🔑 Optional Authentik SSO Integration

Supports SAML-based authentication and forward-auth patterns for centralized identity management.

---

## 🧪 Diagnostics

Run:

```bash
make diag
```

Includes:

- Container health validation
- Service status checks
- Network inspection
- Database readiness validation
- Log collection
- Resource utilization reporting

---

## 🗃️ Backup & Restore

Backups are stored in:

```text
backups/
```

Create:

```bash
make backup
```

Restore:

```bash
make restore FILE=backups/<backup-file>.sql
```

---

## 🔐 Security Notes

- Externalized configuration via environment variables
- Secrets excluded from source control
- Least-privilege container settings
- Version-pinned images
- Isolated Docker networking

---

## 🛣️ Roadmap

- Grafana integration
- Automated vulnerability scanning
- Compose linting and smoke testing
- Terraform deployment automation
- High availability reference architecture

---

## 🧠 What I Learned

- End-to-end observability design
- Secure infrastructure practices
- Identity integration patterns
- Infrastructure-as-Code discipline
- Operational readiness and recovery planning
- Technical documentation and architecture communication

Each of these lessons translates directly into the way I approach designing, securing, monitoring, and automating enterprise infrastructure environments.

---

## 👤 About

Built by **Tim Heverin**

GitHub: https://github.com/dj-3dub

LinkedIn: https://www.linkedin.com/in/tim-heverin/

---

## License

MIT License
