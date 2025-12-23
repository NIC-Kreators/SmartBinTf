# Smart Bin Infrastructure

A comprehensive, production-ready Terraform infrastructure for deploying a Smart Bin IoT system on AWS. This project provisions a complete cloud infrastructure with modern container orchestration, service mesh capabilities, and comprehensive observability.

## 🏗️ Architecture Overview

The Smart Bin infrastructure leverages AWS best practices with:

- **🌐 VPC & Networking**: Multi-AZ VPC with public/private subnets and secure routing
- **🐳 ECS with Service Connect**: Modern container orchestration with service mesh capabilities
- **📊 DocumentDB**: MongoDB-compatible database with high availability
- **📡 MQTT Messaging**: RabbitMQ broker for IoT device communication
- **📝 Centralized Logging**: Seq instance with structured log management
- **🔍 Observability**: OpenTelemetry collector with CloudWatch and X-Ray integration
- **🚀 Container Registry**: ECR with automated lifecycle management
- **⚖️ Load Balancing**: Application Load Balancer with health checks and access logging

## 📁 Refactored Project Structure

The infrastructure has been completely refactored for better maintainability and organization:

```
├── bootstrap/                    # S3 backend setup (run first)
├── global/                      # Global IAM roles for GitHub Actions
│
├── ecs-cluster.tf              # ECS cluster with Service Connect
├── ecs-iam.tf                  # All IAM roles and policies
├── ecs-api-service.tf          # API service configuration
├── ecs-otel-service.tf         # OTEL collector service
├── ecs-ec2.tf                  # Auto Scaling Group and launch template
├── load-balancer.tf            # ALB, target groups, and access logs
│
├── vpc.tf                      # VPC and networking
├── documentdb.tf               # DocumentDB cluster
├── mqtt-broker.tf              # RabbitMQ MQTT broker
├── seq-instance.tf             # Seq logging server
├── observability.tf            # CloudWatch dashboard
├── api-ecr.tf                  # Container registry
│
├── variables.tf                # Input variables
├── locals.tf                   # Computed values with Service Connect
├── data.tf                     # Data sources
├── outputs.tf                  # Output values
├── terraform.tfvars            # Environment configuration
├── secrets.tfvars              # Sensitive variables (not in git)
│
├── ecs.tf                      # Legacy file (content moved)
├── update-seq-api-key.sh       # Helper script for Seq setup
└── REFACTORING_SUMMARY.md      # Detailed refactoring notes
```

## ✨ Key Features & Improvements

### 🔗 ECS Service Connect Integration

- **Simplified Service Discovery**: Services communicate using simple DNS names
- **Automatic Load Balancing**: Built-in load balancing between service instances
- **Enhanced Observability**: Service Connect logs and metrics
- **Better Fault Tolerance**: Automatic health checking and failover

### 📦 Organized Components

- **Separated Concerns**: Each component in its own logical file
- **Dedicated IAM Management**: All roles and policies centralized
- **Service-Specific Configuration**: Easier maintenance and updates
- **Enhanced Security**: Proper security group rules for Service Connect

## 🚀 Quick Start

### 1. Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.12 installed
- Docker (for building and pushing container images)
- jq (for the Seq API key update script)

### 2. Bootstrap (First Time Only)

Set up the Terraform state backend:

```bash
cd bootstrap
terraform init
terraform apply
cd ..
```

### 3. Global Resources

Deploy GitHub Actions IAM roles:

```bash
cd global
terraform init
terraform apply
cd ..
```

### 4. Main Infrastructure

Deploy the Smart Bin infrastructure:

```bash
# Copy and configure secrets
cp secrets.tfvars.example secrets.tfvars
# Edit secrets.tfvars with your values

# Deploy infrastructure
terraform init
terraform apply -var-file="secrets.tfvars"
```

### 5. Seq API Key Setup

After initial deployment, configure the Seq API key:

1. **Access Seq UI**: Use the `seq_web_interface` output URL
2. **Create API Key**: Go to Settings → API Keys and create a new key
3. **Update Secret**: Run the helper script:

   ```bash
   ./update-seq-api-key.sh "your-seq-api-key-here"
   ```

## ⚙️ Configuration

### Required Variables (terraform.tfvars)

```hcl
aws_region = "eu-central-1"
project_name = "SmartBin"
environment = "Production"

vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

seq_instance_type = "t4g.small"
```

### Sensitive Variables (secrets.tfvars)

```hcl
# MQTT Broker
rmq_username = "your-mqtt-username"
rmq_password = "your-secure-password"

# DocumentDB
docdb_username = "admin"
docdb_password = "your-secure-db-password"

# Application Secrets
jwt_secret = "your-jwt-signing-secret"
seq_api_key = ""  # Leave empty initially, update after Seq deployment
```

### Optional Variables

```hcl
# ECS Configuration
api_memory = 512
api_desired_count = 1
api_container_port = 8080
otel_memory = 512

# EC2 Configuration
ecs_instance_type = "t3.small"
ecs_desired_capacity = 1
ecs_min_capacity = 1
ecs_max_capacity = 3
enable_ssh_access = false  # Set to true for debugging
```

## 🏗️ Infrastructure Components

### 🐳 Container Platform

**ECS Cluster (`ecs-cluster.tf`)**

- Service Connect enabled for simplified service discovery
- Container Insights for enhanced monitoring
- Capacity providers for automatic scaling

**API Service (`ecs-api-service.tf`)**

- .NET API with health checks
- Service Connect integration
- Secrets Manager integration
- CloudWatch logging

**OTEL Collector (`ecs-otel-service.tf`)**

- OpenTelemetry collector for observability
- Multiple port mappings (gRPC, HTTP, metrics)
- Service Connect endpoints for easy access
- CloudWatch and Seq integration

**EC2 Auto Scaling (`ecs-ec2.tf`)**

- Launch template with ECS-optimized AMI
- Auto Scaling Group with health checks
- Security groups optimized for Service Connect
- Optional SSH access

### ⚖️ Load Balancing (`load-balancer.tf`)

- **Application Load Balancer**: HTTP traffic distribution
- **Target Groups**: Health checks and routing
- **Access Logs**: S3 bucket with lifecycle policies
- **Security Groups**: Proper ingress/egress rules

### 🗄️ Database (`documentdb.tf`)

- **DocumentDB Cluster**: MongoDB-compatible with encryption
- **Multi-AZ Deployment**: High availability
- **Automated Backups**: Configurable retention
- **VPC Security**: Private subnet isolation

### 📡 MQTT Broker (`mqtt-broker.tf`)

- **RabbitMQ Engine**: Version 3.11.20 on mq.t3.micro
- **Public Access**: Internet-facing for IoT devices
- **Authentication**: Username/password based
- **Custom Configuration**: MQTT-optimized settings

### 📝 Logging (`seq-instance.tf`)

- **Seq Server**: Containerized on Amazon Linux 2023
- **Persistent Storage**: EBS volume for data
- **Web Interface**: Port 80 for UI access
- **Log Ingestion**: Port 5341 for OTLP

### 🔍 Observability (`observability.tf`)

- **CloudWatch Dashboard**: ECS metrics and application insights
- **Service Connect Logs**: Inter-service communication monitoring
- **Custom Metrics**: Application-specific monitoring

## 🌐 Service Connect Architecture

### Service Discovery Made Simple

| Service | Discovery Name | Client Alias | Port |
|---------|---------------|--------------|------|
| API | `api` | `api:8080` | 8080 |
| OTEL Collector (HTTP) | `otel-collector-http` | `otel-collector:4318` | 4318 |
| OTEL Collector (gRPC) | `otel-collector-grpc` | `otel-collector:4317` | 4317 |
| OTEL Metrics | `otel-collector-metrics` | `otel-collector-metrics:9696` | 9696 |

### Benefits

- **🔄 Automatic Load Balancing**: Between service instances
- **🏥 Health Checking**: Built-in health monitoring
- **📊 Observability**: Service Connect logs and metrics
- **🛡️ Fault Tolerance**: Automatic failover and retry
- **🎯 Simplified Configuration**: No complex DNS setup required

## 📊 Application Configuration

The .NET API is automatically configured with:

### Environment Variables

```bash
# ASP.NET Core
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://0.0.0.0:8080

# Database
MongoDB__ConnectionString=mongodb://docdb-endpoint:27017/...
MongoDB__DatabaseName=SmartBinDatabase

# Authentication (from Secrets Manager)
Jwt__Key=***
MongoDB__Username=***
MongoDB__Password=***

# OTEL Integration (Service Connect)
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
OTEL_SERVICE_NAME=SmartBin.Api
Serilog__WriteTo__1__Args__Endpoint=http://otel-collector:4318
```

## 🔐 Security Features

- **🌐 Network Isolation**: Private subnets for internal services
- **🛡️ Security Groups**: Service Connect optimized rules
- **🔒 Encryption**: DocumentDB, ECR, Secrets Manager encrypted
- **🔑 Secrets Management**: AWS Secrets Manager integration
- **👤 IAM**: Principle of least privilege
- **🔐 TLS**: Required for DocumentDB connections
- **📝 Access Logs**: ALB logs with lifecycle management

## 📈 Monitoring & Observability

### Built-in Monitoring

- **📊 CloudWatch Metrics**: ECS, ALB, and custom application metrics
- **🔍 X-Ray Tracing**: Distributed tracing across services
- **📝 Structured Logging**: Serilog with OTEL integration
- **🏥 Health Checks**: Container and load balancer health monitoring
- **🔗 Service Connect Logs**: Inter-service communication monitoring

### Dashboards

- **ECS Service Metrics**: CPU, memory, task count
- **API Metrics**: Request rates, response times, errors
- **Service Connect**: Communication patterns and health
- **Infrastructure**: Load balancer, Auto Scaling Group metrics

## 💰 Cost Optimization

### Estimated Monthly Costs (eu-central-1)

- **DocumentDB (db.t3.medium)**: ~$50/month
- **ECS EC2 (t3.small)**: ~$15/month
- **Application Load Balancer**: ~$20/month
- **RabbitMQ (mq.t3.micro)**: ~$13/month
- **Seq Instance (t4g.small)**: ~$13/month
- **ECR Storage**: Pay per GB stored
- **Data Transfer**: Varies by usage

### Cost Optimization Tips

- Use Reserved Instances for predictable workloads
- Consider Spot Instances for non-critical services
- Implement lifecycle policies for logs and images
- Right-size instances based on actual usage
- Monitor and optimize data transfer costs

## 🔧 Troubleshooting

### Common Issues

**Service Connect Communication**

```bash
# Test service connectivity from within a container
curl http://otel-collector:4318/health
curl http://api:8080/health
```

**ECS Service Issues**

```bash
# Check service status
aws ecs describe-services --cluster smartbin-cluster --services smartbin-api-service

# View service events
aws ecs describe-services --cluster smartbin-cluster --services smartbin-api-service \
  --query 'services[0].events[0:5]'
```

**Container Logs**

```bash
# API logs
aws logs tail /ecs/smartbin-api --follow

# OTEL collector logs
aws logs tail /ecs/smartbin-otel-collector --follow

# Service Connect logs
aws logs tail /ecs/smartbin-service-connect --follow
```

### Useful Commands

```bash
# Force new deployment
aws ecs update-service --cluster smartbin-cluster \
  --service smartbin-api-service --force-new-deployment

# Scale service
aws ecs update-service --cluster smartbin-cluster \
  --service smartbin-api-service --desired-count 2

# Check Auto Scaling Group
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names smartbin-ecs-asg

# Update Seq API key
./update-seq-api-key.sh "your-new-api-key"
```

## 📋 Outputs

After deployment, you'll receive comprehensive outputs:

```bash
# Service Endpoints
api_url = "http://smartbin-alb-xxxxx.eu-central-1.elb.amazonaws.com"
seq_web_interface = "http://x.x.x.x"
mqtt_broker_console_url = "https://b-xxxxx.mq.region.amazonaws.com"

# Service Connect Endpoints
api_service_connect_endpoint = "api:8080"
otel_collector_endpoint_http = "otel-collector:4318"
otel_collector_endpoint_grpc = "otel-collector:4317"
service_connect_namespace = "smartbin.local"

# Infrastructure Details
vpc_id = "vpc-xxxxx"
ecs_cluster_name = "smartbin-cluster"
ecr_repository_url = "account.dkr.ecr.region.amazonaws.com/smart-bin-api"
docdb_cluster_endpoint = "smartbin-docdb.cluster-xxxxx.docdb.region.amazonaws.com"
```

## 🚀 Deployment Pipeline

The infrastructure supports modern CI/CD practices:

- **GitHub Actions Integration**: Automated Terraform workflows
- **State Management**: S3 backend with DynamoDB locking
- **Plan Generation**: Automatic plan generation on PRs
- **Automated Deployment**: Deploy on main branch merge
- **Container Updates**: ECS service updates trigger new deployments

**Built with ❤️ using Terraform and AWS best practices**
