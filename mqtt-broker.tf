resource "aws_security_group" "mqtt_broker_sg" {
  name        = "${var.project_name}-mqtt-sg"
  description = "Security group for RabbitMQ MQTT broker"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "MQTT"
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MQTTS"
    from_port   = 8883
    to_port     = 8883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  ingress {
    description = "AMQPS"
    from_port   = 5671
    to_port     = 5671
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RabbitMQ Web Console"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "smart-bin-mqtt-sg"
  }
}

resource "aws_mq_broker" "mqtt_broker" {
  broker_name        = "${lower(var.project_name)}-mqtt"
  engine_type        = "RabbitMQ"
  engine_version     = "3.13"
  host_instance_type = "mq.t3.micro"
  deployment_mode    = "SINGLE_INSTANCE"

  subnet_ids          = [aws_subnet.public[0].id]
  publicly_accessible = true
  security_groups = [ aws_security_group.mqtt_broker_sg.id ]

  configuration {
    id       = aws_mq_configuration.rabbitmq_config.id
    revision = aws_mq_configuration.rabbitmq_config.latest_revision
  }

  user {
    username = var.rmq_username
    password = var.rmq_password
  }

  auto_minor_version_upgrade = true

  maintenance_window_start_time {
    day_of_week = "MONDAY"
    time_of_day = "18:00"
    time_zone   = "UTC"
  }

  apply_immediately = true

  tags = {
    Name = "smart-bin-mqtt"
  }
}

resource "aws_mq_configuration" "rabbitmq_config" {
  description    = "RabbitMQ MQTT Configuration"
  name           = "rabbitmq-mqtt-broker"
  engine_type    = "RabbitMQ"
  engine_version = "3.13"

  data = <<DATA
# Default RabbitMQ delivery acknowledgement timeout is 30 minutes in milliseconds
consumer_timeout = 1800000
DATA
}
