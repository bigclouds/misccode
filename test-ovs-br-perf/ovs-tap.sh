ovs-vsctl add-br ovs2a
ovs-vsctl add-br ovs2b
ovs-vsctl add-port ovs2a porta -- set interface porta type=internal  
ovs-vsctl add-port ovs2b portb -- set interface portb type=internal  

ip netns add porta
ip netns add portb

ip link set porta netns porta
ip link set portb netns portb

ip netns exec porta ip link set lo up
ip netns exec porta ip link set porta up
ip netns exec porta ip addr add 192.168.1.1/24 dev porta


ip netns exec portb ip link set lo up
ip netns exec portb ip link set portb up
ip netns exec portb ip addr add 192.168.1.2/24 dev portb


ovs-vsctl add-br ovs1a
ovs-vsctl add-br ovs1b
ovs-vsctl add-br ovsbase

ip link add tap01a type veth peer name tap10a
ip link add tap01b type veth peer name tap10b
ip link add tap12a type veth peer name tap21a
ip link add tap12b type veth peer name tap21b

ip link set tap01a up
ip link set tap01b up
ip link set tap10a up
ip link set tap10b up
ip link set tap12a up
ip link set tap12b up
ip link set tap21a up
ip link set tap21b up

ovs-vsctl add-port ovs2a tap21a
ovs-vsctl add-port ovs2b tap21b
ovs-vsctl add-port ovs1a tap12a
ovs-vsctl add-port ovs1a tap10a
ovs-vsctl add-port ovs1b tap12b
ovs-vsctl add-port ovs1b tap10b
ovs-vsctl add-port ovsbase tap01a
ovs-vsctl add-port ovsbase tap01b
#ip netns exec portb iperf3 -s -4
#ip netns exec porta iperf3 -c 192.168.1.2 -N -u -l 64 -b 10000M  -P 20 -t 10
