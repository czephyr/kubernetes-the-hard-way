module "network_module" {
  source = "../networks"
}

data "openstack_compute_keypair_v2" "k8s_keypair" {
  name = "k8s-the-hard-way"
}

data "openstack_images_image_v2" "centos8_image" {
  name = "CentOS Stream 8 - GARR"
}

data "openstack_compute_flavor_v2" "small_flavor" {
  name = "m1.small"
}

# create dns server and assign it a public and a private ip
resource "openstack_compute_instance_v2" "k8s_dns_server" {
  name            = "dns.k8s.lan"
  image_name      = data.openstack_images_image_v2.centos8_image.name
  flavor_id       = data.openstack_compute_flavor_v2.small_flavor.id
  key_pair        = data.openstack_compute_keypair_v2.k8s_keypair.name
  security_groups = [openstack_networking_secgroup_v2.kubernetes_dns_sg.name]

  network {
    uuid        = module.network_module.external_network_id
    fixed_ip_v4 = "10.240.0.100"
  }
}
resource "openstack_compute_floatingip_associate_v2" "dns_fip_associate" {
  floating_ip = openstack_networking_floatingip_v2.dns_floating_ip.address
  instance_id = openstack_compute_instance_v2.k8s_dns_server.id
}
