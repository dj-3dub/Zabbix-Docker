# Backup and Restore Guide

## Purpose

This document describes the backup and recovery procedures for the Zabbix Docker Monitoring Stack.

The goal is to ensure that monitoring data, configuration, and historical metrics can be recovered in the event of data corruption, accidental deletion, infrastructure failure, or migration to a new host.

---

# What Is Protected

The following data is included in backups:

| Component                | Description                                                    |
| ------------------------ | -------------------------------------------------------------- |
| PostgreSQL / TimescaleDB | Monitoring data, hosts, triggers, templates, dashboards, users |
| Zabbix Configuration     | Stored within the database                                     |
| Historical Metrics       | Collected monitoring data                                      |
| Alerting Configuration   | Actions, media types, escalation rules                         |

---

# Backup Location

Backups are stored locally in:

```text
backups/
```

Example:

```text
backups/
├── zabbix_backup_2026-06-04_120000.sql
├── zabbix_backup_2026-06-11_120000.sql
└── zabbix_backup_2026-06-18_120000.sql
```

---

# Backup Strategy

Recommended schedule:

| Frequency            | Purpose                              |
| -------------------- | ------------------------------------ |
| Daily                | Critical monitoring environments     |
| Weekly               | Homelab and development environments |
| Before Upgrades      | Protect against failed updates       |
| Before Major Changes | Preserve rollback capability         |

---

# Creating a Backup

## Using Makefile

Create a backup:

```bash
make backup
```

---

## Manual Backup

Execute directly:

```bash
docker exec zbx-db \
  pg_dump \
  -U zabbix \
  zabbix \
  > backup.sql
```

---

# Verifying Backups

After creating a backup:

Verify file exists:

```bash
ls -lh backups/
```

Verify file contents:

```bash
head backups/<backup-file>.sql
```

Expected output should begin with:

```text
PostgreSQL database dump
```

---

# Listing Available Backups

Using Makefile:

```bash
make backup-list
```

Manual verification:

```bash
ls -lh backups/
```

---

# Restore Process

## Prerequisites

Before restoring:

1. Stop monitoring activities.
2. Ensure a valid backup exists.
3. Confirm sufficient disk space.
4. Verify database container is running.

Check status:

```bash
make status
```

---

# Restoring a Backup

## Using Makefile

Restore a backup:

```bash
make restore FILE=backups/<backup-file>.sql
```

Example:

```bash
make restore FILE=backups/zabbix_backup_2026-06-04_120000.sql
```

---

## Manual Restore

Restore directly:

```bash
cat backup.sql | docker exec -i zbx-db \
  psql \
  -U zabbix \
  zabbix
```

---

# Post-Restore Validation

After restoration:

Verify services:

```bash
make status
```

Review logs:

```bash
make logs
```

Confirm:

* Dashboard loads successfully
* Hosts appear correctly
* Historical metrics are visible
* Triggers and alerts are present
* User accounts function correctly

---

# Recovery Scenarios

## Accidental Configuration Deletion

Restore most recent backup:

```bash
make restore FILE=<backup-file>
```

Verify recovered configuration.

---

## Corrupted Database

1. Stop services.
2. Restore latest known-good backup.
3. Validate service health.
4. Confirm monitoring functionality.

---

## Host Migration

When moving to a new server:

1. Deploy fresh infrastructure.
2. Copy `.env`.
3. Start stack.
4. Restore backup.
5. Validate operation.

---

# Backup Retention

Recommended retention:

| Backup Type | Retention |
| ----------- | --------- |
| Daily       | 7 days    |
| Weekly      | 4 weeks   |
| Monthly     | 12 months |

Homelab environments may use simplified retention policies.

---

# Backup Security

Backups may contain:

* Monitoring configuration
* User accounts
* Alerting configuration
* Infrastructure details

Recommendations:

* Restrict filesystem permissions
* Encrypt backups before offsite storage
* Avoid committing backups to Git
* Store backups separately from production systems

Example permissions:

```bash
chmod 600 backups/*.sql
```

---

# Disaster Recovery Procedure

## Full Recovery

1. Deploy Docker and Docker Compose.
2. Clone repository.
3. Configure `.env`.
4. Start stack.
5. Restore database backup.
6. Validate services.
7. Confirm monitoring coverage.

Recovery checklist:

```text
[ ] Infrastructure deployed
[ ] Containers running
[ ] Database restored
[ ] Dashboard accessible
[ ] Hosts reporting
[ ] Triggers functioning
[ ] Historical data present
```

---

# Testing Restores

Backups are only useful if they can be restored.

Recommended schedule:

| Test Type                  | Frequency |
| -------------------------- | --------- |
| Backup Verification        | Monthly   |
| Restore Validation         | Quarterly |
| Disaster Recovery Exercise | Annually  |

---

# Useful Commands

Create backup:

```bash
make backup
```

List backups:

```bash
make backup-list
```

Restore backup:

```bash
make restore FILE=backups/<backup-file>.sql
```

Check health:

```bash
make health
```

View status:

```bash
make status
```
