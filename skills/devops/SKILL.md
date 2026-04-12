---
name: devops
description: Use when working with DevOps practices including Docker, Kubernetes, CI/CD pipelines (GitHub Actions, GitLab CI), GitOps (ArgoCD/Flux), container registries, secrets management, monitoring, log aggregation, and deployment strategies (blue-green, canary, rolling).
---

# DevOps

## When to use
Use this skill for day-to-day DevOps operations — building containers, setting up CI/CD, deploying to Kubernetes, monitoring, and automation. For architecture-level design, use **architect-onprem** or **architect-cloud** skills instead.

## ⚠️ Command Safety
This skill contains both **reference templates** (Dockerfiles, CI configs, K8s manifests) and **operational commands**. Agents should:
- ✅ **Generate**: Dockerfiles, docker-compose.yml, CI/CD configs, K8s manifests, monitoring configs
- ✅ **Run read-only**: `docker ps`, `kubectl get`, `kubectl describe`, `kubectl logs`, `helm list`
- ❌ **Never auto-run**: `kubectl apply/delete`, `docker rm`, `helm install/upgrade`, `terraform apply`, deploy scripts — always require explicit user approval

## Docker

### Dockerfile best practices
```dockerfile
# 1. Use specific base image tags (never :latest in production)
FROM node:22-slim AS base

# 2. Multi-stage builds to minimize final image
FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable pnpm && pnpm install --frozen-lockfile --prod

FROM base AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm build

FROM base AS production
WORKDIR /app
# 3. Copy only what's needed
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json ./
# 4. Run as non-root user
USER node
# 5. Use exec form for CMD
CMD ["node", "dist/index.js"]
```

### Docker Compose (development)
```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/app
      - REDIS_URL=redis://redis:6379
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    volumes:
      - ./src:/app/src    # Hot reload in dev
    develop:
      watch:
        - action: sync
          path: ./src
          target: /app/src

  db:
    image: postgres:16
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: app
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    volumes:
      - redisdata:/data

volumes:
  pgdata:
  redisdata:
```

## CI/CD

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI/CD
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm typecheck
      - run: pnpm test:coverage
        env:
          DATABASE_URL: postgres://postgres:test@localhost:5432/postgres

  build-and-push:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
```

### GitLab CI
```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy

test:
  stage: test
  image: node:22
  services:
    - postgres:16
  variables:
    POSTGRES_PASSWORD: test
    DATABASE_URL: postgres://postgres:test@postgres:5432/postgres
  script:
    - corepack enable pnpm
    - pnpm install --frozen-lockfile
    - pnpm lint
    - pnpm typecheck
    - pnpm test:coverage

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main
```

## Kubernetes Operations

### Deployment manifest
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: production
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0    # Zero-downtime deploy
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: app
          image: ghcr.io/org/my-app:sha-abc123
          ports:
            - containerPort: 3000
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: database-url
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
            limits:
              cpu: 500m
              memory: 512Mi
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
```

### Common operations
```bash
# Deploy
kubectl apply -f k8s/
kubectl rollout status deployment/my-app -n production

# Rollback
kubectl rollout undo deployment/my-app -n production
kubectl rollout history deployment/my-app -n production

# Scale
kubectl scale deployment/my-app --replicas=5 -n production

# Secrets
kubectl create secret generic app-secrets \
  --from-literal=database-url='postgres://...' \
  -n production

# Port forward (debug)
kubectl port-forward svc/my-app 3000:80 -n production

# Log streaming
kubectl logs -f deployment/my-app -n production --all-containers
stern my-app -n production    # Better log tailing (install stern)
```

## GitOps (ArgoCD)

```yaml
# argocd-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/org/infra.git
    targetRevision: main
    path: k8s/production
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

**GitOps workflow:**
```
Developer pushes code → CI builds image → CI updates image tag in infra repo →
ArgoCD detects change → ArgoCD syncs to cluster → App deployed
```

## Deployment Strategies

| Strategy | Risk | Downtime | Rollback Speed |
|----------|------|----------|---------------|
| **Rolling** | Low | None | Fast (rollout undo) |
| **Blue-Green** | Low | None | Instant (switch LB) |
| **Canary** | Very low | None | Instant (route change) |
| **Recreate** | High | Yes | Slow |

## Monitoring Setup

### Prometheus + Grafana (Helm)
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.adminPassword=admin
```

### Application metrics (expose /metrics endpoint)

**Node.js:**
```typescript
import { register, Counter, Histogram } from "prom-client";

const httpRequests = new Counter({
  name: "http_requests_total",
  help: "Total HTTP requests",
  labelNames: ["method", "path", "status"],
});

const httpDuration = new Histogram({
  name: "http_request_duration_seconds",
  help: "HTTP request duration",
  labelNames: ["method", "path"],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 5],
});

// Express middleware
app.use((req, res, next) => {
  const end = httpDuration.startTimer({ method: req.method, path: req.path });
  res.on("finish", () => {
    httpRequests.inc({ method: req.method, path: req.path, status: res.statusCode });
    end();
  });
  next();
});

app.get("/metrics", async (req, res) => {
  res.set("Content-Type", register.contentType);
  res.send(await register.metrics());
});
```

**Python (FastAPI):**
```python
from prometheus_client import Counter, Histogram, generate_latest
from starlette.middleware.base import BaseHTTPMiddleware

REQUEST_COUNT = Counter("http_requests_total", "Total HTTP requests", ["method", "path", "status"])
REQUEST_DURATION = Histogram("http_request_duration_seconds", "HTTP request duration", ["method", "path"])

class MetricsMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        with REQUEST_DURATION.labels(method=request.method, path=request.url.path).time():
            response = await call_next(request)
            REQUEST_COUNT.labels(method=request.method, path=request.url.path, status=response.status_code).inc()
            return response

@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type="text/plain")
```

## Gotchas

- **Never store secrets in git.** Use environment variables, Kubernetes secrets, or a secrets manager.
- **Always pin image tags.** Never use `:latest` in production. Use SHA or semver tags.
- **Health checks are mandatory.** Without them, k8s can't route traffic or restart unhealthy pods.
- **Resource limits prevent noisy neighbors.** Always set CPU/memory requests and limits.
- **CI/CD needs secrets rotation.** Rotate API keys, tokens, and credentials regularly.
- **Monitoring is not optional.** If you can't measure it, you can't fix it.

## Integration

- **Before this skill:** architect-cloud, architect-onprem
- **After this skill:** code-review, test-writer
- **Complementary skills:** troubleshoot-infra, git-workflow
