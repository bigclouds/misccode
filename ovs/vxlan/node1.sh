#/bin/bash

#node 99
ovs-vsctl del-br vxlanbr1
ovs-vsctl add-br vxlanbr1
#ip link set vxlanbr1 up
#ip addr add 192.101.6.99/24 dev vxlanbr1

ovs-vsctl add-port vxlanbr1 xnic1 -- set Interface xnic1 type=internal
ip link set xnic1 up
ip addr add  192.101.1.99/24 dev xnic1

ovs-vsctl add-port vxlanbr1 vxlanp0 -- set interface vxlanp0 type=vxlan option:remote_ip=172.20.12.98 option:key=5 option:df_default=false
#ping -I xnic1 192.101.1.98
#reforward icmp reply to coorect port
#ovs-ofctl add-flow grebr1 "table=0,icmp,icmp_type=0,icmp_code=0,nw_dst=192.101.1.99,priority=4,in_port=2,actions=mod_dl_dst:ba:c4:b7:93:ef:f7,output:1"
#ovs-ofctl del-flows grebr1 "table=0,icmp,icmp_type=0,icmp_code=0,nw_dst=192.101.1.99"
#ovs-ofctl dump-flows grebr1
#ovs-ofctl dump-ports-desc grebr1
