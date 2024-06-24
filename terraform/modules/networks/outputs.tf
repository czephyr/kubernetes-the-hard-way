# id of external floating-ip network
output "external_network_id" {
  description = "The ID of the floating-ip external network"
  value = data.openstack_networking_network_v2.external_network.id
}