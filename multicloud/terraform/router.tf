resource "openstack_networking_router_v2" "router_tf" {
  name                = "router_tf"
  admin_state_up      = true
  enable_snat	      = true
  external_network_id = "${var.openstack_ex_net_id}"
}

resource "openstack_networking_router_interface_v2" "router_interface_tf" {
  router_id = "${openstack_networking_router_v2.router_tf.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_tf.id}"
}
