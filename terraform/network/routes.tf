# Internet Gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-igw" 
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route table for public subnets their associations

resource "aws_route_table" "public_rt_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.route_table
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.name}-public-rt-a" 
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table_association" "public_a" {

  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt_a.id

  depends_on = [aws_route_table.public_rt_a]
}

resource "aws_route_table" "public_rt_b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.route_table
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt_b.id

  depends_on = [aws_route_table.public_rt_b]
}
# Route table for private subnets and their associations

resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.route_table
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }
  tags = {
    Name = "${var.name}-private-rt-a" 
  }

  depends_on = [aws_internet_gateway.main, aws_nat_gateway.nat_a]
}

resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.route_table
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }
  tags = {
    Name = "${var.name}-private-rt-b" 
  }
  depends_on = [aws_internet_gateway.main, aws_nat_gateway.nat_b]
}

resource "aws_route_table_association" "private_a" {
  for_each = {
    for key, subnet in aws_subnet.private_subnets :
    key => subnet.id
    if subnet.availability_zone == var.private_subnets["availability-zone-2a"].az
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt_a.id

  depends_on = [aws_route_table.private_rt_a]
}

resource "aws_route_table_association" "private_b" {
  for_each = {
    for key, subnet in aws_subnet.private_subnets :
    key => subnet.id
    if subnet.availability_zone == var.private_subnets["availability-zone-2b"].az
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt_b.id

  depends_on = [aws_route_table.private_rt_b]
}

output "aws_route_table_association_private_a" {
  value = aws_route_table_association.private_a
}