output "kubeconfig" {
    value = civo_kubernetes_cluster.main.kubeconfig
    sensitive = true
}

output "cluster_id" {
    value = civo_kubernetes_cluster.main.id
}