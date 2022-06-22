ip netns  exec openvpn  /usr/sbin/openvpn --suppress-timestamps --nobind --config /etc/openvpn/client/client.conf

#ip netns add openvpn
#ip link add openvpn157 type veth peer name openvpn155
#ip link set  openvpn157 up  
#brctl addif docker0 openvpn157
#ip link set  openvpn155 netns openvpn 
#ip netns exec openvpn ip link set openvpn155 up   
#ip netns exec openvpn ip link set lo up   
#ip netns exec openvpn ip addr add 172.17.0.157/16 dev openvpn155 
#ip netns exec openvpn ip route add default via 172.17.0.1
