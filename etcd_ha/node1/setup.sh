ip netns add a
ip netns exec a ip link set xnic1 up
ip netns exec a ip addr add 192.101.1.99/24 dev  xnic1
