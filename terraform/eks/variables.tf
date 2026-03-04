variable "aws_region" {
    description = "AWS region"
    type = string
}

variable "name" {
    description = "Name"
    type = string
}

variable "cidr_block" {
    description = "CIDR block"
    type = list(string)
}

variable "external_dns" {
    description = "external-dns name"
    type = string
}

# variable "addon_name" {
#     description = "Addon name"
#     type = string
# }

# variable "addon_version" {
#     description = "Addon version"
#     type = string
# }