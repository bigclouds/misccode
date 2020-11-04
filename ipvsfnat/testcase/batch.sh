#!/bin/bash

for i in `seq 1 30`; do
    #n=$i
    echo -n $n && curl http://192.168.20.3:80 && echo -n ""
    #echo -n $n && curl http://192.168.10.3:80 && echo -n ""
    #echo -n $n && curl "http://\[fc00:2::3\]:8070" && echo -n ""
    #echo -n $n && curl "http://\[fc00:2::3\]:8060" && echo -n ""
    #echo -n $n && curl "http://\[fc00::1:3\]:8050" && echo -n ""
    #echo -n $n && curl "http://\[fc00::1:5\]:8080"
    #sleep 0.2
    if [ $i%1000 == 0 ]; then
	echo $i
    fi
done
