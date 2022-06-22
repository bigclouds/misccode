#!/bin/bash

modprobe -r ipvs_fnat ; modprobe  ipvs_fnat vmdev="tap"  debug_level=0
#insmod ./ipvs_fnat.ko vmdev="vnet" debug_level=1
# wrk -H "Connection: Close"
ip netns exec ${ns} ./wrk -c 5000 -t 500 -d 1000  http://173.20.12.139:8080/
ip netns exec ${ns} ab -c 2000 -n 200000 http://173.20.12.139:8080/

# test hook priority
iptables -I FORWARD -m physdev --physdev-is-bridged --physdev-out vnet5 -j DROP
iptables -I FORWARD -m physdev --physdev-is-bridged --physdev-in vnet5 -j DROP


#test max connections

sysctl -w net.ipv4.ip_local_port_range="2001 65535"

#./10m-svr 3000 3001 1 2000
#./10m-cli 10.10.10.22 3000 3001 40000 10 1 10 10 2000
