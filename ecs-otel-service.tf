# CloudWatch Log Group for OTEL Collector
resource "aws_cloudwatch_log_group" "otel_collector" {
  name              = "/ecs/${lower(var.project_name)}-otel-collector"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-otel-collector-logs"
  }
}

# OTEL Collector Configuration
resource "aws_ssm_parameter" "otel_config" {
  name = "/${lower(var.project_name)}/otel/config"
  type = "String"
  value = yamlencode({
    receivers = {
      otlp = {
        protocols = {
          grpc = {
            endpoint = "0.0.0.0:${var.service_definitions.otel_grpc.port}"
          }
          http = {
            endpoint = "0.0.0.0:${var.service_definitions.otel_http.port}"
          }
        }
      }
    }

    exporters = {
      prometheus = {
        endpoint = "0.0.0.0:${var.service_definitions.otel_metrics.port}"
      }
      "otlphttp/seq" = {
        endpoint = "http://${aws_eip.seq_ip.public_ip}:5341/ingest/otlp"
        headers = var.seq_api_key != "" ? {
          "X-Seq-ApiKey" = var.seq_api_key
        } : {}
        tls = {
          insecure = true
        }
      }
    }

    processors = {
      batch = {
        send_batch_size     = 10000
        send_batch_max_size = 11000
        timeout             = "10s"
      }
    }

    extensions = {
      health_check = {
        endpoint = "0.0.0.0:13133"
      }
      pprof = {
        endpoint = "0.0.0.0:1777"
      }
    }

    service = {
      extensions = ["health_check", "pprof"]
      pipelines = {
        metrics = {
          receivers  = ["otlp"]
          processors = ["batch"]
          exporters  = ["prometheus"]
        }
        traces = {
          receivers  = ["otlp"]
          processors = ["batch"]
          exporters  = ["otlphttp/seq"]
        }
        logs = {
          receivers  = ["otlp"]
          processors = ["batch"]
          exporters  = ["otlphttp/seq"]
        }
      }
    }
  })

  tags = {
    Name = "${var.project_name}-otel-config"
  }
}

# OTEL Collector Task Definition
resource "aws_ecs_task_definition" "otel_collector" {
  family             = "${lower(var.project_name)}-otel-collector"
  network_mode       = "bridge"
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task_otel.arn

  container_definitions = jsonencode([{
    name  = "otel-collector"
    image = "public.ecr.aws/aws-observability/aws-otel-collector:latest"

    portMappings = [
      {
        name          = var.service_definitions.otel_grpc.port_name
        containerPort = var.service_definitions.otel_grpc.port
        protocol      = "tcp"
      },
      {
        name          = var.service_definitions.otel_http.port_name
        containerPort = var.service_definitions.otel_http.port
        protocol      = "tcp"
      },
      {
        name          = var.service_definitions.otel_metrics.port_name
        containerPort = var.service_definitions.otel_metrics.port
        protocol      = "tcp"
      },
      {
        name          = "health-check"
        containerPort = 13133
        protocol      = "tcp"
      }
    ]

    environment = [
      {
        name  = "AOT_CONFIG_CONTENT"
        value = aws_ssm_parameter.otel_config.value
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.otel_collector.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }

    memory    = var.otel_memory
    essential = true

    healthCheck = {
      command = [
        "CMD-SHELL",
        "nc -z localhost 13133 || exit 1"
      ]
      interval    = 30
      timeout     = 10
      retries     = 3
      startPeriod = 120
    }
  }])

  tags = {
    Name = "${var.project_name}-otel-collector-task"
  }
}

# OTEL Collector Service with Service Connect
resource "aws_ecs_service" "otel_collector" {
  name            = "${lower(var.project_name)}-otel-collector"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.otel_collector.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 100
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn

    service {
      port_name      = var.service_definitions.otel_grpc.port_name
      discovery_name = var.service_definitions.otel_grpc.discovery_name
      client_alias {
        port     = var.service_definitions.otel_grpc.port
        dns_name = "otel-collector"
      }
    }

    service {
      port_name      = var.service_definitions.otel_http.port_name
      discovery_name = var.service_definitions.otel_http.discovery_name
      client_alias {
        port     = var.service_definitions.otel_http.port
        dns_name = "otel-collector"
      }
    }

    service {
      port_name      = var.service_definitions.otel_metrics.port_name
      discovery_name = var.service_definitions.otel_metrics.discovery_name
      client_alias {
        port     = var.service_definitions.otel_metrics.port
        dns_name = "otel-collector-metrics"
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

  tags = {
    Name = "${var.project_name}-otel-collector-service"
  }
}