resource "aws_docdb_subnet_group" "main" {
  name       = "${lower(var.project_name)}-docdb-subnet-group"
  subnet_ids = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-docdb-subnet-group"
  }
}

resource "aws_security_group" "docdb" {
  name        = "${lower(var.project_name)}-docdb-sg"
  description = "Security group for DocumentDB cluster"
  vpc_id      = aws_vpc.smart_bin_vpc.id

  ingress {
    description = "MongoDB port from VPC"
    from_port   = 27017
    to_port     = 27017
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
    Name = "${var.project_name}-docdb-sg"
  }
}

resource "aws_docdb_cluster_parameter_group" "main" {
  family      = "docdb5.0"
  name        = "${lower(var.project_name)}-docdb-params"
  description = "DocumentDB cluster parameter group for ${var.project_name}"

  parameter {
    name  = "tls"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-docdb-params"
  }
}

resource "aws_docdb_cluster" "main" {
  cluster_identifier              = "${lower(var.project_name)}-docdb-cluster"
  engine                          = "docdb"
  master_username                 = var.docdb_username
  master_password                 = var.docdb_password
  backup_retention_period         = var.docdb_backup_retention_period
  preferred_backup_window         = "02:00-04:00"
  preferred_maintenance_window    = "sun:04:00-sun:06:00"
  skip_final_snapshot             = var.environment != "Production"
  final_snapshot_identifier       = var.environment == "Production" ? "${lower(var.project_name)}-docdb-final-snapshot" : null
  db_subnet_group_name            = aws_docdb_subnet_group.main.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
  vpc_security_group_ids          = [aws_security_group.docdb.id]
  storage_encrypted               = true
  deletion_protection             = var.environment == "Production"

  tags = {
    Name = "${var.project_name}-docdb-cluster"
  }
}

resource "aws_docdb_cluster_instance" "main" {
  count              = var.docdb_instance_count
  identifier         = "${lower(var.project_name)}-docdb-instance-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.docdb_instance_class

  tags = {
    Name = "${var.project_name}-docdb-instance-${count.index + 1}"
  }
}
