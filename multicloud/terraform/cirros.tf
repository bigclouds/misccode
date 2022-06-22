resource "openstack_compute_instance_v2" "cirrosbasic" {
  name            = "cirrosbasic"
  flavor_name     = "m1.tiny"
  image_name      = "cirros"
  power_state	  = "active"
  //security_groups = ["default"]
  security_groups = ["${openstack_compute_secgroup_v2.secgroup_tf.name}"]

  metadata = {
    this = "that"
  }

  //network {
    //name = "test-ipv4-2"
    //uuid = "70f1e128-46f8-460f-b8c6-cb176b5c8d7d"
    //fixed_ip_v4 = "30.1.1.5"
    //name = "${openstack_networking_network_v2.network_tf.name}"
    //fixed_ip_v4 = "192.200.199.5"
  //}

  network {
    port = "${openstack_networking_port_v2.port_tf1.id}"
  }
  network {
    port = "${openstack_networking_port_v2.port_tf.id}"
  }
}

resource "openstack_networking_port_v2" "port_tf1" {
  name               = "port_tf1"
  network_id         = "${openstack_networking_network_v2.network_tf.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.secgroup_tf.id}"]

  fixed_ip {
    subnet_id  = "${openstack_networking_subnet_v2.subnet_tf.id}"
    ip_address = "192.200.199.5"
  }
}

resource "openstack_networking_port_v2" "port_tf" {
  name               = "port_tf"
  network_id         = "${openstack_networking_network_v2.network_tf.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.secgroup_tf.id}"]

  fixed_ip {
    subnet_id  = "${openstack_networking_subnet_v2.subnet_tf.id}"
    ip_address = "192.200.199.10"
  }
}

resource "openstack_networking_floatingip_associate_v2" "fip_as_tf" {
  port_id = openstack_networking_port_v2.port_tf1.id
  fixed_ip = "192.200.199.5"
  floating_ip = openstack_networking_floatingip_v2.floatip_tf.address
}

resource "openstack_networking_floatingip_v2" "floatip_tf" {
  pool = var.openstack_ex_net_name
}
