resource "aws_internet_gateway" "smart_bin_igw" {
  vpc_id = aws_vpc.smart_bin_vpc.id
  tags = {
    Name = "${lower(var.project_name)}-igw"
  }
}
