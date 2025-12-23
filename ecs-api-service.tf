# CloudWatch Log Group for API
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${lower(var.project_name)}-api"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-api-logs"
  }
}

# ECS Task Definition for API
resource "aws_ecs_task_definition" "api" {
  family             = "${lower(var.project_name)}-api"
  network_mode       = "bridge"
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task_api.arn

  container_definitions = jsonencode([{
    name  = "${lower(var.project_name)}-api"
    image = "${aws_ecr_repository.smart_bin_api_ecr_repo.repository_url}:${local.image_tag}"

    portMappings = [{
      name          = var.service_definitions.api.port_name
      containerPort = var.service_definitions.api.port
      protocol      = "tcp"
    }]

    environment = local.api_env_vars

    secrets = [
      { name = "MongoDB__Username", valueFrom = "${aws_secretsmanager_secret.api_secrets.arn}:MONGODB_USERNAME::" },
      { name = "MongoDB__Password", valueFrom = "${aws_secretsmanager_secret.api_secrets.arn}:MONGODB_PASSWORD::" },
      { name = "Jwt__Key", valueFrom = "${aws_secretsmanager_secret.api_secrets.arn}:JWT_SECRET::" }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.api.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }

    memory    = var.api_memory
    essential = true

    healthCheck = {
      command = [
        "CMD-SHELL",
        "curl -f http://localhost:${var.service_definitions.api.port}${var.api_health_check_path} || exit 1"
      ]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 120  # Increased start period
    }
  }])

  tags = {
    Name = "${var.project_name}-api-task"
  }
}

# ECS Service for API with Service Connect
resource "aws_ecs_service" "api" {
  name            = "${lower(var.project_name)}-api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.api_desired_count

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "${lower(var.project_name)}-api"
    container_port   = var.service_definitions.api.port
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn

    service {
      port_name      = var.service_definitions.api.port_name
      discovery_name = var.service_definitions.api.discovery_name
      client_alias {
        port     = var.service_definitions.api.port
        dns_name = var.service_definitions.api.discovery_name
      }
    }

    log_configuration {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.service_connect.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "service-connect"
      }
    }
  }

  enable_execute_command = true

  depends_on = [aws_lb_listener.http]

  tags = {
    Name = "${var.project_name}-api-service"
  }
}

# CloudWatch Log Group for Service Connect
resource "aws_cloudwatch_log_group" "service_connect" {
  name              = "/ecs/${lower(var.project_name)}-service-connect"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-service-connect-logs"
  }
}

# Secrets Manager for API secrets
resource "aws_secretsmanager_secret" "api_secrets" {
  name        = "${lower(var.project_name)}-api-secrets"
  description = "API secrets for ${var.project_name}"

  tags = {
    Name = "${var.project_name}-api-secrets"
  }
}

resource "aws_secretsmanager_secret_version" "api_secrets" {
  secret_id = aws_secretsmanager_secret.api_secrets.id
  secret_string = jsonencode({
    MONGODB_USERNAME = var.docdb_username
    MONGODB_PASSWORD = var.docdb_password
    SEQ_API_KEY      = var.seq_api_key != "" ? var.seq_api_key : "placeholder-update-after-seq-deployment"
    JWT_SECRET       = var.jwt_secret
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}