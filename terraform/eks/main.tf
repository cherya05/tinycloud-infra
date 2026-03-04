terraform {
    backend "s3" {
        bucket = "tinycloud.terraform"
        key = "terraform/eks/.terraform/terraform.tfstate"
        region = "eu-north-1"
    }
}

provider "aws" {
    region = "eu-north-1"
}

provider "kubernetes" {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
}

provider "tls" {
}