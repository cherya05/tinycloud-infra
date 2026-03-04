# Elastic IP and NAT

resource "aws_eip" "main" {
    domain = "vpc"

    tags = {
        Name = "${var.name}-elastic-ip-a"
    }
}

resource "aws_eip" "secondary" {
    domain = "vpc"

    tags = {
        Name = "${var.name}-elastic-ip-b"
    }
}

resource "aws_nat_gateway" "nat_a" {
    allocation_id = aws_eip.main.id
    subnet_id = aws_subnet.public_subnet_a.id

    tags = {
        Name = "${var.name}-nat-gw-a"
    }
}

resource "aws_nat_gateway" "nat_b" {
    allocation_id = aws_eip.secondary.id
    subnet_id = aws_subnet.public_subnet_b.id

    tags = {
        Name = "${var.name}-nat-gw-b"
    }
}

output "eip_address_main" {
    value = aws_eip.main.public_ip
}

output "nat_gateway_id" {
    value = aws_nat_gateway.nat_a.id
}

output "eip_address_secondary" {
    value = aws_eip.secondary.public_ip
}

output "nat_gateway_id_b" {
    value = aws_nat_gateway.nat_b.id
}