aws_region   = "eu-central-1"
project_name = "Smart-Bin"
environment  = "Production"

vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

seq_instance_type = "t4g.small"

ecs_instance_type = "t3.small"

ecs_min_capacity = 1
ecs_desired_capacity = 2
ecs_max_capacity = 3

enable_ssh_access = false

# ECS Task Configuration
api_memory = 256
api_desired_count = 1
otel_memory = 256
auto_deploy_latest = true