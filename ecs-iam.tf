# ECS Service Linked Role (use existing one)
data "aws_iam_role" "ecs_service_linked_role" {
  name = "AWSServiceRoleForECS"
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  name = "${lower(var.project_name)}-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.project_name}-ecs-task-execution"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (for API to access AWS services)
resource "aws_iam_role" "ecs_task_api" {
  name = "${lower(var.project_name)}-ecs-task-api"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.project_name}-ecs-task-api"
  }
}

# ECS Task Role for OTEL Collector
resource "aws_iam_role" "ecs_task_otel" {
  name = "${lower(var.project_name)}-ecs-task-otel"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.project_name}-ecs-task-otel"
  }
}

# IAM Policy for OTEL Collector
resource "aws_iam_role_policy" "otel_collector" {
  name = "${lower(var.project_name)}-otel-collector-policy"
  role = aws_iam_role.ecs_task_otel.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "ssm:GetParameters",
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for ECS Instances
resource "aws_iam_role" "ecs_instance" {
  name = "${lower(var.project_name)}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.project_name}-ecs-instance-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${lower(var.project_name)}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance.name
}

# IAM policy for ECS to read Secrets Manager
resource "aws_iam_role_policy" "ecs_secrets_access" {
  name = "${lower(var.project_name)}-ecs-secrets-access"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = [
        aws_secretsmanager_secret.api_secrets.arn
      ]
    }]
  })
}