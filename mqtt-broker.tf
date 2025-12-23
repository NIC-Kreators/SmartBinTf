resource "aws_security_group" "mqtt_broker_sg" {
  name        = "${var.project_name}-mqtt-sg"
  description = "Security group for ActiveMQ MQTT broker"
  vpc_id      = aws_vpc.smart_bin_vpc.id

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
    description = "OpenWire"
    from_port   = 61617
    to_port     = 61617
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "STOMP"
    from_port   = 61614
    to_port     = 61614
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WebSocket"
    from_port   = 61619
    to_port     = 61619
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ActiveMQ Web Console"
    from_port   = 8162
    to_port     = 8162
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
    Name = "${var.project_name}-mqtt-sg"
  }
}

resource "aws_mq_broker" "mqtt_broker" {
  broker_name        = "${lower(var.project_name)}-mqtt"
  engine_type        = "ActiveMQ"
  engine_version     = "5.18"
  host_instance_type = "mq.t3.micro"
  deployment_mode    = "SINGLE_INSTANCE"

  subnet_ids          = [aws_subnet.public[0].id]
  publicly_accessible = true
  security_groups     = [aws_security_group.mqtt_broker_sg.id]

  configuration {
    id       = aws_mq_configuration.activemq_config.id
    revision = aws_mq_configuration.activemq_config.latest_revision
  }

  user {
    username       = var.rmq_username
    password       = var.rmq_password
    console_access = true
  }

  auto_minor_version_upgrade = true

  maintenance_window_start_time {
    day_of_week = "MONDAY"
    time_of_day = "18:00"
    time_zone   = "UTC"
  }

  apply_immediately = true

  tags = {
    Name = "${var.project_name}-mqtt"
  }
}

resource "aws_mq_configuration" "activemq_config" {
  description    = "ActiveMQ MQTT Configuration"
  name           = "${lower(var.project_name)}-activemq-mqtt"
  engine_type    = "ActiveMQ"
  engine_version = "5.18"

  data = <<DATA
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<broker xmlns="http://activemq.apache.org/schema/core">
  <plugins>
    <forcePersistencyModeBrokerPlugin persistenceFlag="true"/>
    <statisticsBrokerPlugin/>
    <timeStampingBrokerPlugin ttlCeiling="86400000" zeroExpirationOverride="86400000"/>
  </plugins>
  <transportConnectors>
    <transportConnector name="mqtt" uri="mqtt://0.0.0.0:1883"/>
    <transportConnector name="mqtt+ssl" uri="mqtt+ssl://0.0.0.0:8883"/>
  </transportConnectors>
</broker>
DATA
}
