output "dns_floating_ip_address" {
  description = "The IP address of the DNS floating IP"
  value       = openstack_networking_floatingip_v2.dns_floating_ip.address
}