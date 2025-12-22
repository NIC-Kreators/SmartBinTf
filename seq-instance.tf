resource "aws_security_group" "seq_sg" {
  name   = "seq-sg"
  vpc_id = aws_vpc.smart_bin_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5341
    to_port     = 5341
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
    Name = "seq-sg"
  }
}

resource "aws_eip" "seq_ip" {
  instance = aws_instance.seq_instance.id
  domain   = "vpc"

  tags = {
    Name = "seq-ip"
  }
}

resource "aws_instance" "seq_instance" {
  ami             = data.aws_ami.amazon_linux_2023_arm.id
  instance_type   = var.seq_instance_type
  subnet_id       = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.seq_sg.id]

  user_data = file("${path.module}/seq-user-data.sh")

  tags = {
    Name = "seq-instance"
  }
}
