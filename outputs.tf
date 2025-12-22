# VPC Outputs
output "vpc_id" {
  description = "ID of the Smart Bin VPC"
  value       = aws_vpc.smart_bin_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the Smart Bin VPC"
  value       = aws_vpc.smart_bin_vpc.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.smart_bin_igw.id
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

# Seq Instance Outputs
output "seq_instance_id" {
  description = "ID of the Seq logging instance"
  value       = aws_instance.seq_instance.id
}

output "seq_instance_public_ip" {
  description = "Public IP address of the Seq instance"
  value       = aws_eip.seq_ip.public_ip
}

output "seq_instance_private_ip" {
  description = "Private IP address of the Seq instance"
  value       = aws_instance.seq_instance.private_ip
}

output "seq_web_url" {
  description = "URL to access Seq web interface"
  value       = "http://${aws_eip.seq_ip.public_ip}"
}

output "seq_ingestion_url" {
  description = "URL for Seq log ingestion"
  value       = "http://${aws_eip.seq_ip.public_ip}:5341"
}

output "seq_security_group_id" {
  description = "ID of the Seq security group"
  value       = aws_security_group.seq_sg.id
}

# MQTT Broker Outputs
output "mqtt_broker_id" {
  description = "ID of the MQTT broker"
  value       = aws_mq_broker.mqtt_broker.id
}

output "mqtt_broker_arn" {
  description = "ARN of the MQTT broker"
  value       = aws_mq_broker.mqtt_broker.arn
}

output "mqtt_broker_endpoints" {
  description = "MQTT broker connection endpoints"
  value       = aws_mq_broker.mqtt_broker.instances[*].endpoints
}

output "mqtt_broker_console_url" {
  description = "MQTT broker management console URL"
  value       = aws_mq_broker.mqtt_broker.instances[0].console_url
}

# ECR Repository Outputs
output "ecr_repository_url" {
  description = "URL of the Smart Bin API ECR repository"
  value       = aws_ecr_repository.smart_bin_api_ecr_repo.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the Smart Bin API ECR repository"
  value       = aws_ecr_repository.smart_bin_api_ecr_repo.arn
}

output "ecr_repository_name" {
  description = "Name of the Smart Bin API ECR repository"
  value       = aws_ecr_repository.smart_bin_api_ecr_repo.name
}

# Availability Zones
output "availability_zones" {
  description = "List of availability zones used"
  value       = data.aws_availability_zones.available.names
}


# DocumentDB Outputs
output "docdb_cluster_endpoint" {
  description = "Endpoint for the DocumentDB cluster"
  value       = aws_docdb_cluster.main.endpoint
}

output "docdb_cluster_reader_endpoint" {
  description = "Reader endpoint for the DocumentDB cluster"
  value       = aws_docdb_cluster.main.reader_endpoint
}

output "docdb_cluster_port" {
  description = "Port for the DocumentDB cluster"
  value       = aws_docdb_cluster.main.port
}

output "docdb_cluster_arn" {
  description = "ARN of the DocumentDB cluster"
  value       = aws_docdb_cluster.main.arn
}

output "docdb_connection_string" {
  description = "MongoDB connection string for DocumentDB (without credentials)"
  value       = "mongodb://${aws_docdb_cluster.main.endpoint}:${aws_docdb_cluster.main.port}/?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}


# ECS Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.api.name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "api_url" {
  description = "URL to access the API"
  value       = "http://${aws_lb.main.dns_name}"
}

# OTEL Collector Outputs
output "otel_collector_endpoint_grpc" {
  description = "OTEL Collector gRPC endpoint for applications (Service Connect)"
  value       = "${var.service_definitions.otel_grpc.discovery_name}:${var.service_definitions.otel_grpc.port}"
}

output "otel_collector_endpoint_http" {
  description = "OTEL Collector HTTP endpoint for applications (Service Connect)"
  value       = "${var.service_definitions.otel_http.discovery_name}:${var.service_definitions.otel_http.port}"
}

output "otel_collector_metrics_endpoint" {
  description = "OTEL Collector Prometheus metrics endpoint (Service Connect)"
  value       = "${var.service_definitions.otel_metrics.discovery_name}:${var.service_definitions.otel_metrics.port}"
}

output "service_connect_namespace" {
  description = "Service Connect namespace for inter-service communication"
  value       = aws_service_discovery_private_dns_namespace.main.name
}

output "api_service_connect_endpoint" {
  description = "API service endpoint via Service Connect"
  value       = "${var.service_definitions.api.discovery_name}:${var.service_definitions.api.port}"
}

# Seq Setup Instructions
output "seq_setup_instructions" {
  description = "Instructions for setting up Seq API key"
  value       = <<-EOT
    
    🔧 SEQ SETUP INSTRUCTIONS:
    
    1. Access Seq UI: http://${aws_eip.seq_ip.public_ip}
    2. Create an API key in Seq UI (Settings > API Keys)
    3. Update the secret: ./update-seq-api-key.sh "your-api-key-here"
    
    Note: The API will work without Seq initially, but logs won't be sent to Seq until the API key is configured.
    
  EOT
}

output "seq_web_interface" {
  description = "Seq web interface URL"
  value       = "http://${aws_eip.seq_ip.public_ip}"
}