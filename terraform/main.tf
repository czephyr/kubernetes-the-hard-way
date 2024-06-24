terraform {
  required_version = "~> 1.8.5"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "2.0.0"
    }
  }
}

provider "openstack" {
  cloud = "openstack_garr"
}

module "networks" {
  source = "./modules/networks"
}

module "dns" {
  source = "./modules/dns"
}

# module "k8s" {
#   source = "./modules/k8s"
# }

