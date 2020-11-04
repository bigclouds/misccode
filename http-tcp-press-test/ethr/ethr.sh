ips="192.168.10.7"
cport=8888
dport=9999
tcport=9998
lport=9996
hport=9899
hsport=9799
#ip netns exec test7   ethr -s --ports 'control=8888,tcp=9999,http=9899,https=9799'
#ip netns exec test3 ./ethr -c 192.168.20.3  -p tcp -t c -n 10  --ports 'control=8888,tcp=9999,udp=9999,http=9899,https=9799'


ips="192.168.10.6"
cport=8388
dport=9499
tcport=9498
lport=9496
hport=9399
hsport=9299
#ip netns exec test6   ethr -s --ports 'control=8888,tcp=9999,http=9899,https=9799'
#ip netns exec test3 ./ethr -c 192.168.20.3  -p tcp -t c -n 10  --ports 'control=8388,tcp=9499,udp=9499,http=9399,https=9299'


ips="192.168.10.5"
cport=8088
dport=9199
tcport=9198
lport=9196
hport=9099
hsport=8999
#ip netns exec test5   ethr -s --ports 'control=8888,tcp=9999,http=9899,https=9799'
#ip netns exec test3 ./ethr -c 192.168.20.3  -p tcp -t c -n 10  --ports 'control=8088,tcp=9199,udp=9199,http=9099,https=8999'

if [ "$1" = "yes" ]; then
    for i in $ips; do
        ip netns exec test2 ipvsadm -A -t 192.168.20.3:$cport -s rr
        ip netns exec test2 ipvsadm -a -t 192.168.20.3:$cport -r $i:8888 -g

        ip netns exec test2 ipvsadm -A -t 192.168.20.3:$dport -s rr
        ip netns exec test2 ipvsadm -a -t 192.168.20.3:$dport -r $i:9999 -g

        ip netns exec test2 ipvsadm -A -t 192.168.20.3:$tcport -s rr
        ip netns exec test2 ipvsadm -a -t 192.168.20.3:$tcport -r $i:9998 -g

        ip netns exec test2 ipvsadm -A -t 192.168.20.3:$lport -s rr
        ip netns exec test2 ipvsadm -a -t 192.168.20.3:$lport -r $i:9996 -g

        ip netns exec test2 ipvsadm -A -t 192.168.20.3:$hport -s rr
        ip netns exec test2 ipvsadm -a -t 192.168.20.3:$hport -r $i:9899 -g

        ip netns exec test2 ipvsadm -A -t 192.168.20.3:$hsport -s rr
        ip netns exec test2 ipvsadm -a -t 192.168.20.3:$hsport -r $i:9799 -g

        dport=`expr $dport + 1`
        cport=`expr $cport + 1`
        bport=`expr $bport + 1`
        lport=`expr $lport + 1`
        hport=`expr $hport + 1`
        hsport=`expr $hsport + 1`
    done
fi

if [ "$1" = "no" ]; then
    for i in $ips; do
	ip netns exec test2 ipvsadm -D -t 192.168.20.3:$cport
	ip netns exec test2 ipvsadm -D -t 192.168.20.3:$dport
	ip netns exec test2 ipvsadm -D -t 192.168.20.3:$tcport
	ip netns exec test2 ipvsadm -D -t 192.168.20.3:$lport
	ip netns exec test2 ipvsadm -D -t 192.168.20.3:$hport
	ip netns exec test2 ipvsadm -D -t 192.168.20.3:$hsport

        dport=`expr $dport + 1`
        cport=`expr $cport + 1`
        bport=`expr $bport + 1`
        lport=`expr $lport + 1`
        hport=`expr $hport + 1`
        hsport=`expr $hsport + 1`
    done
fi

ip netns exec test2  ipvsadm -ln
