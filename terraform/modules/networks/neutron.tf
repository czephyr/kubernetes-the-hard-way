# get external network
data "openstack_networking_network_v2" "external_network" {
  name = "floating-ip"
}

# create router to external network
resource "openstack_networking_router_v2" "kubernetes_router" {
  name            = "kubernetes-the-hard-way-router"
  admin_state_up  = true
  external_network_id = data.openstack_networking_network_v2.external_network.id
}

# create kubernetes network with subnet
resource "openstack_networking_network_v2" "kubernetes_network" {
  name           = "kubernetes-the-hard-way"
  admin_state_up = true
}
resource "openstack_networking_subnet_v2" "kubernetes_subnet" {
  name       = "kubernetes"
  network_id = openstack_networking_network_v2.kubernetes_network.id
  cidr       = "10.240.0.0/24"
}

# link kubernetes subnet with router
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.kubernetes_router.id
  subnet_id = openstack_networking_subnet_v2.kubernetes_subnet.id
}

##### INTERNAL ALL TCP, UDP, ICMP

resource "openstack_networking_secgroup_v2" "kubernetes_internal_sg" {
  name = "kubernetes-the-hard-way-allow-internal"
}

resource "openstack_networking_secgroup_rule_v2" "tcp_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_internal_sg.id
  remote_group_id   = openstack_networking_secgroup_v2.kubernetes_internal_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "udp_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_internal_sg.id
  remote_group_id   = openstack_networking_secgroup_v2.kubernetes_internal_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "icmp_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_internal_sg.id
  remote_group_id   = openstack_networking_secgroup_v2.kubernetes_internal_sg.id
}


#### EXTERNAL ICMP, SSH, K8S api

resource "openstack_networking_secgroup_v2" "kubernetes_external_sg" {
  name = "kubernetes-the-hard-way-allow-external"
}

resource "openstack_networking_secgroup_rule_v2" "icmp_rule_external" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_external_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "ssh_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.kubernetes_external_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "k8s_api_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  security_group_id = openstack_networking_secgroup_v2.kubernetes_external_sg.id
}