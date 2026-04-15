resource "civo_kubernetes_cluster" "main" {
    name = var.name
    network_id = civo_network.main.id
    firewall_id = civo_firewall.main.id

    pools {
        size = var.node_size
        node_count = 1
    }  
}