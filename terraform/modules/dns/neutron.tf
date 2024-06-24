# create external ip and security group for DNS
resource "openstack_networking_floatingip_v2" "dns_floating_ip" {
  pool        = "floating-ip"
  description = "DNS floating IP for Name Server"
}

resource "openstack_networking_secgroup_v2" "kubernetes_dns_sg" {
  name        = "kubernetes-the-hard-way-allow-dns"
  description = "Security group for DNS server"
}
resource "openstack_networking_secgroup_rule_v2" "icmp_rule_dns" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_dns_sg.id
}
resource "openstack_networking_secgroup_rule_v2" "ssh_rule_dns" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.kubernetes_dns_sg.id
}
resource "openstack_networking_secgroup_rule_v2" "dns_tcp_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 53
  port_range_max    = 53
  security_group_id = openstack_networking_secgroup_v2.kubernetes_dns_sg.id
  remote_ip_prefix  = "10.240.0.0/24"
}
resource "openstack_networking_secgroup_rule_v2" "dns_udp_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 53
  port_range_max    = 53
  security_group_id = openstack_networking_secgroup_v2.kubernetes_dns_sg.id
  remote_ip_prefix  = "10.240.0.0/24"
}
