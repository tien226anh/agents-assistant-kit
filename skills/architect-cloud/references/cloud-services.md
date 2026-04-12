# Cloud Services Deep Reference

Detailed service patterns for AWS, GCP, and Azure.

## Compute Patterns

### Container Hosting Decision Tree
```
Need Kubernetes specifically?
  → Yes: EKS / GKE / AKS
  → No:
    Stateless HTTP workloads?
      → Yes: Cloud Run / App Runner / Container Apps (simplest)
      → No:
        Long-running background tasks?
          → Yes: ECS Fargate / Cloud Run Jobs / Container Apps Jobs
          → No:
            Short event-driven?
              → Yes: Lambda / Cloud Functions / Azure Functions
```

### Serverless Compute Comparison

| Feature | AWS Lambda | GCP Cloud Functions | Azure Functions |
|---------|-----------|-------------------|-----------------|
| Max timeout | 15 min | 60 min (2nd gen) | 10 min (Consumption) |
| Max memory | 10 GB | 32 GB (2nd gen) | 1.5 GB (Consumption) |
| Cold start | ~100-500ms | ~100-500ms | ~200-1000ms |
| Container support | Yes (images) | Yes (2nd gen) | Yes |
| VPC support | Yes | Yes (2nd gen) | Yes (Premium) |
| Languages | All major | All major | All major |

### Kubernetes Managed Services

**EKS (AWS)**
```bash
# Create cluster
eksctl create cluster --name my-cluster --region us-east-1 \
  --nodegroup-name standard --node-type t3.medium --nodes 3

# Add Fargate profile (serverless nodes)
eksctl create fargateprofile --cluster my-cluster \
  --name fp-default --namespace default
```

**GKE (GCP)**
```bash
# Create Autopilot cluster (recommended — Google manages nodes)
gcloud container clusters create-auto my-cluster \
  --region us-central1

# Standard cluster (you manage nodes)
gcloud container clusters create my-cluster \
  --zone us-central1-a --num-nodes 3 --machine-type e2-medium
```

**AKS (Azure)**
```bash
# Create cluster
az aks create --resource-group myRg --name myCluster \
  --node-count 3 --node-vm-size Standard_D2s_v3 \
  --enable-managed-identity --generate-ssh-keys
```

## Database Patterns

### Managed PostgreSQL

| Feature | RDS/Aurora (AWS) | Cloud SQL / AlloyDB (GCP) | Azure Flexible Server |
|---------|-----------------|--------------------------|----------------------|
| Max size | 128 TB (Aurora) | 64 TB (AlloyDB) | 16 TB |
| Read replicas | 15 (Aurora) | 10 | 10 |
| Auto-scaling storage | Yes | Yes | Yes |
| Serverless | Aurora Serverless v2 | — | Burstable tier |
| High availability | Multi-AZ + Aurora Replicas | Regional (AlloyDB) | Zone-redundant |

### When to use what database
```
Relational data with complex queries?
  → Managed PostgreSQL (RDS / Cloud SQL / Azure Flexible Server)

Key-value with extreme scale?
  → DynamoDB / Bigtable / Cosmos DB

Document store?
  → DocumentDB / Firestore / Cosmos DB

Cache layer?
  → ElastiCache Redis / Memorystore / Azure Cache for Redis

Full-text search?
  → OpenSearch / Elasticsearch (self-managed) / Azure AI Search

Analytics / Data warehouse?
  → Redshift / BigQuery / Synapse

Time-series?
  → Timestream / Bigtable / Azure Data Explorer
```

## Networking

### VPC/VNet Design
```
10.0.0.0/16 (VPC)
├── 10.0.1.0/24 — Public subnet (load balancers, NAT gateways)
├── 10.0.2.0/24 — Public subnet (AZ-b)
├── 10.0.10.0/24 — Private subnet (application servers)
├── 10.0.11.0/24 — Private subnet (AZ-b)
├── 10.0.20.0/24 — Data subnet (databases, caches)
└── 10.0.21.0/24 — Data subnet (AZ-b)
```

**Rules:**
- ALB/NLB in public subnets only
- App servers in private subnets (access internet via NAT Gateway)
- Databases in isolated subnets (no internet access)
- Use VPC endpoints / Private Link for AWS services (avoid NAT costs)

## Messaging & Event Architecture

### SQS / Pub/Sub / Service Bus Patterns
```
Producer → Queue → Consumer (point-to-point)
Producer → Topic → Multiple Subscribers (fan-out)
Producer → Event Bus → Rules → Multiple Targets (event routing)
```

**Dead letter queues (DLQ)**: Always configure a DLQ for failed messages.
```
Main Queue → Consumer (fails) → DLQ → Alert + Manual processing
```

**Idempotency**: Consumers MUST be idempotent. Messages can be delivered more than once.

## Storage Patterns

### S3 / Cloud Storage / Blob Storage
```
Lifecycle policy:
  Day 0-30:   Standard (frequent access)
  Day 31-90:  Infrequent Access
  Day 91-365: Glacier / Nearline / Cool
  Day 366+:   Deep Archive / Coldline / Archive
```

**Security:**
- Block public access by default
- Use bucket policies + IAM (not ACLs)
- Enable versioning for critical data
- Enable server-side encryption (SSE-S3/KMS)
- Enable access logging

## Observability

### Cloud-native monitoring

| Stack | AWS | GCP | Azure |
|-------|-----|-----|-------|
| Metrics | CloudWatch | Cloud Monitoring | Azure Monitor |
| Logs | CloudWatch Logs | Cloud Logging | Log Analytics |
| Traces | X-Ray | Cloud Trace | Application Insights |
| Dashboards | CloudWatch Dashboards | Monitoring Dashboards | Azure Dashboards |

### Alternative: Cloud-agnostic stack
- **Metrics**: Prometheus + Grafana (via Grafana Cloud or self-hosted)
- **Logs**: Loki or Datadog
- **Traces**: Jaeger, Tempo, or Datadog
- **APM**: Datadog, New Relic, or Grafana Cloud
