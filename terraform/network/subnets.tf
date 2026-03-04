# Subnets

resource "aws_subnet" "public_subnet_a" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnets["availability-zone-1a"].cidr
    availability_zone = var.public_subnets["availability-zone-1a"].az
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.name}-public-subnet-${var.public_subnets["availability-zone-1a"].az}"
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/eks-cluster-${var.name}" = "shared"
    }
}

resource "aws_subnet" "public_subnet_b" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnets["availability-zone-1b"].cidr
    availability_zone = var.public_subnets["availability-zone-1b"].az
    map_public_ip_on_launch = true
    
    tags = {
        Name = "${var.name}-public-subnet-${var.public_subnets["availability-zone-1b"].az}"
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/eks-cluster-${var.name}" = "shared"
    }
}

resource "aws_subnet" "private_subnets" {
    for_each = var.private_subnets
    vpc_id = aws_vpc.main.id
    cidr_block = each.value.cidr
    availability_zone = each.value.az

    tags = {
        Name = "${var.name}-private-subnet-${each.key}"
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/eks-cluster-${var.name}" = "shared"
    }
}

output "private_subnets_ids_az_a" {
    value = [
        for subnet in aws_subnet.private_subnets :
        subnet.id if subnet.availability_zone == var.private_subnets["availability-zone-2a"].az
    ]
}

output "private_subnets_ids_az_b" {
    value = [
        for subnet in aws_subnet.private_subnets :
        subnet.id if subnet.availability_zone == var.private_subnets["availability-zone-2b"].az
    ]
}

output "public_subnet_ids" {
    value = [aws_subnet.public_subnet_a.id]
}

output "public_subnet_ids_az_b" {
    value = [aws_subnet.public_subnet_b.id]
}