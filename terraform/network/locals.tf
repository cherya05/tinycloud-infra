locals {
  private_subnet_ids_az_a = {
    for k, subnet in aws_subnet.private_subnets :
    k => subnet.id
    if subnet.availability_zone == var.private_subnets["availability-zone-2a"].az
  }

  private_subnet_ids_az_b = {
    for k, subnet in aws_subnet.private_subnets :
    k => subnet.id
    if subnet.availability_zone == var.private_subnets["availability-zone-2b"].az
  }
}