#!/bin/bash


echo 256>/sys/block/dm-1/queue/nr_requests 
echo 256>/sys/block/dm-0/queue/nr_requests 
sysctl -w net.core.somaxconn=1024
sysctl -w net.ipv4.tcp_rmem="4096 87380 6291456"
sysctl -w net.ipv4.tcp_wmem="4096 87380 6291456"
sysctl -w net.core.rmem_max = 16777216
sysctl -w net.core.wmem_max = 16777216
sysctl -w net.core.netdev_max_backlog=1500
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=3600
for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo "performance" > $file; done
for file in /sys/block/sd*/queue/nr_requests; do cat  $file; done

#systemctl stop ksm.service ksmtuned.service
#systemctl disable ksm.service ksmtuned.service

#nic 
#ethtool -g enp59s0f1 show ring size
#ethtool -G enp59s0f1 rx 1024 tx 1024
