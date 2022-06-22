ovs-vsctl add-br test
ovs-vsctl add-port test port1 -- set interface port1 type=internal  
ovs-vsctl add-port test port2 -- set interface port2 type=internal  

ip netns add port1
ip netns add port2

ip link set port1 netns port1
ip link set port2 netns port2

ip netns exec port1 ip link set lo up
ip netns exec port1 ip link set port1 up
ip netns exec port1 ip addr add 192.168.1.1/24 dev port1

ip netns exec port2 ip link set lo up
ip netns exec port2 ip link set port2 up
ip netns exec port2 ip addr add 192.168.1.2/24 dev port2

# ip netns exec port2 iperf3 -s -4
# ip netns exec port1 iperf3 -c 192.168.1.2 -N -u -l 1460 -b 20000M
