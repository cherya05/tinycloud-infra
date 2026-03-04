resource "aws_iam_role" "eks_cluster_role" {
    name = "eks-cluster-role-${var.name}"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
                Effect = "Allow"
        }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    role = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_group_role" {
    name = "eks-node-group-role-${var.name}"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Effect = "Allow"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
    role = aws_iam_role.eks_node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
    role = aws_iam_role.eks_node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
    role = aws_iam_role.eks_node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_openid_connect_provider" "main" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
    url = aws_eks_cluster.main.identity[0].oidc[0].issuer

    tags = {
        Name = "${var.name}-eks-irsa"
    }
}

resource "aws_iam_role" "external_dns_role" {

    name = "external-dns-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRoleWithWebIdentity"
                Effect = "Allow"
                Principal = {
                    Federated = aws_iam_openid_connect_provider.main.arn
                }
                Condition = {
                    StringEquals = {
                        "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:external-dns:external-dns"
                        "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
                    }
                }
            }
        ]
    })

    tags = {
        Name = "external-dns-role"
    }

}

# resource "aws_iam_role" "ebs_csi_driver" {
#     name = "AmazonEKS_EBS_CSI_Driver_Role"

#     assume_role_policy = jsonencode({
#         Version = "2012-10-17"
#         Statement = [
#             {
#                 Effect = "Allow"
#                 Principal = {
#                     Federated = aws_iam_openid_connect_provider.main.arn
#                 }
#                 Action = "sts:AssumeRoleWithWebIdentity"
#                 Condition = {
#                     StringEquals = {
#                         "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
#                         "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
#                     }
#                 }
#             }
#         ]
#     })
#     tags = {
#         Name = "ebs_csi_driver_role"
#     }
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
#     policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#     role = aws_iam_role.ebs_csi_driver.name
# }

resource "aws_iam_policy" "external_dns" {
    
    name = "external-dns-policy"
    
    policy = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role_policy_attachment" "external_dns" {

    role = aws_iam_role.external_dns_role.name
    policy_arn = aws_iam_policy.external_dns.arn
}

output "oidc_provider_arn" {
    value = aws_iam_openid_connect_provider.main.arn
}