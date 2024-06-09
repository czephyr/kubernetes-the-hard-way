terraform {
  required_version = ">= 0.14.0"
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

module "k8s" {
  source = "./modules/k8s"
}

module "dns" {
  source = "./modules/dns"
  depends_on = [module.k8s]
}
