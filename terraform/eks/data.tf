data "terraform_remote_state" "aws_vpc" {
    backend = "s3"
    config = {
        bucket = "tinycloud.terraform"
        key    = "terraform/network/.terraform/terraform.tfstate"
        region = "eu-north-1"
    }
}

data "aws_vpc" "main" {
    id = data.terraform_remote_state.aws_vpc.outputs.vpc_id
}

data "aws_subnets" "public_subnets" {
    filter {
        name = "vpc-id"
        values = [data.terraform_remote_state.aws_vpc.outputs.vpc_id]
    }

    filter {
        name   = "tag:kubernetes.io/role/elb"
        values = ["1"]
    }
}

data "aws_subnets" "private_subnets" {
    filter {
        name = "vpc-id"
        values = [data.terraform_remote_state.aws_vpc.outputs.vpc_id]
    }

    filter {
        name   = "tag:kubernetes.io/role/internal-elb"
        values = ["1"]
    }
}

data "tls_certificate" "eks" {
    url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

data "aws_eks_cluster_auth" "main" {
    name = aws_eks_cluster.main.name
}

data "aws_iam_policy_document" "external_dns" {
    statement {
        effect = "Allow"
        actions = ["route53:ChangeResourceRecordSets"]
        resources = ["arn:aws:route53:::hostedzone/*"]
    }

    statement {
        effect = "Allow"
        actions = ["route53:ListHostedZones", "route53:ListResourceRecordSets", "route53:ListTagsForResource"]
        resources = ["*"]
    }
}