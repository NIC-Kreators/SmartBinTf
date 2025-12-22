# ECS Cluster with Service Connect
resource "aws_ecs_cluster" "main" {
  name = "${lower(var.project_name)}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  service_connect_defaults {
    namespace = aws_service_discovery_private_dns_namespace.main.arn
  }

  tags = {
    Name = "${var.project_name}-cluster"
  }

  depends_on = [data.aws_iam_role.ecs_service_linked_role]
}

# Service Discovery Namespace for Service Connect
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${lower(var.project_name)}.local"
  description = "Private DNS namespace for ${var.project_name} Service Connect"
  vpc         = aws_vpc.smart_bin_vpc.id

  tags = {
    Name = "${var.project_name}-service-connect-namespace"
  }
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "main" {
  name = "${lower(var.project_name)}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "DISABLED"
      target_capacity           = 100
    }
  }

  tags = {
    Name = "${var.project_name}-capacity-provider"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.main.name
  }
}