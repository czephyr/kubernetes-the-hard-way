terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "2.0.0"
    }
  }
}





# data "external" "dns_ip" {
#   program = ["cat", "/tmp/dns_ip.json"]
#   depends_on = [openstack_compute_instance_v2.k8s_dns_server]
# }

# resource "openstack_networking_subnet_v2" "kubernetes_subnet" {
#   network_id      = data.openstack_networking_subnet_v2.kubernetes_network.id
#   dns_nameservers = [data.external.dns_ip.result.dns_internal_ip]
#   depends_on = [data.external.dns_ip]
# }




