# On-Premise Tools Reference

Detailed tool comparisons and configurations for on-premise infrastructure.

## Virtualization Platforms

### Proxmox VE (recommended for most)
- Free and open source (AGPL)
- KVM for VMs + LXC for containers
- Web UI, backup, HA clustering built-in
- REST API for automation

```bash
# Create VM via CLI
qm create 100 --name myvm --memory 4096 --cores 4 --net0 virtio,bridge=vmbr0
qm set 100 --scsi0 local-lvm:32
qm set 100 --ide2 local:iso/ubuntu-24.04.iso,media=cdrom
qm start 100
```

### VMware vSphere
- Industry standard for enterprise
- Requires licensing (expensive)
- Best ecosystem of management tools
- vMotion for live migration

## Kubernetes Distributions

### k3s (lightweight, recommended for small-medium)
```bash
# Install server
curl -sfL https://get.k3s.io | sh -

# Install agent (worker node)
curl -sfL https://get.k3s.io | K3S_URL=https://server:6443 K3S_TOKEN=<token> sh -

# Features included: Traefik, CoreDNS, local-path-provisioner, metrics-server
```

### RKE2 (production-grade, FIPS compliant)
```bash
# Install server
curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service

# FIPS mode
curl -sfL https://get.rke2.io | INSTALL_RKE2_METHOD=rpm sh -
```

## Load Balancers

### HAProxy (TCP/HTTP, high performance)
```
frontend http-in
    bind *:80
    bind *:443 ssl crt /etc/ssl/certs/app.pem
    redirect scheme https if !{ ssl_fc }
    default_backend app-servers

backend app-servers
    balance roundrobin
    option httpchk GET /health
    server app1 10.0.1.10:8000 check
    server app2 10.0.1.11:8000 check
    server app3 10.0.1.12:8000 check
```

### Traefik (container-native, auto-discovery)
```yaml
# docker-compose.yml
services:
  traefik:
    image: traefik:v3
    command:
      - --providers.docker=true
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.letsencrypt.acme.email=admin@example.com
      - --certificatesresolvers.letsencrypt.acme.storage=/acme/acme.json
      - --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./acme:/acme
```

## Database HA

### PostgreSQL + Patroni (automated failover)
```yaml
# patroni.yml
scope: postgres-cluster
name: node1

restapi:
  listen: 0.0.0.0:8008

etcd:
  hosts: 10.0.1.20:2379,10.0.1.21:2379,10.0.1.22:2379

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
      parameters:
        max_connections: 200
        shared_buffers: 4GB
        wal_level: replica
        max_wal_senders: 5

postgresql:
  listen: 0.0.0.0:5432
  data_dir: /var/lib/postgresql/data
  authentication:
    replication:
      username: replicator
      password: rep-pass
    superuser:
      username: postgres
      password: postgres-pass
```

## Secrets Management

### HashiCorp Vault
```bash
# Start dev server (testing only)
vault server -dev

# Store a secret
vault kv put secret/app/db password=s3cret host=db.internal

# Read a secret
vault kv get secret/app/db

# Dynamic database credentials
vault read database/creds/app-role
```

## Backup

### Restic (encrypted, deduplicated, fast)
```bash
# Initialize repository
restic -r /mnt/backup/repo init

# Backup
restic -r /mnt/backup/repo backup /var/data --tag daily

# List snapshots
restic -r /mnt/backup/repo snapshots

# Restore
restic -r /mnt/backup/repo restore latest --target /var/data-restored

# Prune old snapshots
restic -r /mnt/backup/repo forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
```

### Velero (Kubernetes backup)
```bash
# Install
velero install --provider aws --bucket velero-backup \
  --secret-file ./credentials \
  --backup-location-config region=minio,s3ForcePathStyle=true,s3Url=http://minio:9000

# Backup namespace
velero backup create my-backup --include-namespaces production

# Schedule daily backups
velero schedule create daily --schedule="0 2 * * *" --include-namespaces production

# Restore
velero restore create --from-backup my-backup
```

## Monitoring

### Prometheus + Grafana (docker-compose)
```yaml
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    ports:
      - "3000:3000"

  node-exporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"
```

### Alertmanager rules example
```yaml
groups:
  - name: infrastructure
    rules:
      - alert: HighCPU
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 10m
        labels:
          severity: warning

      - alert: DiskSpaceLow
        expr: node_filesystem_avail_bytes / node_filesystem_size_bytes * 100 < 10
        for: 5m
        labels:
          severity: critical

      - alert: ServiceDown
        expr: up == 0
        for: 2m
        labels:
          severity: critical
```
