# Security Guide

## Purpose

This document outlines the security considerations, hardening measures, and operational recommendations for the Zabbix Docker Monitoring Stack.

The goal of this project is to demonstrate secure-by-default infrastructure practices while maintaining a simple deployment model suitable for homelab, development, and learning environments.

---

# Security Principles

This project follows several core security principles:

* Least Privilege
* Defense in Depth
* Secure Configuration Management
* Vulnerability Management
* Separation of Secrets
* Infrastructure as Code

---

# Secrets Management

## Environment Variables

Sensitive values are stored in a local `.env` file.

Examples include:

```text
DB_USER
DB_PASSWORD
DB_NAME
```

The `.env` file is excluded from source control via `.gitignore`.

A sanitized `.env.example` file is provided for reference.

---

## Recommendations

For production deployments:

* Use Docker Secrets
* Use a secret management platform
* Rotate credentials regularly
* Avoid storing secrets directly in Compose files

Examples:

```text
HashiCorp Vault
Bitwarden Secrets Manager
AWS Secrets Manager
Azure Key Vault
```

---

# Container Hardening

## Security Options

Containers should be configured with:

```yaml
security_opt:
  - no-new-privileges:true
```

This prevents privilege escalation within containers.

---

## Restart Policies

Containers should use:

```yaml
restart: unless-stopped
```

This improves availability following service interruptions.

---

## Image Version Pinning

Avoid:

```yaml
image: alpine-latest
```

Prefer:

```yaml
image: alpine-7.4.11
```

Benefits:

* Predictable deployments
* Repeatable builds
* Reduced upgrade risk
* Easier troubleshooting

---

# Network Security

## Internal Network Segmentation

Containers communicate using an isolated Docker bridge network.

```yaml
networks:
  zbx-net:
    driver: bridge
```

Benefits:

* Reduces attack surface
* Limits lateral movement
* Restricts unnecessary exposure

---

## Exposed Ports

Only required services should be published.

Current ports:

| Port  | Purpose       |
| ----- | ------------- |
| 8180  | Zabbix Web UI |
| 10051 | Zabbix Server |

Avoid exposing database ports externally unless absolutely necessary.

---

# Web Interface Security

## Default Credentials

Default credentials:

```text
Username: Admin
Password: zabbix
```

Immediately change these credentials after deployment.

---

## HTTPS

The default deployment uses HTTP.

For production-style deployments, place Zabbix behind a reverse proxy.

Examples:

```text
Caddy
Traefik
Nginx
HAProxy
```

Benefits:

* TLS encryption
* Automatic certificate management
* Additional access controls

---

## Multi-Factor Authentication

When possible:

* Enable MFA
* Integrate with SSO
* Use centralized identity management

Examples:

```text
Authentik
Keycloak
Azure AD
Okta
```

---

# Vulnerability Management

## Image Scanning

Container images should be scanned regularly.

Recommended tools:

```text
Trivy
Docker Scout
Grype
```

Example:

```bash
make security
```

---

## Patch Management

Review updates regularly.

Recommended schedule:

### Monthly

* Pull updated images
* Review release notes
* Validate stack functionality

### Quarterly

* Review security posture
* Test backup restoration
* Audit monitoring coverage

---

# Logging and Monitoring

The monitoring platform itself should be monitored.

Review:

* Container health
* Resource utilization
* Database health
* Zabbix internal alerts

Commands:

```bash
make health
make report
```

---

# Backup Security

Database backups may contain:

* Host information
* Monitoring data
* User accounts
* Configuration details

Recommendations:

* Store backups securely
* Restrict access permissions
* Encrypt backups when appropriate
* Regularly test restore procedures

---

# GitHub Security

## Source Control

Never commit:

```text
.env
database dumps
API keys
private certificates
tokens
passwords
```

Review commits before pushing.

---

## Dependency Updates

Monitor upstream projects:

* Zabbix
* TimescaleDB
* PostgreSQL
* Docker Engine

Apply updates after testing.

---

# Future Enhancements

Potential future security improvements include:

* Docker Secrets integration
* Reverse proxy with HTTPS
* Authentik SSO
* Role-based access control
* Container image signing
* Automated vulnerability scanning
* Security-focused GitHub Actions workflows

---

# Security Disclaimer

This project is intended for educational and portfolio purposes.

Before deploying in a production environment, perform a full security review, credential rotation process, vulnerability assessment, and infrastructure hardening exercise appropriate for your organization's requirements.
