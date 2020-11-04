#!/bin/bash

#lnstat -k in_martian_dst,in_martian_src,in_no_route

#		192.168.10.2		192.168.10.3   192.168.20.3	
#		[ns test1]		  [ ns         test2]
#  192.168.10.4	     ^			    ^		^
#	[qemu]	     |test1i		    |test2i	|test23     192.168.20.2
#	 |vnetX	     |			    |		____________test32__>[ ns test3] client
#	 |	     |			    |
#	 |	     |			    |
#	 |	     |test1o		    |test2o		
#	_|___________________testbr_______________________________________
#		|		|		|		  |
#	     __brvm5___	     __brvm6__	     __brvm7__		__brvm8__
#		|		|		|		  |
#	    	|vnet5		|vnet6   	|vnet7		  |vnet8
#	      [ns test5]      [ns test6]      [ns test7]	[ns client]
#	      192.168.10.5    192.168.10.6    192.168.10.7	192.168.10.8
#
#

if [ "$1" = "no" ]; then
ip netns del test1
ip netns del test2
ip netns del test3
ip netns del test4
ip netns del test5
ip netns del test6
ip netns del test7
ip netns del test8
ip link del vm5testi
ip link del vm6testi
ip link del vm7testi
ip link del vm8testi
ip link set brvm5 down
ip link set brvm6 down
ip link set brvm7 down
ip link set brvm8 down
ip link set testbr down

ip link del name brvm5 type bridge
ip link del name brvm6 type bridge
ip link del name brvm7 type bridge
ip link del name brvm8 type bridge
ip link del name testbr type bridge
fi
# HOST
ulimit -n 60000
modprobe br_netfilter
sysctl -w net.core.somaxconn=2048
sysctl -w net.ipv4.tcp_max_syn_backlog=2048
#sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv4.tcp_fin_timeout=20
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.netfilter.nf_conntrack_max=1655360
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_fin_wait=10
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_syn_sent=10
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_syn_recv=30
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=30
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_close_wait=30
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=120
sysctl -w net.ipv4.ip_local_port_range="2000 65535"
#sysctl -w net.bridge.bridge-nf-call-arptables=0
#sysctl -w net.bridge.bridge-nf-call-ip6tables=0
sysctl -w net.bridge.bridge-nf-call-iptables=1

ip netns add test1
ip netns add test2
ip netns add test3
ip netns add test4

ip link add name testbr type bridge
ip link set testbr up

ip link add test1i type veth peer name test1o
ip link add test2i type veth peer name test2o
ip link add test23 type veth peer name test32
ip link add test24 type veth peer name test42

ip link set test1o up
ip link set test2o up
ip link set test1o master testbr
ip link set test2o master testbr

ip link set test1i netns test1
ip link set test2i netns test2
ip link set test23 netns test2
ip link set test24 netns test2
ip link set test32 netns test3
ip link set test42 netns test4
# ns test1  network
ip netns exec test1 ip link set lo up
ip netns exec test1 ip link set test1i up
ip netns exec test1 ip addr add 192.168.10.2/24 dev test1i

# ns test2/lb  network
ip netns exec test2 ip link set lo up
ip netns exec test2 ip link set test2i up
ip netns exec test2 ip addr add 192.168.10.3/24 dev test2i
ip netns exec test2 ip link set test23 up
ip netns exec test2 ip addr add 192.168.20.3/24 dev test23
ip netns exec test2 ip link set test24 up
ip netns exec test2 ip addr add 192.168.40.3/24 dev test24

# ns test3/client  network
ip netns exec test3 ip link set lo up
ip netns exec test3 ip link set test32 up
ip netns exec test3 ip addr add 192.168.20.2/24 dev test32
ip netns exec test4 ip route add default via 192.168.20.3

# ns test4/client  network
ip netns exec test4 ip link set lo up
ip netns exec test4 ip link set test42 up
ip netns exec test4 ip addr add 192.168.40.2/24 dev test42
ip netns exec test4 ip route add default via 192.168.40.3

# lb namespace setting
ip netns exec test2 sysctl -w net.ipv4.ip_local_port_range="2000 65535"
ip netns exec test2 sysctl -w net.ipv4.ip_forward=1
ip netns exec test2 sysctl -w net.ipv4.conf.all.rp_filter=0
ip netns exec test2 sysctl -w net.ipv4.conf.default.rp_filter=0
ip netns exec test2 sysctl -w net.ipv4.conf.test2i.rp_filter=0
ip netns exec test2 sysctl -w net.ipv4.conf.test2i.accept_local=1
#ip netns exec test2 sysctl -w net.ipv4.conf.all.accept_local=1
#ip netns exec test2 sysctl -w net.ipv4.conf.default.accept_local=1
#ip netns exec test2 sysctl -w net.ipv6.conf.all.forwarding=1

function sysparam(){
	ip netns exec $1 sysctl -w net.core.somaxconn=4096
}

# http server inside ns or vm
ip netns add test5
ip netns add test6
ip netns add test7
ip netns add test8

sysparam test2
sysparam test5
sysparam test6
sysparam test7
sysparam test8

ip link add name brvm5 type bridge
ip link add name brvm6 type bridge
ip link add name brvm7 type bridge
ip link add name brvm8 type bridge
ip link set brvm5 up
ip link set brvm6 up
ip link set brvm7 up
ip link set brvm8 up

ip link add vm5testi type veth peer name vm5testo
ip link add vm6testi type veth peer name vm6testo
ip link add vm7testi type veth peer name vm7testo
ip link add vm8testi type veth peer name vm8testo
ip link set vm5testi up
ip link set vm5testo up
ip link set vm6testi up
ip link set vm6testo up
ip link set vm7testi up
ip link set vm7testo up
ip link set vm8testi up
ip link set vm8testo up

ip link set vm5testi master brvm5
ip link set vm6testi master brvm6
ip link set vm7testi master brvm7
ip link set vm8testi master brvm8
ip link set vm5testo master testbr
ip link set vm6testo master testbr
ip link set vm7testo master testbr
ip link set vm8testo master testbr

ip link add test5i type veth peer name vnet5
ip link add test6i type veth peer name vnet6
ip link add test7i type veth peer name vnet7
ip link add test8i type veth peer name vnet8
ip link set test5i netns test5
ip link set test6i netns test6
ip link set test7i netns test7
ip link set test8i netns test8
ip link set vnet5 up
ip link set vnet6 up
ip link set vnet7 up
ip link set vnet8 up
ip link set vnet5 master brvm5
ip link set vnet6 master brvm6
ip link set vnet7 master brvm7
ip link set vnet8 master brvm8

ip netns exec test5 ip link set lo up
ip netns exec test5 ip link set test5i up
ip netns exec test5 ip addr add 192.168.10.5/24 dev test5i
ip netns exec test5 ip route add default via 192.168.10.2
ip netns exec test6 ip link set lo up
ip netns exec test6 ip link set test6i up
ip netns exec test6 ip addr add 192.168.10.6/24 dev test6i
ip netns exec test6 ip route add default via 192.168.10.2
ip netns exec test7 ip link set lo up
ip netns exec test7 ip link set test7i up
ip netns exec test7 ip addr add 192.168.10.7/24 dev test7i
ip netns exec test7 ip route add default via 192.168.10.2
ip netns exec test8 ip link set lo up
ip netns exec test8 ip link set test8i up
ip netns exec test8 ip addr add 192.168.10.8/24 dev test8i
ip netns exec test8 ip route add default via 192.168.10.2


ip netns exec test3 sysctl -w net.ipv4.ip_local_port_range="2000 65535" 
ip netns exec test4 sysctl -w net.ipv4.ip_local_port_range="2000 65535"
ip netns exec test5 sysctl -w net.ipv4.ip_local_port_range="2000 65535"
ip netns exec test6 sysctl -w net.ipv4.ip_local_port_range="2000 65535"
ip netns exec test7 sysctl -w net.ipv4.ip_local_port_range="2000 65535"
ip netns exec test8 sysctl -w net.ipv4.ip_local_port_range="2000 65535"

function set_ipv6()
{
	ip netns exec test1  ip -6 addr add fc00::1:1/64 dev test1i

	ip netns exec test2  ip -6 addr add fc00::1:3/64 dev test2i
	ip netns exec test2  ip -6 add add fc00:2::3/64 dev test23
	ip netns exec test2  ip -6 add add fc00:4::3/64 dev test24

	ip netns exec test3  ip -6 add add fc00:2::2/64 dev test32
	ip netns exec test3  ip -6 route add default via fc00:2::3

	ip netns exec test4  ip -6 add add fc00:4::2/64 dev test42
	ip netns exec test4  ip -6 route add default via fc00:4::3

	ip netns exec test5  ip -6 addr add fc00::1:5/64 dev test5i
	ip netns exec test5  ip -6 route add default via fc00::1:1 
	# ip netns exec test5 ip -6 addr add ::ffff:c0a8:a05/64 dev test5i

	ip netns exec test6  ip -6 addr add fc00::1:6/64 dev test6i
	ip netns exec test6  ip -6 route add default via fc00::1:1
	#ip netns exec test6 ip -6 addr add ::c0a8:a06/64 dev test6i

	ip netns exec test7  ip -6 addr add fc00::1:7/64 dev test7i
	ip netns exec test7  ip -6 route add default via fc00::1:1
	#ip netns exec test7 ip -6 addr add ::c0a8:a07/64 dev test7i

	ip netns exec test8  ip -6 addr add fc00::1:8/64 dev test8i
	ip netns exec test8  ip -6 route add default via fc00::1:1

	# cat /sys/class/net/brvm5/bridge/vlan_filtering
	# fdb vm2
	# ip netns exec test2 ip link set dev test2i address 8a:26:99:f8:ef:4d
	# bridge fdb append 8a:26:99:f8:ef:4d dev test2o master temp
	# fdb vm5
	# ip netns exec test5 ip link set dev test5i address 02:e3:04:0e:28:69
	# bridge fdb append 02:e3:04:0e:28:69 dev vnet5 master temp
	# bridge fdb append 02:e3:04:0e:28:69 dev vm5testo master temp
	# fdb vm6
	# ip netns exec test6 ip link set dev test6i address 12:14:04:30:ec:4c
	# bridge fdb append 12:14:04:30:ec:4c dev vnet6 master temp
	# bridge fdb append 12:14:04:30:ec:4c dev vm6testo master temp
	# fdb vm7
	# ip netns exec test7 ip link set dev test7i address 76:6b:4a:e8:f9:02
	# bridge fdb append 76:6b:4a:e8:f9:02 dev vnet7 master temp
	# bridge fdb append 76:6b:4a:e8:f9:02 dev vm7testo master temp
	# fdb vm8
	# ip netns exec test8 ip link set dev test8i address fa:a9:04:83:ab:f6
	# bridge fdb append fa:a9:04:83:ab:f6 dev vnet8 master temp
	# bridge fdb append fa:a9:04:83:ab:f6 dev vm8testo master temp

	# via route 

	#ip netns exec test2 ip -6 neigh add  fc00::1:5 lladdr  02:e3:04:0e:28:69 dev test2i 
	#ip netns exec test2 ip6tables -t raw -A PREROUTING -p tcp --dport 8070 -j NOTRACK
	#ip netns exec test2 ip6tables -t raw -A PREROUTING -p tcp --dport 8080 -j NOTRACK
	#ip6tables -t raw -A PREROUTING -p tcp --dport 8070 -j NOTRACK
	#ip6tables -t raw -A PREROUTING -p tcp --dport 8080 -j NOTRACK
}

function set_ipv6_compat_v4()
{
	ip netns exec test1 ip -6 addr add ::c0a8:a02/64 dev test1i
	ip netns exec test2 ip -6 addr add ::c0a8:a03/64 dev test2i
	ip netns exec test5 ip -6 addr add ::c0a8:a05/64 dev test5i
	ip netns exec test6 ip -6 addr add ::c0a8:a06/64 dev test6i
	ip netns exec test7 ip -6 addr add ::c0a8:a07/64 dev test7i
	ip netns exec test8 ip -6 addr add ::c0a8:a08/64 dev test8i
}



#set_ipv6
#set_ipv6_compat_v4
#virsh start cirros
