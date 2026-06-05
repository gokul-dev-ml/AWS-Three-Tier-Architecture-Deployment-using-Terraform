# AWS Three-Tier Architecture Deployment using Terraform

## Overview

This project provisions a production-style **Three-Tier Architecture on AWS** using **Terraform**. The infrastructure follows industry best practices by separating the application into distinct Web, Application, and Database layers while incorporating high availability, security, scalability, and infrastructure-as-code principles.

The deployment includes:

* Custom VPC with public and private subnets
* Internet Gateway and NAT Gateway
* External and Internal Application Load Balancers
* Bastion Host for secure administrative access
* Web Tier EC2 Instances
* Application Tier EC2 Instances
* Amazon RDS MySQL Database
* Security Groups implementing least-privilege access
* Remote Terraform State Management using Amazon S3
* State Locking for team collaboration

---

## Architecture

```text
Internet
    │
    ▼
External Application Load Balancer
    │
    ▼
Web Tier EC2 Instances
(Public Subnets)
    │
    ▼
Internal Application Load Balancer
    │
    ▼
Application Tier EC2 Instances
(Private App Subnets)
    │
    ▼
Amazon RDS MySQL
(Private Database Subnets)
```

### Network Components

* 1 VPC
* 2 Public Subnets (Multi-AZ)
* 2 Private Application Subnets (Multi-AZ)
* 2 Private Database Subnets (Multi-AZ)
* Internet Gateway
* NAT Gateway
* Public Route Table
* Private Application Route Table
* Private Database Route Table

---

## Technologies Used

* Terraform
* AWS VPC
* AWS EC2
* AWS Application Load Balancer (ALB)
* AWS RDS MySQL
* AWS Security Groups
* AWS Internet Gateway
* AWS NAT Gateway
* AWS S3 Backend
* AWS IAM

---

## Infrastructure Components

### Networking Layer

* Custom VPC (`10.0.0.0/16`)
* DNS support enabled
* Multi-AZ subnet deployment
* Internet-facing and private routing configuration

### Security Layer

#### Bastion Host Security Group

Allows:

* SSH (Port 22) only from administrator IP

#### External ALB Security Group

Allows:

* HTTP (80)
* HTTPS (443)

#### Web Tier Security Group

Allows:

* HTTP traffic from External ALB
* SSH access from Bastion Host

#### Internal ALB Security Group

Allows:

* HTTP traffic from Web Tier

#### Application Tier Security Group

Allows:

* Application traffic (8080) from Internal ALB
* SSH access from Bastion Host

#### Database Security Group

Allows:

* MySQL traffic (3306) only from Application Tier

---

## High Availability Features

* Multi-AZ subnet architecture
* External ALB deployed across multiple Availability Zones
* Internal ALB deployed across multiple Availability Zones
* Multiple Web Tier instances
* Multiple Application Tier instances
* Optional Multi-AZ RDS deployment for Production environments

```hcl
multi_az = var.environment == "prod" ? true : false
```

---

## Terraform Backend Configuration

Terraform state is stored remotely in Amazon S3.

```hcl
terraform {
  backend "s3" {
    bucket       = "gokul-three-tier-tfstate-2026"
    key          = "infra/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
    encrypt      = true
  }
}
```

### Benefits

* Centralized state management
* Team collaboration
* State locking
* State file encryption
* Disaster recovery

---

## Project Structure

```text
.
├── backend.tf
├── provider.tf
├── variable.tf
├── vpc.tf
├── security_group.tf
├── ec2.tf
├── alb.tf
├── rds.tf
├── output.tf
└── README.md
```

---

## Deployment Steps

### 1. Clone Repository

```bash
git clone <repository-url>
cd aws-three-tier-architecture
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Validate Configuration

```bash
terraform validate
```

### 4. Review Execution Plan

```bash
terraform plan
```

### 5. Deploy Infrastructure

```bash
terraform apply
```

---

## Variables

| Variable          | Description                               |
| ----------------- | ----------------------------------------- |
| project           | Project name prefix                       |
| environment       | Deployment environment (dev/staging/prod) |
| key_name          | EC2 Key Pair Name                         |
| admin_ip          | Public IP allowed for Bastion SSH         |
| web_instance_type | Web Tier EC2 instance type                |
| app_instance_type | Application Tier EC2 instance type        |
| db_instance_class | RDS instance type                         |
| db_name           | Initial database name                     |
| db_username       | Database username                         |
| db_password       | Database password                         |

---

## Outputs

After deployment Terraform provides:

| Output            | Description                            |
| ----------------- | -------------------------------------- |
| external_alb_dns  | Public DNS of External Load Balancer   |
| internal_alb_dns  | Internal DNS of Internal Load Balancer |
| bastion_public_ip | Bastion Host Public IP                 |
| rds_endpoint      | MySQL Database Endpoint                |
| vpc_id            | Created VPC ID                         |

---

## Security Best Practices Implemented

* Private Application Tier
* Private Database Tier
* Security Group based communication
* Bastion-only administrative access
* Encrypted Terraform state
* Environment-aware database protection
* Restricted database access
* Least privilege network design

---

## Production Features

* Multi-AZ Deployment
* Internal Load Balancing
* Remote State Management
* Environment-based Configuration
* Database Backup Retention
* Deletion Protection
* Infrastructure as Code
* Modular Resource Organization

---

## Learning Outcomes

This project demonstrates practical experience with:

* Terraform Infrastructure as Code
* AWS Networking
* Multi-Tier Architecture Design
* Application Load Balancers
* EC2 Deployment Automation
* Amazon RDS Management
* Security Group Design
* Remote State Management
* High Availability Architectures
* Cloud Infrastructure Automation

---

