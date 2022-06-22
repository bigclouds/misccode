#!/bin/bash
rr=rr
#rr=wrr
#w=-w 1
if [ "$1" = "yes" ]; then
	ip netns exec nslb ipvsadm -A -t 192.168.20.3:8080 -s ${rr}
	ip netns exec nslb ipvsadm -a -t 192.168.20.3:8080 -r 192.168.10.5:8085 -g     
	ip netns exec nslb ipvsadm -a -t 192.168.20.3:8080 -r 192.168.10.6:8086 -g     
	ip netns exec nslb ipvsadm -a -t 192.168.20.3:8080 -r 192.168.10.7:8087 -g     

	ip netns exec nslb ipvsadm -A -t 192.168.10.3:8080 -s ${rr}
	ip netns exec nslb ipvsadm -a -t 192.168.10.3:8080 -r 192.168.10.5:8085 -g     
	ip netns exec nslb ipvsadm -a -t 192.168.10.3:8080 -r 192.168.10.6:8086 -g     
	ip netns exec nslb ipvsadm -a -t 192.168.10.3:8080 -r 192.168.10.7:8087 -g     
	#ip netns exec nslb ipvsadm -d -t  192.168.10.3:8080  -r 192.168.10.7:8080
elif [ "$1" = "no" ]; then 
	ip netns exec nslb ipvsadm -D -t 192.168.20.3:8080
	ip netns exec nslb ipvsadm -D -t 192.168.10.3:8080
else
	ip netns exec nslb ipvsadm -ln
	exit
fi
