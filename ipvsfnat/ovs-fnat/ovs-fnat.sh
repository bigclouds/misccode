#!/bin/bash
#
#	|vm1 10.5|    |vm2 10.6|   |vm3 10.7|   |vm4 10.8|
#	    |vnet          |vnet	|vnet	    |vnet
#	-brovm1-	-brovm2-      -brovm3-	  -brovm4-
#	    |veth	   |veth	|veth	    |veth	
#	------------------fnatovsbr----------------------------
#	       |lbovs(ovs port)		|
#	 |nslb 10.3,20.3|	     [netgw default gw 192.168.10.1]
#	       |veth
#	 |nsclient 20.2|
GW="192.168.10.1"
function base_set()
{
	ulimit -n 60000
	modprobe br_netfilter
	sysctl -w net.core.somaxconn=1024
	sysctl -w net.ipv4.tcp_max_syn_backlog=1024
	sysctl -w net.ipv4.tcp_syncookies=1
	sysctl -w net.ipv4.tcp_fin_timeout=20
	sysctl -w net.ipv4.ip_forward=1
	#sysctl -w net.netfilter.nf_conntrack_max=1655360
	#sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=3600
	#sysctl -w net.ipv4.ip_local_port_range="1000 65535"
	#sysctl -w net.bridge.bridge-nf-call-arptables=0
	#sysctl -w net.bridge.bridge-nf-call-ip6tables=0
	#sysctl -w net.bridge.bridge-nf-call-iptables=0
}

# name, ip, need_br
function add_vm()
{
	ip netns add $1
	if [ $# -eq 3 ]; then
		echo -n ""
	fi
	ovs-vsctl add-port fnatovsbr vnet$1 -- set interface vnet$1 type=internal
	ip link set vnet$1 netns $1
	ip netns exec $1 ip link set lo up
	ip netns exec $1 ip link set vnet$1 up
	ip netns exec $1 ip addr add $2 dev vnet$1
	ip netns exec $1 ip route add default via $GW
}
function del_vm()
{
	if [ $# -eq 3 ]; then
		echo -n ""
	fi
	ovs-vsctl del-port fnatovsbr vnet$1
	ip netns del $1
}

function add_net()
{
	echo "add"
	ovs-vsctl add-br fnatovsbr
	ovs-vsctl add-port fnatovsbr lbovs -- set interface lbovs type=internal
	ovs-vsctl add-port fnatovsbr netgw -- set interface netgw type=internal

	# lb,gw,client namespace
	ip netns add nslb
	ip netns add nsclient
	ip netns add netgw

	ip link add clientlb type veth peer name lbclient
	# connect lb client
	ip link set lbovs netns nslb
	ip link set lbclient netns nslb
	ip link set clientlb netns nsclient
	ip link set netgw netns netgw

	# up lb
	ip netns exec nslb ip link set lo up
	ip netns exec nslb ip link set lbovs up
	ip netns exec nslb ip addr add 192.168.10.3/24 dev lbovs
	ip netns exec nslb ip link set lbclient up
	ip netns exec nslb ip addr add 192.168.20.3/24 dev lbclient
	# up client
	ip netns exec nsclient ip link set lo up
	ip netns exec nsclient ip link set clientlb up
	ip netns exec nsclient ip addr add 192.168.20.2/24 dev clientlb
	# up gw
	ip netns exec netgw ip link set lo up
	ip netns exec netgw ip link set netgw up
	ip netns exec netgw ip addr add 192.168.10.1/24 dev netgw

	ip netns exec nslb sysctl -w net.ipv4.ip_forward=1
	ip netns exec nslb sysctl -w net.ipv4.conf.all.rp_filter=0
	ip netns exec nslb sysctl -w net.ipv4.conf.default.rp_filter=0
	ip netns exec nslb sysctl -w net.ipv4.conf.lbovs.rp_filter=0
	ip netns exec nslb sysctl -w net.ipv4.conf.lbovs.accept_local=1
	#ip netns exec nslb sysctl -w net.ipv4.conf.all.accept_local=1
	#ip netns exec nslb sysctl -w net.ipv4.conf.default.accept_local=1
	ip netns exec nslb sysctl -w net.core.somaxconn=1024

	#start vms
}

function set_ipv6()
{
	ip netns exec netgw  ip -6 addr add fc00::1:1/64 dev netgw

	ip netns exec nslb  ip -6 addr add fc00::1:3/64 dev lbovs
	ip netns exec nslb  ip -6 add add fc00:2::3/64 dev lbclient
	#ip netns exec nslb  ip -6 add add fc00:4::3/64 dev test24

	ip netns exec nsclient  ip -6 add add fc00:2::2/64 dev clientlb
	ip netns exec nsclient  ip -6 route add default via fc00:2::3

	#ip netns exec test4  ip -6 add add fc00:4::2/64 dev test42
	#ip netns exec test4  ip -6 route add default via fc00:4::3

	ip netns exec vm1 ip -6 addr add fc00::1:5/64 dev vnetvm1
	ip netns exec vm1 ip -6 route add default via fc00::1:1 
	# map ipv6
	# ip netns exec test5 ip -6 addr add ::ffff:c0a8:a05/64 dev test5i

	#ip netns exec vm2 ip -6 addr add fc00::1:6/64 dev vnetvm1
	#ip netns exec vm2 ip -6 route add default via fc00::1:1
																	
	#ip netns exec test7  ip -6 addr add fc00::1:7/64 dev test7i
	#ip netns exec test7  ip -6 route add default via fc00::1:1

	#ip netns exec test8  ip -6 addr add fc00::1:8/64 dev test8i
	#ip netns exec test8  ip -6 route add default via fc00::1:1
}

function set_ipv6_compat_v4()
{
	ip netns exec test1 ip -6 addr add ::c0a8:a02/64 dev test1i
	ip netns exec test2 ip -6 addr add ::c0a8:a03/64 dev test2i
	ip netns exec test5 ip -6 addr add ::c0a8:a05/64 dev test5i
	#ip netns exec test6 ip -6 addr add ::c0a8:a06/64 dev test6i
	#ip netns exec test7 ip -6 addr add ::c0a8:a07/64 dev test7i
	#ip netns exec test8 ip -6 addr add ::c0a8:a08/64 dev test8i
}

function del_net()
{
	ip netns del nsclient
	ip netns del nslb
	ip netns del netgw

	# delete lb
	ovs-vsctl del-port fnatovsbr lbovs
	ovs-vsctl del-port fnatovsbr netgw
	ovs-vsctl del-br fnatovsbr
}
if [[ "$1" = "add" ]] ; then
	#base_set
	add_net
	add_vm vm1 192.168.10.5/24 
	add_vm vm2 192.168.10.6/24 
	set_ipv6
elif [[ "$1" = "del" ]] ; then
	del_vm vm1
	del_vm vm2
	del_net
else
	echo "none"
fi
