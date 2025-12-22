resource "aws_route_table" "public" {
  vpc_id = aws_vpc.smart_bin_vpc.id

  route {
    gateway_id = aws_internet_gateway.smart_bin_igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "public-subnet-route-table"
  }
}

resource "aws_route_table_association" "public_associations" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
