#/bin/bash

#node 99
ovs-vsctl del-br grebr1
ovs-vsctl add-br grebr1
ip link set grebr1 up
ip addr add 192.101.6.99/24 dev grebr1

ovs-vsctl add-port grebr1 nic1 -- set Interface nic1 type=internal
ip link set nic1 up
ip addr add  192.101.1.99/24 dev nic1
ip route add 192.101.2.0/24 via 192.101.6.98 dev grebr1

ovs-vsctl add-port grebr1 gre -- set interface gre type=gre option:remote_ip=172.20.12.98
#ping -I nic1 192.101.2.98
#reforward icmp reply to coorect port
#ovs-ofctl add-flow grebr1 "table=0,icmp,icmp_type=0,icmp_code=0,nw_dst=192.101.1.99,priority=4,in_port=2,actions=mod_dl_dst:ba:c4:b7:93:ef:f7,output:1"
#ovs-ofctl del-flows grebr1 "table=0,icmp,icmp_type=0,icmp_code=0,nw_dst=192.101.1.99"
#ovs-ofctl dump-flows grebr1
#ovs-ofctl dump-ports-desc grebr1
