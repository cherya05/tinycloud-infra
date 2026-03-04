# VPC

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    tags = {
        Name = "${var.name}-vpc"
    }
}

output "vpc_id" {
    value = aws_vpc.main.id
}