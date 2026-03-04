resource "aws_eks_cluster" "main" {
    name = "eks-cluster-${var.name}"

    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
        subnet_ids                 = concat(data.aws_subnets.private_subnets.ids, data.aws_subnets.public_subnets.ids)
        endpoint_private_access    = true
        endpoint_public_access     = true
        public_access_cidrs        = var.cidr_block
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster_policy,
    ]
}

resource "aws_eks_node_group" "dev" {
    cluster_name    = aws_eks_cluster.main.name
    node_group_name = "node-group-${var.name}-dev"
    node_role_arn  = aws_iam_role.eks_node_group_role.arn
    subnet_ids     = data.aws_subnets.private_subnets.ids

    scaling_config {
        desired_size = 1
        max_size     = 3
        min_size     = 1
    }

    instance_types = ["t3.large"]

    labels = {
        environment = "dev"
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks_worker_node_policy,
        aws_iam_role_policy_attachment.eks_cni_policy,
        aws_iam_role_policy_attachment.eks_container_registry_policy,
    ]
}

resource "aws_eks_node_group" "staging" {
    cluster_name    = aws_eks_cluster.main.name
    node_group_name = "node-group-${var.name}-staging"
    node_role_arn  = aws_iam_role.eks_node_group_role.arn
    subnet_ids     = data.aws_subnets.private_subnets.ids

    scaling_config {
        desired_size = 1
        max_size     = 3
        min_size     = 1
    }

    instance_types = ["t3.large"]

    labels = {
        environment = "staging"
    }
    
    depends_on = [
        aws_iam_role_policy_attachment.eks_worker_node_policy,
        aws_iam_role_policy_attachment.eks_cni_policy,
        aws_iam_role_policy_attachment.eks_container_registry_policy,
    ]
}

resource "aws_eks_node_group" "prod" {
    cluster_name    = aws_eks_cluster.main.name
    node_group_name = "node-group-${var.name}-prod"
    node_role_arn  = aws_iam_role.eks_node_group_role.arn
    subnet_ids     = data.aws_subnets.private_subnets.ids

    scaling_config {
        desired_size = 1
        max_size     = 3
        min_size     = 1
    }

    instance_types = ["t3.large"]

    labels = {
        environment = "prod"
    }
    
    depends_on = [
        aws_iam_role_policy_attachment.eks_worker_node_policy,
        aws_iam_role_policy_attachment.eks_cni_policy,
        aws_iam_role_policy_attachment.eks_container_registry_policy,
    ]
}

resource "kubernetes_namespace_v1" "external_dns" {

    metadata {
        name = var.external_dns
    }
}

resource "kubernetes_service_account_v1" "external_dns" {

    metadata {
        name = var.external_dns
        namespace = var.external_dns
        labels = {
            "app.kubernetes.io/managed-by" = "Helm"
        }
        annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns_role.arn
            "meta.helm.sh/release-name" = var.external_dns
            "meta.helm.sh/release-namespace" = var.external_dns
        }
    }
}

# resource "aws_eks_addon" "ebs_csi_driver" {
#     cluster_name = aws_eks_cluster.main.name
#     addon_name = var.addon_name
#     addon_version = var.addon_version
#     service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

    
#     resolve_conflicts_on_create = "OVERWRITE"
#     resolve_conflicts_on_update = "OVERWRITE"

#     depends_on = [
#         aws_iam_role_policy_attachment.ebs_csi_driver_policy
#     ]

#     tags = {
#         Name = "ebs-csi-driver-${var.name}"
#     }
# }