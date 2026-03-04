name = "tinycloud"
aws_region = "eu-north-1"

vpc_cidr_block = "10.0.0.0/16"

public_subnets = {
  "availability-zone-1a" = {
    az   = "eu-north-1a"
    cidr = "10.0.11.0/24"
  }
  "availability-zone-1b" = {
    az   = "eu-north-1b"
    cidr = "10.0.21.0/24"
  }
}
private_subnets = {
  "availability-zone-2a" = {
    az   = "eu-north-1a"
    cidr = "10.0.12.0/24"
  }
  "availability-zone-3a" = {
    az   = "eu-north-1a"
    cidr = "10.0.13.0/24"
  }
  "availability-zone-2b" = {
    az   = "eu-north-1b"
    cidr = "10.0.22.0/24"
  }
  "availability-zone-3b" = {
    az   = "eu-north-1b"
    cidr = "10.0.23.0/24"
  }
}

route_table = "0.0.0.0/0"