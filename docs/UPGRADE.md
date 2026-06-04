# Upgrade Guide

## Purpose

This document describes the recommended process for upgrading the Zabbix Docker Monitoring Stack.

The goal is to minimize downtime, protect monitoring data, preserve observability, and provide a repeatable upgrade workflow for Zabbix, PostgreSQL/TimescaleDB, Docker images, and supporting components.

---

# Upgrade Philosophy

All upgrades should follow a controlled process:

- Backup first
- Validate compatibility
- Review release notes
- Upgrade in small increments
- Verify functionality
- Maintain rollback capability

The monitoring platform is a critical operational service. Upgrades should be approached with the same discipline applied to production infrastructure.

---

# Components Covered

| Component | Upgrade Method |
|------------|------------|
| Zabbix Server | Docker image update |
| Zabbix Web Frontend | Docker image update |
| Zabbix Agent 2 | Docker image update |
| PostgreSQL / TimescaleDB | Controlled image upgrade |
| Docker Compose | Host package update |
| Docker Engine | Host package update |

---

# Pre-Upgrade Checklist

Complete the following before every upgrade:

[ ] Review vendor release notes

[ ] Create a database backup

[ ] Verify backup integrity

[ ] Document current versions

[ ] Verify available disk space

[ ] Confirm maintenance window

[ ] Verify rollback procedure

[ ] Notify stakeholders (if applicable)

---

# Document Current Versions

Check running containers:

```bash
docker compose ps
```

Review image versions:

```bash
docker compose images
```

Example:

```text
zabbix/zabbix-server-pgsql      alpine-7.4.11
zabbix/zabbix-web-nginx-pgsql  alpine-7.4.11
zabbix/zabbix-agent2           alpine-7.4.11
timescale/timescaledb          2.17.2-pg16
```

---

# Create Backup

Always create a backup before upgrading.

```bash
make backup
```

Verify backup:

```bash
ls -lh backups/
```

Confirm backup size is reasonable and file creation completed successfully.

---

# Review Release Notes

Before updating image versions:

- Review Zabbix release notes
- Review PostgreSQL release notes
- Review TimescaleDB release notes
- Identify schema or compatibility changes
- Review deprecated functionality

Recommended sources:

- Zabbix Documentation
- PostgreSQL Documentation
- TimescaleDB Documentation
- Docker Hub release pages

---

# Pull Updated Images

Update image versions in:

```text
docker-compose.yml
```

Example:

```yaml
image: zabbix/zabbix-server-pgsql:alpine-7.4.12
```

Pull new images:

```bash
docker compose pull
```

Verify:

```bash
docker compose images
```

---

# Perform Upgrade

Deploy updated containers:

```bash
docker compose up -d
```

Verify service startup:

```bash
docker compose ps
```

Expected:

```text
db        running
server    running
web       running
agent     running
```

---

# Post-Upgrade Validation

Run diagnostics:

```bash
make diag
```

Review logs:

```bash
make logs
```

Verify:

- Containers are healthy
- Web UI loads successfully
- Dashboard renders correctly
- Agents are reporting
- Historical metrics remain available
- Triggers function correctly
- Alerts are generated normally

---

# Upgrade Validation Checklist

[ ] Database healthy

[ ] Server healthy

[ ] Web frontend healthy

[ ] Agent connected

[ ] Dashboard accessible

[ ] Historical data visible

[ ] Triggers functioning

[ ] Backup procedures verified

---

# Rollback Procedure

If issues are encountered:

## Stop Services

```bash
make down
```

## Revert Image Versions

Update image tags in:

```text
docker-compose.yml
```

Return to the previous known-good versions.

## Restart Services

```bash
make up
```

Verify:

```bash
make status
```

---

# Database Recovery

If database corruption or migration issues occur:

Restore the most recent backup:

```bash
make restore FILE=backups/<backup-file>.sql
```

Verify:

```bash
make diag
```

---

# Major Version Upgrades

Major upgrades require additional planning.

Examples:

```text
Zabbix 7.2 → 7.4
PostgreSQL 15 → PostgreSQL 16
TimescaleDB major version changes
```

Before proceeding:

- Validate compatibility
- Review migration documentation
- Test in a lab environment
- Verify backup and restore procedures

Major upgrades should always be tested before deployment.

---

# Security Update Process

Monthly:

- Review Zabbix releases
- Review PostgreSQL releases
- Review TimescaleDB releases
- Review Docker image updates

Quarterly:

- Review security advisories
- Audit image versions
- Validate container hardening configuration

---

# Failed Upgrade Recovery

If services fail after an upgrade:

Check service status:

```bash
make status
```

Review logs:

```bash
make logs
```

Run diagnostics:

```bash
make diag
```

Rollback if necessary.

Restore backups if recovery cannot be achieved through rollback.

---

# Maintenance Schedule

| Task | Frequency |
|--------|--------|
| Backup Verification | Monthly |
| Image Review | Monthly |
| Dependency Review | Quarterly |
| Restore Testing | Quarterly |
| Full Upgrade Exercise | Annually |

---

# Recommended Upgrade Workflow

```bash
make backup
docker compose pull
docker compose up -d
make diag
make logs
```

If successful:

```text
Upgrade completed successfully.
```

If unsuccessful:

```text
Rollback to previous versions.
Restore backup if necessary.
```

---

# References

Official Documentation:

- Zabbix Documentation
- PostgreSQL Documentation
- TimescaleDB Documentation
- Docker Documentation

---

# Summary

The safest upgrade strategy is:

1. Backup first.
2. Upgrade in small increments.
3. Validate functionality.
4. Maintain rollback capability.
5. Test recovery procedures regularly.

Following this process helps ensure monitoring continuity while reducing upgrade-related risk.
