#/bin/bash

#node 98
ovs-vsctl del-br grebr1
ovs-vsctl add-br grebr1
#ip link set grebr1 up
#ip addr add 192.101.6.98/24 dev grebr1

ovs-vsctl add-port grebr1 nic1 -- set Interface nic1 type=internal
ip link set nic1 up
ip addr add  192.101.1.98/24 dev nic1

ovs-vsctl add-port grebr1 gre -- set interface gre type=gre option:remote_ip=172.20.12.99
#ping -I nic1 192.101.1.99
