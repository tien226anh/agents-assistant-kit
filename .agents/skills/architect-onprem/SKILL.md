---
name: architect-onprem
description: Solution architecture for on-premise software deployment including server infrastructure, networking, storage, containerization, CI/CD pipelines, monitoring, security hardening, high availability, and disaster recovery. Use when the user asks about deploying software on-prem, designing infrastructure without cloud providers, self-hosted systems, bare-metal servers, or private data center architecture.
---

# On-Premise Solution Architecture

## When to use
Use this skill when designing, deploying, or maintaining software on on-premise infrastructure — bare-metal servers, private data centers, self-hosted environments, or air-gapped networks.

## ⚠️ Command Safety
This skill provides **architecture guidance and reference configurations**. Agents must only run read-only diagnostic commands (`systemctl status`, `kubectl get`, `docker ps`). Never run install, deploy, delete, or modify commands without explicit user approval.

## Architecture Decision Framework

Before designing, answer these questions:

```
1. Scale: How many users/requests? Growth projections?
2. Availability: What uptime SLA? (99.9% = 8.7h downtime/year)
3. Data sensitivity: Compliance requirements? (HIPAA, PCI-DSS, GDPR)
4. Budget: CapEx vs OpEx constraints?
5. Team: Who operates this? (dedicated ops team vs developers)
6. Network: Air-gapped? VPN requirements? Multi-site?
```

## Infrastructure Layers

### 1. Compute

**Bare metal vs Virtualization vs Containers**

| Approach | Best For | Tools |
|----------|----------|-------|
| Bare metal | Maximum performance, GPU workloads | IPMI, PXE boot |
| VMs | Multi-tenant isolation, legacy apps | Proxmox, VMware vSphere, KVM |
| Containers | Microservices, stateless apps | Docker, Podman, Kubernetes |
| Hybrid | Mixed workloads | Containers on VMs |

**Recommended stack for most workloads:**
- **Kubernetes (k8s)** on VMs or bare metal via **k3s** (lightweight) or **RKE2** (production-grade)
- **Container runtime**: containerd (default for k8s) or Podman (rootless)

### 2. Networking

```
┌─────────────────────────────────────────────┐
│                  Internet                    │
└────────────────────┬────────────────────────┘
                     │
              ┌──────┴──────┐
              │  Firewall   │  (pfSense, OPNsense)
              └──────┬──────┘
                     │
              ┌──────┴──────┐
              │ Load Balancer│  (HAProxy, Nginx, Traefik)
              └──────┬──────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
    ┌────┴────┐ ┌────┴────┐ ┌───┴─────┐
    │ App 1   │ │ App 2   │ │ App 3   │
    └────┬────┘ └────┬────┘ └───┬─────┘
         │           │           │
         └───────────┼───────────┘
                     │
              ┌──────┴──────┐
              │  Database   │  (Primary + Replica)
              └─────────────┘
```

**Key components:**
- **Reverse proxy / Load balancer**: Nginx, HAProxy, or Traefik
- **DNS**: CoreDNS, Pi-hole, or BIND
- **TLS certificates**: Let's Encrypt (with ACME) or internal CA (step-ca, cfssl)
- **VPN**: WireGuard (simple, fast) or OpenVPN
- **Network segmentation**: VLANs for separating app, DB, management traffic

### 3. Storage

| Type | Use Case | Tools |
|------|----------|-------|
| Block storage | Databases, VMs | LVM, ZFS, Ceph RBD |
| File storage | Shared files, NFS mounts | NFS, GlusterFS, Ceph FS |
| Object storage | Backups, media, logs | MinIO (S3-compatible), Ceph RGW |
| Database | Application data | PostgreSQL, MySQL, MongoDB |

**MinIO** is the standard for on-prem S3-compatible object storage. Use it for:
- Backup storage
- Application file uploads
- Log archival
- Container registry backend

### 4. Container Orchestration (Kubernetes)

**On-prem K8s distributions:**

| Distribution | Complexity | Best For |
|-------------|-----------|----------|
| **k3s** | Low | Edge, small clusters, dev |
| **RKE2** | Medium | Production, FIPS compliance |
| **kubeadm** | Medium | Custom setups |
| **Talos Linux** | Medium | Immutable OS, security-first |
| **OpenShift** | High | Enterprise, support contracts |

**Essential add-ons for on-prem k8s:**
- **Ingress**: Traefik, Nginx Ingress, or Contour
- **Storage**: Longhorn (simple), Rook-Ceph (scalable), or OpenEBS
- **Load balancer**: MetalLB (bare-metal LB for k8s services)
- **DNS**: ExternalDNS + CoreDNS
- **Certificates**: cert-manager with Let's Encrypt or internal CA

### 5. CI/CD

| Tool | Type | Self-hosted |
|------|------|-------------|
| **GitLab CI** | Full DevOps platform | ✅ Built-in |
| **Gitea + Woodpecker** | Lightweight git + CI | ✅ |
| **Jenkins** | Highly customizable CI | ✅ (legacy but powerful) |
| **Drone CI** | Container-native CI | ✅ |
| **ArgoCD** | GitOps for Kubernetes | ✅ |

**Recommended pipeline:**
```
Git push → CI build → Container image → Registry → ArgoCD → Kubernetes
```

**Container registry** (self-hosted):
- Harbor (enterprise features, vulnerability scanning)
- Gitea Container Registry (if using Gitea)
- Docker Registry v2 (simple)

### 6. Monitoring & Observability

**The observability stack:**

| Layer | Tool | Purpose |
|-------|------|---------|
| Metrics | **Prometheus** + **Grafana** | Time-series metrics, dashboards |
| Logs | **Loki** + **Promtail** | Log aggregation (lightweight) |
| Traces | **Jaeger** or **Tempo** | Distributed tracing |
| Alerts | **Alertmanager** | Alert routing (PagerDuty, Slack, email) |
| Uptime | **Uptime Kuma** | Endpoint monitoring, status pages |

### 7. Security

```
- [ ] Firewall rules: deny all, allow specific
- [ ] TLS everywhere (even internal services)
- [ ] SSH key-only authentication (disable password auth)
- [ ] Secrets management: Vault (HashiCorp) or Sealed Secrets (k8s)
- [ ] Regular OS patching (Unattended Upgrades)
- [ ] Vulnerability scanning: Trivy (container images), OpenVAS (infrastructure)
- [ ] Backup encryption at rest
- [ ] Network segmentation (app tier, DB tier, management tier)
- [ ] Audit logging for all administrative actions
- [ ] MFA for all admin access
```

### 8. High Availability

**Database HA:**
- PostgreSQL: Patroni + etcd (automated failover)
- MySQL: InnoDB Cluster or Galera Cluster
- Redis: Redis Sentinel or Redis Cluster

**Application HA:**
- Multiple replicas behind load balancer
- Health checks with automatic restart
- Rolling deployments (zero-downtime)
- Pod disruption budgets (k8s)

**Infrastructure HA:**
- Redundant power supplies
- RAID storage (RAID 10 for DBs)
- Multiple network paths
- Geographic redundancy (if multi-site)

### 9. Backup & Disaster Recovery

```
- [ ] 3-2-1 rule: 3 copies, 2 media types, 1 offsite
- [ ] Database: pg_dump / mysqldump + WAL archiving (point-in-time recovery)
- [ ] Kubernetes: Velero for cluster state + PV snapshots
- [ ] Files: Restic or BorgBackup (encrypted, deduplicated)
- [ ] Test restores monthly
- [ ] Document RTO (Recovery Time Objective) and RPO (Recovery Point Objective)
```

## Gotchas

- **Don't underestimate networking.** On-prem networking is the #1 source of issues. Document every VLAN, firewall rule, and DNS entry.
- **Hardware failures happen.** Plan for disk failures (RAID), power failures (UPS), and complete server failures (replicas).
- **Keep firmware updated.** BIOS, IPMI/BMC, NIC firmware, disk firmware — all need regular updates.
- **Air-gapped environments** need a mirror strategy for OS packages, container images, and language packages.
- **Capacity planning is your job.** No auto-scaling — you must predict and procure hardware ahead of demand.

For detailed tool comparisons, see [references/onprem-tools.md](references/onprem-tools.md).
