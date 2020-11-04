ovs-vsctl add-br ovspt2a
ovs-vsctl add-br ovspt2b
ovs-vsctl add-port ovspt2a portpta -- set interface portpta type=internal  
ovs-vsctl add-port ovspt2b portptb -- set interface portptb type=internal  

ip netns add portpta
ip netns add portptb

ip link set portpta netns portpta
ip link set portptb netns portptb

ip netns exec portpta ip link set lo up
ip netns exec portpta ip link set portpta up
ip netns exec portpta ip addr add 192.168.1.1/24 dev portpta


ip netns exec portptb ip link set lo up
ip netns exec portptb ip link set portptb up
ip netns exec portptb ip addr add 192.168.1.2/24 dev portptb


ovs-vsctl add-br ovspt1a
ovs-vsctl add-br ovspt1b
ovs-vsctl add-br ovsptbase


ovs-vsctl add-port ovspt1a patch12a -- set Interface patch12a type=patch options:peer=patch21a
ovs-vsctl add-port ovspt2a patch21a -- set Interface patch21a type=patch options:peer=patch12a

ovs-vsctl add-port ovspt1b patch12b -- set Interface patch12b type=patch options:peer=patch21b
ovs-vsctl add-port ovspt2b patch21b -- set Interface patch21b type=patch options:peer=patch12b

ovs-vsctl add-port ovspt1a patch10a -- set Interface patch10a type=patch options:peer=patch01a
ovs-vsctl add-port ovsptbase patch01a -- set Interface patch01a type=patch options:peer=patch10a

ovs-vsctl add-port ovspt1b patch10b -- set Interface patch10b type=patch options:peer=patch01b
ovs-vsctl add-port ovsptbase patch01b -- set Interface patch01b type=patch options:peer=patch10b

#ip netns exec portpta iperf3 -s -4
#ip netns exec portptb iperf3 -c 192.168.1.2 -N -u -l 64 -b 10000M  -P 20 -t 10
