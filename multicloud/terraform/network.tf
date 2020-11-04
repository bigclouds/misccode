resource "openstack_networking_network_v2" "network_tf" {
  name           = "network_tf"
  admin_state_up = "true"
  shared = "true"
}

resource "openstack_networking_subnet_v2" "subnet_tf" {
  name       = "subnet_tf"
  network_id = "${openstack_networking_network_v2.network_tf.id}"
  cidr       = "192.200.199.0/24"
  ip_version = 4
  enable_dhcp = "true"
  gateway_ip = "192.200.199.1"
}
