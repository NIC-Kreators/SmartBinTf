# Data source for ECS-optimized AMI
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

# EC2 Launch Template for ECS
resource "aws_launch_template" "ecs" {
  name_prefix   = "${lower(var.project_name)}-ecs-"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = var.ecs_instance_type

  vpc_security_group_ids = [aws_security_group.ecs_instances.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  user_data = base64encode(templatefile("${path.module}/ecs-user-data.sh", {
    cluster_name = aws_ecs_cluster.main.name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-ecs-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ecs" {
  name                      = "${lower(var.project_name)}-ecs-asg"
  vpc_zone_identifier       = aws_subnet.public[*].id
  target_group_arns         = [aws_lb_target_group.api.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  min_size                  = var.ecs_min_capacity
  max_size                  = var.ecs_max_capacity
  desired_capacity          = var.ecs_desired_capacity
  protect_from_scale_in     = true

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  # Instance refresh configuration
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300  # Reduce warmup time
      max_healthy_percentage = 200  # Allow more instances during refresh
    }
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = false
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ecs-asg"
    propagate_at_launch = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for ECS Instances
resource "aws_security_group" "ecs_instances" {
  name        = "${lower(var.project_name)}-ecs-instances-sg"
  description = "Security group for ECS instances"
  vpc_id      = aws_vpc.smart_bin_vpc.id

  # Dynamic port range for ALB health checks and traffic
  ingress {
    description     = "Dynamic ports from ALB"
    from_port       = 32768
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Service Connect traffic between containers
  ingress {
    description = "Service Connect traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # SSH access (optional - consider restricting to specific IPs)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.enable_ssh_access ? ["0.0.0.0/0"] : []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-instances-sg"
  }
}
