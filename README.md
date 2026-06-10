<p align="center">
  <img src="docs/images/zabbix_logo_500x131.png" alt="Zabbix Logo" width="220"/>
</p>

# Zabbix Monitoring Platform

A production-oriented observability platform built with Zabbix, PostgreSQL/TimescaleDB, Docker Compose, and Terraform.

This project demonstrates infrastructure provisioning, monitoring, operational automation, security controls, backup and recovery procedures, and Infrastructure as Code (IaC) practices commonly used in platform engineering and site reliability engineering environments.

---

## Overview

The platform provides a containerized monitoring solution designed to showcase operational readiness, repeatable deployments, infrastructure automation, and enterprise-style documentation.

---

## Highlights

- Multi-container architecture using Docker Compose
- PostgreSQL/TimescaleDB-backed monitoring platform
- Infrastructure provisioning with Terraform
- Automated operational workflows using Makefiles
- Backup and restore automation
- Security-focused container configuration
- GitHub Actions validation pipeline
- Architecture documentation and operational runbooks

---

## Architecture

The platform separates infrastructure provisioning from application deployment.

Terraform provisions infrastructure resources while Docker Compose manages the monitoring application stack.

```text
Terraform
    │
    ▼
AWS Infrastructure
    │
    ▼
Ubuntu Host
    │
    ▼
Docker Compose
 ├── Zabbix Server
 ├── Zabbix Web Frontend
 ├── PostgreSQL / TimescaleDB
 └── Zabbix Agent
```

For detailed architecture diagrams and deployment flows, see:

- docs/ARCHITECTURE.md

---

## Infrastructure as Code

Terraform provisions:

- VPC
- Public Subnet
- Internet Gateway
- Route Table
- Security Group
- Ubuntu EC2 Instance
- Docker Engine Installation

Terraform manages infrastructure while Docker Compose manages application deployment.

### Terraform Workflow

```bash
make tf-init
make tf-plan
make tf-apply
make tf-destroy
make tf-validate
```

---

## Repository Structure

```text
.
├── docs/
├── scripts/
├── terraform/
│   └── aws/
├── backups/
├── .github/
├── docker-compose.yml
├── Makefile
└── README.md
```

---

## Quick Start

```bash
git clone https://github.com/dj-3dub/Zabbix-Docker.git
cd Zabbix-Docker
cp .env.example .env
docker compose up -d
```

---

## Operations

```bash
make validate
make up
make down
make restart
make status
make logs
make diag
make backup
make restore FILE=backups/<backup-file>.sql
```

---

## Documentation

- docs/ARCHITECTURE.md
- docs/RUNBOOK.md
- docs/SECURITY.md
- docs/BACKUP_RESTORE.md

---

## Engineering Takeaways

This project provided hands-on experience across multiple disciplines commonly encountered in platform engineering, infrastructure operations, and site reliability engineering.

Key areas of learning and practical application included:

- End-to-end observability platform design and deployment
- Infrastructure provisioning and automation using Terraform
- Secure infrastructure practices and least-privilege design
- Containerized application deployment and lifecycle management
- Identity integration patterns and access control concepts
- Backup, recovery, and operational readiness planning
- Monitoring, diagnostics, and incident response workflows
- Technical documentation, runbook development, and architecture communication

The project reinforced the importance of treating infrastructure as a product: designing for reliability, maintainability, security, and repeatability from the beginning. These principles directly influence how I approach building, operating, and automating enterprise infrastructure environments.

---

## About

Built by **Tim Heverin**

GitHub: https://github.com/dj-3dub

LinkedIn: https://www.linkedin.com/in/tim-heverin/

---

## License

MIT License
