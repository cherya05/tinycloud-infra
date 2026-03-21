resource "civo_network" "main" {
    label = var.name
}

resource "civo_firewall" "main" {
    name = var.name
    network_id = civo_network.main.id
    create_default_rules = true
}