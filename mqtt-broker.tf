resource "aws_mq_broker" "mqtt_broker" {
  broker_name        = "${lower(var.project_name)}-mqtt"
  engine_type        = "RabbitMQ"
  engine_version     = "3.13"
  host_instance_type = "mq.t3.micro"
  deployment_mode    = "SINGLE_INSTANCE"

  subnet_ids          = [aws_subnet.public[0].id]
  publicly_accessible = true

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
