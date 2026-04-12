---
name: architect-cloud
description: Solution architecture for multi-cloud software deployment across AWS, GCP, and Azure. Covers compute, storage, databases, networking, serverless, containers, IaC (Terraform), CI/CD, cost optimization, security, compliance, and cloud-native patterns. Use when the user asks about cloud architecture, deploying to AWS/GCP/Azure, cloud infrastructure design, serverless, managed services, or cloud migration.
---

# Cloud Solution Architecture (Multi-Cloud)

## When to use
Use this skill when designing, deploying, or migrating software to cloud platforms — AWS, GCP, Azure, or multi-cloud environments.

## ⚠️ Command Safety
This skill provides **architecture guidance and IaC templates**. Agents must only run read-only commands (`terraform plan`, `aws describe-*`, `gcloud list`, `az show`, `kubectl get`). Never run `terraform apply`, `aws create/delete`, `gcloud deploy`, or any mutating cloud CLI commands without explicit user approval.

## Architecture Decision Framework

```
1. Workload type: Stateless API? Data pipeline? ML? Real-time?
2. Scale pattern: Steady? Spiky? Predictable growth?
3. Latency requirements: Regional? Global? Edge?
4. Data residency: Which regions? Compliance constraints?
5. Cost model: Optimize for cost vs speed vs reliability?
6. Vendor strategy: Single cloud? Multi-cloud? Avoid lock-in?
7. Team skills: Which cloud does your team know?
```

## Service Mapping (AWS ↔ GCP ↔ Azure)

### Compute

| Capability | AWS | GCP | Azure |
|-----------|-----|-----|-------|
| VMs | EC2 | Compute Engine | Virtual Machines |
| Containers (managed) | ECS, EKS | Cloud Run, GKE | ACA, AKS |
| Serverless functions | Lambda | Cloud Functions | Azure Functions |
| Serverless containers | Fargate, App Runner | Cloud Run | Container Apps |

### Storage

| Capability | AWS | GCP | Azure |
|-----------|-----|-----|-------|
| Object storage | S3 | Cloud Storage | Blob Storage |
| Block storage | EBS | Persistent Disk | Managed Disks |
| File storage | EFS | Filestore | Azure Files |
| Archive | S3 Glacier | Archive Storage | Cool/Archive Blob |

### Databases

| Capability | AWS | GCP | Azure |
|-----------|-----|-----|-------|
| Relational (managed) | RDS, Aurora | Cloud SQL, AlloyDB | Azure SQL, Flexible Server |
| NoSQL (document) | DynamoDB | Firestore | Cosmos DB |
| NoSQL (key-value) | ElastiCache (Redis) | Memorystore | Azure Cache for Redis |
| NoSQL (wide column) | DynamoDB | Bigtable | Cosmos DB (Cassandra API) |
| Search | OpenSearch | — | Azure AI Search |
| Data warehouse | Redshift | BigQuery | Synapse Analytics |

### Networking

| Capability | AWS | GCP | Azure |
|-----------|-----|-----|-------|
| Virtual network | VPC | VPC | VNet |
| Load balancer | ALB/NLB | Cloud Load Balancing | Application Gateway / LB |
| CDN | CloudFront | Cloud CDN | Azure CDN / Front Door |
| DNS | Route 53 | Cloud DNS | Azure DNS |
| API Gateway | API Gateway | API Gateway / Apigee | API Management |

### Messaging & Events

| Capability | AWS | GCP | Azure |
|-----------|-----|-----|-------|
| Message queue | SQS | Cloud Tasks | Queue Storage / Service Bus |
| Pub/sub | SNS, EventBridge | Pub/Sub | Event Grid / Service Bus |
| Streaming | Kinesis | Dataflow | Event Hubs |

### Identity & Security

| Capability | AWS | GCP | Azure |
|-----------|-----|-----|-------|
| IAM | IAM | IAM | Entra ID (Azure AD) |
| Secrets | Secrets Manager | Secret Manager | Key Vault |
| Certificates | ACM | Certificate Manager | Key Vault |
| KMS | KMS | Cloud KMS | Key Vault |

## Architecture Patterns

### 1. Three-Tier Web Application
```
Internet → CDN → Load Balancer → App Servers (auto-scaling) → Database (managed)
                                       ↓
                                  Cache (Redis)
                                       ↓
                                Object Storage (static assets)
```

### 2. Event-Driven (Serverless)
```
API Gateway → Lambda/Cloud Functions → SQS/Pub/Sub → Worker Functions → Database
                     ↓
               EventBridge/Event Grid → Fan-out to multiple consumers
```

### 3. Microservices on Kubernetes
```
Ingress → Service Mesh (Istio/Linkerd) → Service A → Database A
                                       → Service B → Database B
                                       → Service C → Queue → Worker
```

### 4. Data Pipeline
```
Sources → Ingestion (Kinesis/Pub/Sub) → Processing (Spark/Dataflow) → Warehouse (BigQuery/Redshift) → BI
```

## Infrastructure as Code (Terraform)

### Project structure
```
infra/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── production/
├── modules/
│   ├── networking/
│   ├── compute/
│   ├── database/
│   └── monitoring/
└── shared/
    └── backend.tf
```

### Key patterns
```hcl
# Use modules for reusable components
module "vpc" {
  source = "../../modules/networking"

  cidr_block     = "10.0.0.0/16"
  environment    = var.environment
  azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Use remote state
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "production/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-locks"
  }
}

# Tag everything
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
```

**Terraform alternatives by cloud:**
- **AWS**: CDK (TypeScript/Python), CloudFormation
- **GCP**: Deployment Manager, Pulumi
- **Azure**: Bicep, ARM templates
- **Multi-cloud**: Terraform (recommended), Pulumi, Crossplane (k8s-native)

## CI/CD for Cloud

### GitHub Actions (multi-cloud)
```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write  # OIDC auth (no static keys!)
      contents: read
    steps:
      - uses: actions/checkout@v4

      # AWS (use OIDC, never static credentials)
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/deploy
          aws-region: us-east-1

      # GCP
      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: projects/123/locations/global/...
          service_account: deploy@project.iam.gserviceaccount.com

      # Azure
      - uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Cost Optimization

### Principles
1. **Right-size** — Don't over-provision. Start small, scale up based on metrics.
2. **Use spot/preemptible** — For batch jobs, CI runners, dev environments (60-90% savings).
3. **Reserved/committed use** — For steady-state production workloads (30-60% savings).
4. **Serverless for spiky loads** — Pay only for what you use.
5. **Auto-scaling** — Scale down during off-hours.
6. **Storage lifecycle policies** — Move old data to cheaper tiers automatically.
7. **Delete unused resources** — Orphaned disks, old snapshots, unattached IPs.

### Cost monitoring tools
| Cloud | Native Tool | Third-party |
|-------|-------------|-------------|
| AWS | Cost Explorer, Budgets | Infracost, Vantage |
| GCP | Billing Reports, Budgets | Infracost |
| Azure | Cost Management | Infracost, Vantage |

## Security Best Practices

```
- [ ] Use OIDC/Workload Identity for CI/CD (no static API keys)
- [ ] Principle of least privilege for all IAM roles
- [ ] Enable cloud audit logging (CloudTrail, Cloud Audit Logs, Activity Log)
- [ ] Encrypt data at rest (default) AND in transit (enforce TLS)
- [ ] Use managed secrets (Secrets Manager, Secret Manager, Key Vault)
- [ ] Enable MFA for all human accounts
- [ ] Use private subnets for databases and internal services
- [ ] VPC/VNet peering instead of public endpoints for inter-service communication
- [ ] Enable DDoS protection for public-facing services
- [ ] Regular security scanning (GuardDuty, Security Command Center, Defender)
- [ ] Infrastructure as Code — no manual changes in console
```

## Multi-Cloud Strategy

### When to go multi-cloud
- **Compliance**: Data residency requires specific regions only available on certain clouds
- **Best-of-breed**: BigQuery for analytics + AWS for everything else
- **Vendor negotiation**: Leverage competition for better pricing
- **Disaster recovery**: Cross-cloud DR for critical systems

### When NOT to go multi-cloud
- **Small team**: Operational overhead of multi-cloud > benefits
- **No clear requirement**: Don't add complexity for theoretical benefits
- **Skill gap**: Team only knows one cloud well

### Multi-cloud patterns
1. **Abstraction layer**: Use Terraform + Kubernetes to abstract cloud-specific APIs
2. **Service mesh**: Istio or Consul for cross-cloud service connectivity
3. **Data replication**: Cross-cloud database replication for DR
4. **DNS-based routing**: Use external DNS (Route 53, Cloudflare) for traffic steering

## Gotchas

- **Egress costs kill budgets.** Data leaving a cloud is expensive. Design to minimize cross-region and cross-cloud data transfer.
- **Managed services = vendor lock-in.** Use managed Postgres over DynamoDB if portability matters.
- **"Lift and shift" is rarely optimal.** Refactor for cloud-native patterns to get real benefits.
- **IAM is the #1 security surface.** Over-permissive roles are the most common vulnerability.
- **Multi-region is hard.** Don't do it unless you genuinely need it. Start with one region.
- **Terraform state is critical.** Always use remote state with locking. Never commit `.tfstate` to git.

For cloud-specific patterns and IaC examples, see [references/cloud-services.md](references/cloud-services.md).
For Terraform patterns and modules, see [references/terraform-patterns.md](references/terraform-patterns.md).
