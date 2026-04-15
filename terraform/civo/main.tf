terraform {
  required_providers {
    civo = {
      source  = "civo/civo"
      version = "1.1.0"
    }
  }
}

provider "civo" {
  region = var.civo_region
}
