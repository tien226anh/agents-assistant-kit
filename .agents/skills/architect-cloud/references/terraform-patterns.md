# Terraform Patterns

Reusable Terraform patterns for multi-cloud infrastructure.

## Project Structure (recommended)

```
infra/
├── modules/                    # Reusable modules
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   ├── database/
│   └── monitoring/
├── environments/
│   ├── dev/
│   │   ├── main.tf            # Calls modules with dev params
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── production/
└── scripts/
    ├── plan.sh
    └── apply.sh
```

## State Management

### Remote state (always use this)
```hcl
# AWS S3 backend
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "environment/component/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# GCP GCS backend
terraform {
  backend "gcs" {
    bucket = "company-terraform-state"
    prefix = "environment/component"
  }
}

# Azure Blob backend
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "companyterraformstate"
    container_name       = "tfstate"
    key                  = "environment/component/terraform.tfstate"
  }
}
```

## Module Patterns

### Networking module (AWS example)
```hcl
# modules/networking/main.tf
variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "environment" {
  type = string
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-public-${count.index}"
    Type = "public"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 10)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-private-${count.index}"
    Type = "private"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
```

### Using modules
```hcl
# environments/production/main.tf
module "networking" {
  source = "../../modules/networking"

  cidr_block         = "10.0.0.0/16"
  environment        = "production"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "database" {
  source = "../../modules/database"

  environment    = "production"
  vpc_id         = module.networking.vpc_id
  subnet_ids     = module.networking.private_subnet_ids
  instance_class = "db.r6g.xlarge"
  multi_az       = true
}
```

## Common Patterns

### Data source for existing resources
```hcl
# Reference existing VPC
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["production-vpc"]
  }
}

# Reference current AWS account
data "aws_caller_identity" "current" {}

# Reference current region
data "aws_region" "current" {}
```

### Dynamic blocks
```hcl
resource "aws_security_group" "app" {
  name   = "${var.environment}-app-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
}
```

### Conditional resources
```hcl
resource "aws_cloudwatch_metric_alarm" "cpu" {
  count = var.environment == "production" ? 1 : 0

  alarm_name = "${var.environment}-high-cpu"
  # ... alarm config
}
```

## Workflow

```bash
# Initialize (first time or after backend change)
terraform init

# Format
terraform fmt -recursive

# Validate
terraform validate

# Plan (always review before apply)
terraform plan -out=plan.tfplan

# Apply
terraform apply plan.tfplan

# Destroy (careful!)
terraform destroy

# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Show state
terraform state list
terraform state show aws_instance.web
```

## Anti-Patterns to Avoid

1. **No remote state**: Local `.tfstate` files get lost, can't collaborate
2. **Monolithic config**: One giant `main.tf` — split into modules
3. **Hardcoded values**: Use variables and tfvars files
4. **No state locking**: Concurrent applies corrupt state
5. **Manual changes**: Everything through Terraform, never the console
6. **Secrets in tfvars**: Use environment variables or secret managers
7. **`terraform apply` without plan**: Always review the plan first
