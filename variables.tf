variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region to deploy resources in"
}

variable "project_name" {
  type        = string
  description = "The project name"
}

variable "environment" {
  type        = string
  description = "The current project's environemnt"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for project's VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "The CIDR blocks for all public subnets within the VPC"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "The CIDR blocks for all private subnets within the VPC"
}

variable "seq_instance_type" {
  type        = string
  description = "The type of EC2, where Seq will be deployeds"
}

variable "rmq_username" {
  type        = string
  description = "The username for MQTT broker"
  sensitive   = true
}

variable "rmq_password" {
  type        = string
  description = "The password for MQTT broker"
  sensitive   = true
}

variable "docdb_username" {
  type        = string
  description = "Master username for DocumentDB cluster"
  sensitive   = true
}

variable "docdb_password" {
  type        = string
  description = "Master password for DocumentDB cluster"
  sensitive   = true
}

variable "docdb_instance_class" {
  type        = string
  default     = "db.t3.medium"
  description = "Instance class for DocumentDB instances"
}

variable "docdb_instance_count" {
  type        = number
  default     = 1
  description = "Number of DocumentDB instances in the cluster"
}

variable "docdb_backup_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain backups"
}

variable "api_container_port" {
  type        = number
  default     = 8080
  description = "Port the API listens on (deprecated - use service_definitions.api.port instead)"
}

variable "api_memory" {
  type        = number
  default     = 512
  description = "Memory reservation for container on EC2 (MB)"
}

variable "api_desired_count" {
  type        = number
  default     = 1
  description = "Number of ECS tasks to run"
}

variable "api_image_tag" {
  type        = string
  default     = "latest"
  description = "Docker image tag to deploy"
}

variable "auto_deploy_latest" {
  type        = bool
  default     = false
  description = "Automatically deploy latest image tag from ECR"
}

variable "api_health_check_path" {
  type        = string
  default     = "/health"
  description = "Health check endpoint path"
}

variable "ecs_instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type for ECS cluster"
}

variable "ecs_min_capacity" {
  type        = number
  default     = 1
  description = "Minimum number of EC2 instances"
}

variable "ecs_max_capacity" {
  type        = number
  default     = 3
  description = "Maximum number of EC2 instances"
}

variable "ecs_desired_capacity" {
  type        = number
  default     = 1
  description = "Desired number of EC2 instances"
}

variable "api_metrics_port" {
  type        = number
  default     = 9696
  description = "Port where OTEL collector exposes Prometheus metrics (deprecated - use service_definitions.otel_metrics.port instead)"
}

variable "seq_api_key" {
  type        = string
  description = "Seq API key for log ingestion (leave empty initially, update after Seq deployment)"
  default     = ""
  sensitive   = true
}

variable "jwt_secret" {
  type        = string
  description = "JWT secret for application authentication"
  sensitive   = true
}

variable "otel_memory" {
  type        = number
  default     = 512
  description = "Memory reservation for OTEL collector container (MB)"
}

variable "enable_ssh_access" {
  type        = bool
  default     = false
  description = "Enable SSH access to ECS instances (set to false for production)"
}

variable "service_definitions" {
  type = map(object({
    port_name      = string
    discovery_name = string
    port           = number
  }))
  description = "Service Connect service definitions for inter-service communication"
  default = {
    api = {
      port_name      = "api-http"
      discovery_name = "api"
      port           = 8080
    }
    otel_grpc = {
      port_name      = "otlp-grpc"
      discovery_name = "otel-collector-grpc"
      port           = 4317
    }
    otel_http = {
      port_name      = "otlp-http"
      discovery_name = "otel-collector-http"
      port           = 4318
    }
    otel_metrics = {
      port_name      = "prometheus"
      discovery_name = "otel-collector-metrics"
      port           = 9696
    }
  }
}
