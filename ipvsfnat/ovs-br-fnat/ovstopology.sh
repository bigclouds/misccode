#!/bin/bash
#
#	|vm1 10.5|    |vm2 10.6|   |vm3 10.7|   |vm4 10.8|
#	    |tap	   |tap		|tap	    |tap
#	-brovm1-	-brovm2-    -brovm3-	 -brovm4-
#	    |veth	   |veth	|veth	    |veth	
#	------------------ovsbr----------------------------
#	    |lbovs(ovs port)		|
#	 |nslb 10.3,20.3|	     [netgw default gw 192.168.10.1]
#	             |veth
#	 |nsclient 20.2|

function base_set()
{
	ulimit -n 60000
	modprobe br_netfilter
	sysctl -w net.core.somaxconn=2048
	sysctl -w net.ipv4.tcp_max_syn_backlog=2048
	sysctl -w net.ipv4.tcp_syncookies=0
	sysctl -w net.ipv4.tcp_fin_timeout=20
	sysctl -w net.ipv4.ip_forward=1
	sysctl -w net.netfilter.nf_conntrack_max=1655360
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=3600
	sysctl -w net.ipv4.ip_local_port_range="3000 65535"
	#sysctl -w net.bridge.bridge-nf-call-arptables=0
	#sysctl -w net.bridge.bridge-nf-call-ip6tables=0
	#sysctl -w net.bridge.bridge-nf-call-iptables=0
}

function add_net()
{
	echo "add"
	ovs-vsctl add-br ovsbr
	#ovs-vsctl add-port testovs clientnic -- set interface clientnic type=internal
	ovs-vsctl add-port ovsbr lbovs -- set interface lbovs type=internal
	ovs-vsctl add-port ovsbr netgw -- set interface netgw type=internal

	# lb vm4 namespace
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

	ip netns exec netgw ip link set lo up
	ip netns exec netgw ip link set netgw up
	ip netns exec netgw ip addr add 192.168.10.1/24 dev netgw

	# add 4 bridge for 4 vm
	brctl addbr brovm1 ; ip link set brovm1 up;
	brctl addbr brovm2 ; ip link set brovm2 up;
	brctl addbr brovm3 ; ip link set brovm3 up;
	brctl addbr brovm4 ; ip link set brovm4 up;
	#connect testovs and bridges
	ip link add vm1ovs type veth peer name ovsvm1 ; ip link set vm1ovs up; ip link set ovsvm1 up;
	ip link add vm2ovs type veth peer name ovsvm2 ; ip link set vm2ovs up; ip link set ovsvm2 up;
	ip link add vm3ovs type veth peer name ovsvm3 ; ip link set vm3ovs up; ip link set ovsvm3 up;
	ip link add vm4ovs type veth peer name ovsvm4 ; ip link set vm4ovs up; ip link set ovsvm4 up;

	brctl addif brovm1 vm1ovs
	brctl addif brovm2 vm2ovs
	brctl addif brovm3 vm3ovs
	brctl addif brovm4 vm4ovs
	ovs-vsctl add-port ovsbr ovsvm1
	ovs-vsctl add-port ovsbr ovsvm2
	ovs-vsctl add-port ovsbr ovsvm3
	ovs-vsctl add-port ovsbr ovsvm4

	ip netns exec nslb sysctl -w net.ipv4.ip_forward=1
	ip netns exec nslb sysctl -w net.ipv4.conf.all.rp_filter=0
	ip netns exec nslb sysctl -w net.ipv4.conf.default.rp_filter=0
	ip netns exec nslb sysctl -w net.ipv4.conf.lbovs.rp_filter=0
	ip netns exec nslb sysctl -w net.ipv4.conf.lbovs.accept_local=1
	#ip netns exec nslb sysctl -w net.ipv4.conf.all.accept_local=1
	#ip netns exec nslb sysctl -w net.ipv4.conf.default.accept_local=1
	ip netns exec test2 sysctl -w net.ipv6.conf.all.forwarding=1
	ip netns exec nslb sysctl -w net.core.somaxconn=4096

	#start vms
}

function del_net()
{
	ip netns del nsclient
	ip netns del nslb
	ip netns del netgw

	# del lb client veth
	#ip link set clientlb down ;ip link delete dev clientlb
	# del bridge if
	brctl delif brovm1 vm1ovs
	brctl delif brovm2 vm2ovs
	brctl delif brovm3 vm3ovs
	brctl delif brovm4 vm4ovs
	# del ovs veth
	ovs-vsctl del-port ovsbr ovsvm1
	ovs-vsctl del-port ovsbr ovsvm2
	ovs-vsctl del-port ovsbr ovsvm3
	ovs-vsctl del-port ovsbr ovsvm4

	ip link set vm1ovs down ; ip link delete dev vm1ovs
	ip link set vm2ovs down ; ip link delete dev vm2ovs
	ip link set vm3ovs down ; ip link delete dev vm3ovs
	ip link set vm4ovs down ; ip link delete dev vm4ovs

	# delete lb
	ovs-vsctl del-port ovsbr lbovs

	# stop vms

	# dele bridge
	ip link set brovm1 down; brctl delbr brovm1
	ip link set brovm2 down; brctl delbr brovm2
	ip link set brovm3 down; brctl delbr brovm3
	ip link set brovm4 down; brctl delbr brovm4
	ovs-vsctl del-br ovsbr
}
if [[ "$1" = "add" ]] ; then
	base_set
	add_net
elif [[ "$1" = "del" ]] ; then
	del_net
else
	echo "none"
fi
