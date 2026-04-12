---
name: troubleshoot-infra
description: Use when troubleshooting infrastructure issues including networking, DNS, TLS/SSL, Docker, Kubernetes, databases, load balancers, storage, and cloud services. Diagnoses connectivity issues, server errors, container crashes, deployment failures, and performance degradation.
---

# Infrastructure Troubleshooting

## When to use
Use this skill for infrastructure-level issues — networking, DNS, containers, databases, load balancers, cloud services, deployments. For code-level bugs, use the **debug-assistant** skill instead.

## ⚠️ Command Safety
**All commands in this skill are diagnostic (read-only).** Never run commands that modify, delete, or deploy infrastructure without explicit user approval. Only use `get`, `describe`, `logs`, `status`, `inspect`, and read-only queries. Never run `delete`, `rm`, `apply`, `deploy`, `DROP`, `ALTER`, or any mutating command.

## Triage Framework

```
1. WHAT is broken? (symptom: timeout, 502, crash, slow, unreachable)
2. WHEN did it start? (deploy, config change, traffic spike, cert expiry)
3. WHERE is it broken? (specific service, region, network path)
4. WHO is affected? (all users, specific clients, internal only)
5. WHAT changed? (recent deploy, infra change, external dependency)
```

**Always check these first:**
```bash
# Is the service running?
systemctl status <service>
docker ps
kubectl get pods -n <namespace>

# Can you reach it?
curl -v http://service:port/health
nc -zv host port

# What do the logs say?
journalctl -u <service> --since "10 min ago"
docker logs <container> --tail 100
kubectl logs <pod> -n <namespace> --tail 100
```

## Networking

### DNS issues
```bash
# Resolve a domain
dig example.com
nslookup example.com

# Check specific DNS server
dig @8.8.8.8 example.com

# Trace DNS resolution path
dig +trace example.com

# Check DNS propagation
dig example.com +short @ns1.provider.com
dig example.com +short @ns2.provider.com

# Common fixes:
# - Flush local DNS cache: sudo systemd-resolve --flush-caches
# - Check /etc/resolv.conf for correct nameservers
# - Verify DNS record TTLs and propagation
```

### Connectivity
```bash
# Test port connectivity
nc -zv host 443
telnet host 443

# Trace network path
traceroute host
mtr host    # Live, better traceroute

# Check if port is listening locally
ss -tlnp | grep :8080
netstat -tlnp | grep :8080

# Check firewall rules
iptables -L -n
ufw status verbose

# Check open connections
ss -s                    # Summary
ss -tnp | grep :8080     # Connections to specific port
```

### TLS/SSL
```bash
# Check certificate details
openssl s_client -connect host:443 -servername host </dev/null 2>/dev/null | openssl x509 -text -noout

# Check certificate expiry
openssl s_client -connect host:443 -servername host </dev/null 2>/dev/null | openssl x509 -enddate -noout

# Test TLS versions
openssl s_client -connect host:443 -tls1_2
openssl s_client -connect host:443 -tls1_3

# Common issues:
# - Expired certificate → renew with certbot or reissue
# - Wrong SNI → check -servername matches
# - Certificate chain incomplete → include intermediate certs
# - Mixed content → all resources must use HTTPS
```

### HTTP debugging
```bash
# Full request/response details
curl -v https://api.example.com/health

# Follow redirects
curl -vL https://example.com

# Check response headers
curl -I https://example.com

# Test with specific Host header
curl -H "Host: api.example.com" http://load-balancer-ip/health

# Test with timeout
curl --connect-timeout 5 --max-time 10 https://api.example.com

# Check from inside a container/pod
kubectl exec -it <pod> -- curl -v http://service:8080/health
```

## Docker

### Container not starting
```bash
# Check container status and exit code
docker ps -a | grep <name>
docker inspect <container> --format='{{.State.ExitCode}} {{.State.Error}}'

# View logs
docker logs <container> --tail 200

# Check resource limits
docker stats <container>

# Common exit codes:
# 0 = normal exit (check if CMD finished)
# 1 = application error (check logs)
# 137 = OOM killed (increase memory limit)
# 139 = segfault
# 143 = SIGTERM (graceful shutdown)
```

### Image issues
```bash
# Build with no cache (fix stale layers)
docker build --no-cache -t myapp .

# Check image size
docker images myapp

# Inspect layers
docker history myapp

# Run shell in image (debug entrypoint)
docker run -it --entrypoint /bin/sh myapp
```

### Networking
```bash
# List networks
docker network ls

# Inspect network
docker network inspect bridge

# Check container DNS resolution
docker exec <container> nslookup other-service

# Check container can reach external
docker exec <container> curl -v https://api.external.com
```

## Kubernetes

### Pod not running
```bash
# Check pod status
kubectl get pods -n <ns> -o wide
kubectl describe pod <pod> -n <ns>    # Events section is critical

# Common statuses:
# Pending = no node can schedule it (resource limits, node selector, taints)
# CrashLoopBackOff = app keeps crashing (check logs)
# ImagePullBackOff = can't pull image (wrong image name, auth, registry down)
# OOMKilled = out of memory (increase resources.limits.memory)
# Evicted = node under pressure (check node conditions)

# Check logs
kubectl logs <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous   # Previous crash logs
kubectl logs <pod> -n <ns> -c <container>  # Specific container

# Debug inside pod
kubectl exec -it <pod> -n <ns> -- sh
kubectl debug <pod> -n <ns> --image=busybox -it
```

### Service connectivity
```bash
# Check service endpoints
kubectl get endpoints <service> -n <ns>

# DNS resolution inside cluster
kubectl exec -it <pod> -- nslookup <service>.<namespace>.svc.cluster.local

# Port forward for local testing
kubectl port-forward svc/<service> 8080:80 -n <ns>

# Check network policies blocking traffic
kubectl get networkpolicies -n <ns>
```

### Node issues
```bash
# Check node status
kubectl get nodes -o wide
kubectl describe node <node>

# Check node conditions (MemoryPressure, DiskPressure, PIDPressure)
kubectl get nodes -o jsonpath='{.items[*].status.conditions}' | jq

# Check node resource usage
kubectl top nodes
kubectl top pods -n <ns> --sort-by=memory
```

## Databases

### PostgreSQL
```bash
# Check connection
psql -h host -U user -d dbname -c "SELECT 1"

# Check active connections
SELECT count(*) FROM pg_stat_activity;
SELECT * FROM pg_stat_activity WHERE state = 'active';

# Check for locks
SELECT * FROM pg_locks WHERE NOT granted;

# Check replication lag
SELECT now() - pg_last_xact_replay_timestamp() AS replication_lag;

# Check table size
SELECT pg_size_pretty(pg_total_relation_size('tablename'));

# Slow queries
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state != 'idle' ORDER BY duration DESC;
```

### Redis
```bash
redis-cli ping                    # Check if alive
redis-cli info memory             # Memory usage
redis-cli info replication        # Replication status
redis-cli info clients            # Connected clients
redis-cli --latency               # Latency test
redis-cli slowlog get 10          # Slow operations
```

## Load Balancers

```bash
# Check backend health (HAProxy)
echo "show stat" | socat stdio /var/run/haproxy/admin.sock

# Check Nginx upstream status
curl http://localhost/nginx_status

# Test specific backend directly (bypass LB)
curl -v http://backend-server:8080/health

# Common issues:
# 502 Bad Gateway = all backends down or unreachable
# 503 Service Unavailable = backends overloaded or in maintenance
# 504 Gateway Timeout = backend too slow to respond
```

## Performance

```bash
# System overview
top / htop
vmstat 1            # CPU, memory, I/O stats every 1 second
iostat -x 1         # Disk I/O stats

# Memory
free -h             # Memory summary
cat /proc/meminfo   # Detailed memory info

# Disk
df -h               # Disk space
du -sh /var/log/*   # Directory sizes
iotop               # I/O per process

# Network
iftop               # Network traffic per connection
nethogs             # Network traffic per process
```

## Gotchas

- **Always check the most recent change first.** 90% of outages correlate with a recent deploy or config change.
- **Logs lie by omission.** If logs look clean, the problem may be upstream (LB, DNS) or in a different service.
- **DNS caching** at every layer (OS, container, application). Flush all caches when changing records.
- **Time sync matters.** Out-of-sync clocks break TLS, tokens, and log correlation. Check `timedatectl` / NTP.
- **Kubernetes RBAC** can silently block operations. Check `kubectl auth can-i` when things don't work.

## Integration

- **Before this skill:** devops
- **After this skill:** bug-analyzer
- **Complementary skills:** debug-assistant, systematic-debugging
