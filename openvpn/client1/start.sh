ip netns  exec openvpn  /usr/sbin/openvpn --suppress-timestamps --nobind --config /etc/openvpn/client/client.conf

#ip link add openvpn159 type veth peer name openvpn155
ip link add openvpn159 type veth peer name openvpn155
ip link set openvpn159 up
brctl addif docker0 openvpn159
ip link set openvpn155 netns openvpn
ip netns exec openvpn ip link set lo up
ip netns exec openvpn ip link set openvpn155 up
ip netns exec openvpn ip addr add 172.19.0.159/16 dev openvpn155
ip netns exec openvpn ip route add default via 172.19.0.1
