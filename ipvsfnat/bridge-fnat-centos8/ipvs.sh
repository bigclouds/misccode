#!/bin/bash
ns=test2
rr=rr
#rr=wrr
#w=-w 1
if [ "$1" = "yes" ]; then
	# tunnel mode
	ip netns exec ${ns} ipvsadm -A -t 192.168.20.3:8080 -s ${rr}
	ip netns exec ${ns} ipvsadm -a -t 192.168.20.3:8080 -r 192.168.10.5:8080 -i
	# dr mode
	#ip netns exec ${ns} ipvsadm -A -t 192.168.20.3:8080 -s ${rr}
	#ip netns exec ${ns} ipvsadm -a -t 192.168.20.3:8080 -r 192.168.10.5:8080 -g
	# nat mode
	#ip netns exec ${ns} ipvsadm -A -t 192.168.20.3:80 -s ${rr}
	#ip netns exec ${ns} ipvsadm -a -t 192.168.20.3:80 -r 192.168.10.5:8080 -m    
	# fnat-dr/nat mode
	#ip netns exec ${ns} ipvsadm -A -t 192.168.20.3:80 -s ${rr}
	#ip netns exec ${ns} ipvsadm -a -t 192.168.20.3:80 -r 192.168.10.5:8080 -g     
elif [ "$1" = "no" ]; then 
	ip netns exec ${ns} ipvsadm -D -t 192.168.20.3:80
	ip netns exec ${ns} ipvsadm -D -t 192.168.20.3:8080
	ip netns exec ${ns} ipvsadm -D -t 192.168.10.3:80
	ip netns exec ${ns} ipvsadm -D -t 192.168.10.3:8080
fi
ip netns exec ${ns} ipvsadm -ln
exit
if [ "$1" = "yes" ]; then
	ip netns exec ${ns} ipvsadm -A -t 192.168.20.3:8080 -s ${rr}
	ip netns exec ${ns} ipvsadm -a -t 192.168.20.3:8080 -r 192.168.10.5:8080 -g     
	ip netns exec ${ns} ipvsadm -a -t 192.168.20.3:8080 -r 192.168.10.6:8080 -g     
	ip netns exec ${ns} ipvsadm -a -t 192.168.20.3:8080 -r 192.168.10.7:8080 -g     

	ip netns exec ${ns} ipvsadm -A -t 192.168.20.3:9090 -s ${rr}
	ip netns exec ${ns} ipvsadm -a -t 192.168.20.3:9090 -r 192.168.10.4:9090 -g     
	ip netns exec ${ns} ipvsadm -ln

	ip netns exec ${ns} ipvsadm -A -t 192.168.20.3:5000 -s ${rr}
	ip netns exec ${ns} ipvsadm -a -t 192.168.20.3:5000 -r 192.168.10.7:5000 -g

	ip netns exec ${ns} ipvsadm -A -t 192.168.10.3:8080 -s ${rr}
	ip netns exec ${ns} ipvsadm -a -t 192.168.10.3:8080 -r 192.168.10.5:8080 -g     
	ip netns exec ${ns} ipvsadm -a -t 192.168.10.3:8080 -r 192.168.10.6:8080 -g     
	ip netns exec ${ns} ipvsadm -a -t 192.168.10.3:8080 -r 192.168.10.7:8080 -g     
	#ip netns exec ${ns} ipvsadm -d -t  192.168.10.3:8080  -r 192.168.10.7:8080
elif [ "$1" = "no" ]; then 
	ip netns exec ${ns} ipvsadm -D -t 192.168.20.3:8080
	ip netns exec ${ns} ipvsadm -D -t 192.168.20.3:9090
	ip netns exec ${ns} ipvsadm -D -t 192.168.10.3:8080
	ip netns exec ${ns} ipvsadm -ln
else
	ip netns exec ${ns} ipvsadm -ln
fi

function local_lb()
{
	ip netns exec ${ns} ipvsadm -A -t [fc00::1:3]:8050 -s ${rr}
	ip netns exec ${ns} ipvsadm -a -t [fc00::1:3]:8050 -r [fc00::1:5]:8080 -g
	#ip netns exec ${ns} ipvsadm -a -t [fc00::1:3]:8050 -r [fc00::1:6]:8080 -g
	#ip netns exec ${ns} ipvsadm -a -t [fc00:2::3]:8050 -r [fc00::1:7]:8080 -g
}

function set_ipv6_lb()
{
	# site local
	ip netns exec ${ns} ipvsadm -A -t [fc00:2::3]:8070 -s ${rr}
	ip netns exec ${ns} ipvsadm -a -t [fc00:2::3]:8070 -r [fc00::1:5]:8080 -g
	#ip netns exec ${ns} ipvsadm -a -t [fc00:2::3]:8070 -r [fc00::1:6]:8080 -g
	#ip netns exec ${ns} ipvsadm -a -t [fc00:2::3]:8070 -r [fc00::1:7]:8080 -g

	ip netns exec ${ns} ipvsadm -A -t 192.168.20.3:8080 -s ${rr}
        ip netns exec ${ns} ipvsadm -a -t 192.168.20.3:8080 -r 192.168.10.5:8080 -g

	ip netns exec ${ns} ipvsadm -A -t 192.168.10.3:8000 -s ${rr}
        ip netns exec ${ns} ipvsadm -a -t 192.168.10.3:8000 -r 192.168.10.5:8080 -g
}

function set_ipv6_lb_compat_v4()
{
	ip netns exec ${ns} ipvsadm -A -t [fc00:2::3]:8060 -s ${rr}
	ip netns exec ${ns} ipvsadm -a -t [fc00:2::3]:8060 -r [::c0a8:a05]:8080 -g   
	#ip netns exec ${ns} ipvsadm -a -t [fc00:2::3]:8060 -r [::c0a8:a06]:8080 -g   
	#ip netns exec ${ns} ipvsadm -a -t [fc00:2::3]:8060 -r [::c0a8:a07]:8080 -g 
}

function delete_lb()
{
        #ip netns exec ${ns} ipvsadm -d -t [fc00:2::3]:8070 -r [fc00::1:5]:8080
        ip netns exec ${ns} ipvsadm -D -t [fc00:2::3]:8070
        ip netns exec ${ns} ipvsadm -D -t [fc00:2::3]:8060
        ip netns exec ${ns} ipvsadm -D -t [fc00::1:3]:8050
        ip netns exec ${ns} ipvsadm -D -t 192.168.20.3:8080
        ip netns exec ${ns} ipvsadm -D -t 192.168.10.3:8000
}

if [ "$1" = "no" ]; then
	delete_lb
	exit
fi
#set_ipv6_lb
#set_ipv6_lb_compat_v4
#local_lb
ip netns exec ${ns} ipvsadm -ln
