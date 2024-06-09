terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "2.0.0"
    }
  }
}

resource "openstack_networking_secgroup_v2" "kubernetes_dns_sg" {
  name = "kubernetes-the-hard-way-allow-dns"
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

resource "openstack_compute_instance_v2" "k8s_dns_server" {
  name            = "dns.k8s.lan"
  image_name      = data.openstack_images_image_v2.centos8_image.name
  flavor_id       = data.openstack_compute_flavor_v2.small_flavor.id
  key_pair        = "k8s-the-hard-way"
  security_groups = ["kubernetes-the-hard-way-allow-dns"]

  network {
    uuid           = data.openstack_networking_network_v2.kubernetes_network.id
    fixed_ip_v4    = "10.240.0.100"
  }

  # this is only executed if the host is up, local-exec is only executed after this
  # so we avoid executing before the host is up
  provisioner "remote-exec" {
    inline = ["echo up!"]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "centos"
      private_key = file(var.pvt_key)
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} dns-setup.yml"
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

data "openstack_images_image_v2" "centos8_image" {
  name = "CentOS Stream 8 - GARR"
}

data "openstack_compute_flavor_v2" "small_flavor" {
  name = "m1.small"
}

data "openstack_networking_network_v2" "kubernetes_network" {
  name = "kubernetes-the-hard-way"
}

resource "openstack_networking_floatingip_v2" "dns_floating_ip" {
  pool = "floating-ip"
  description = "dns"
}

resource "openstack_compute_floatingip_associate_v2" "dns_fip_associate" {
  floating_ip = openstack_networking_floatingip_v2.dns_floating_ip.address
  instance_id = openstack_compute_instance_v2.k8s_dns_server.id
}