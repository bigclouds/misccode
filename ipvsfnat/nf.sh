#!/bin/bash
modprobe nf_conntrack
modprobe nf_nat_ipv4
modprobe nf_conntrack_ipv4
sysctl -w net.core.somaxconn=1024
sysctl -w net.ipv4.tcp_max_syn_backlog=1024
sysctl -w net.ipv4.tcp_fin_timeout=20
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_fin_wait=10
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_syn_sent=10
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_syn_recv=30
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=20
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_close_wait=20
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=120
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_close=5
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_last_ack=20
sysctl -w net.ipv4.ip_local_port_range="1000 65535"
sysctl -w net.netfilter.nf_conntrack_max=1655360
sysctl -w net.ipv4.tcp_keepalive_probes = 10
sysctl -w net.ipv4.tcp_keepalive_time = 120
sysctl -w  net.ipv4.tcp_max_orphans = 10000
ulimit -n 600000
