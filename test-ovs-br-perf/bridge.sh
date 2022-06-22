brctl addbr testbr
ip link set testbr up

ip link add tap1 type veth peer name tap1br
ip link set tap1br up
ip link set tap1 up

ip link add tap2 type veth peer name tap2br
ip link set tap2br up
ip link set tap2 up

brctl addif testbr tap1br
brctl addif testbr tap2br

ip netns add brtap1
ip netns add brtap2

ip link set tap1 netns brtap1
ip link set tap2 netns brtap2


ip netns exec brtap1 ip link set lo up
ip netns exec brtap1 ip link set tap1 up
ip netns exec brtap1 ip addr add 192.168.1.1/24 dev tap1


ip netns exec brtap2 ip link set lo up
ip netns exec brtap2 ip link set tap2 up
ip netns exec brtap2 ip addr add 192.168.1.2/24 dev tap2

# ip netns exec tap2 iperf3 -s -4
# ip netns exec tap1 iperf3 -c 192.168.1.2 -N -u -l 1460 -b 20000M
