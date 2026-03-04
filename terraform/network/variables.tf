variable "aws_region" {
    description = "AWS region"
    type = string
}

variable "vpc_cidr_block" {
    description = "VPC CIDR block"
    type = string
}

variable "public_subnets" {
    type = map(object({
        az = string
        cidr = string
    }
    ))
}

variable "private_subnets" {
    type = map(object({
        az = string
        cidr = string
    }
    ))
}

variable "route_table" {
    description = "Route table"
    type = string
}

variable "name" {
    description = "The name to use for the resources"
    type = string
}