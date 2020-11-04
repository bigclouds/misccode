#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <errno.h>
#include <sys/types.h>
#include <asm/types.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <linux/netlink.h>
#include <linux/rtnetlink.h>
#include <linux/route.h>
 
#define NLMSG_TAIL(nmsg) \
        ((struct rtattr *) (((void *) (nmsg)) + NLMSG_ALIGN((nmsg)->nlmsg_len)))
struct iplink_req {
        struct nlmsghdr         n;
        char                    buf[1024];
};

int addattr_l(struct nlmsghdr *n, int maxlen, int type, const void *data,
              int alen) 
{               
        int len = RTA_LENGTH(alen);
        struct rtattr *rta;
                        
        if (NLMSG_ALIGN(n->nlmsg_len) + RTA_ALIGN(len) > maxlen) {
                fprintf(stderr,
                        "addattr_l ERROR: message exceeded bound of %d\n",
                        maxlen);
                return -1;
        }       
        rta = NLMSG_TAIL(n);
        rta->rta_type = type;
        rta->rta_len = len;
        if (alen) 
                memcpy(RTA_DATA(rta), data, alen);
        n->nlmsg_len = NLMSG_ALIGN(n->nlmsg_len) + RTA_ALIGN(len);
        return 0;
}

int main(int argc, char *argv[])
{
	int socket_fd, qlen=2000;
	int err = 0;
	fd_set rd_set;
	struct timeval timeout;
	int select_r;
	int read_r;
  	int addr_len;
	int sndbuf = 32768;
	struct sockaddr_nl sa;
	struct rtattr *rta;
	char *name = "1122";

	if (argc==3)
	{
		name = argv[1];
		qlen = atoi(argv[2]);
	} else {
		printf("needs nicname qlen");
		return 0;
	}

	struct iplink_req req = {
                .n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
                .n.nlmsg_flags = NLM_F_REQUEST,
                .n.nlmsg_type = RTM_NEWLINK,
        };

	/*
	struct nlmsghdr nh = {
		.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
		.nlmsg_flags = NLM_F_REQUEST,
		.nlmsg_type = RTM_NEWLINK,
	}
	rta = NLMSG_TAIL(n);
	rta->rta_type = type;
        rta->rta_len = RTA_LENGTH(4);	
	memcpy(RTA_DATA(rta), &qlen, 4);
	nh.nlmsg_len = NLMSG_ALIGN(n->nlmsg_len) + RTA_ALIGN(len);
	*/
	addattr_l(&req.n, sizeof(req), IFLA_TXQLEN, &qlen, 4);
	addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, strlen(name) + 1);
 
 
	/*打开NetLink Socket*/
	socket_fd = socket(AF_NETLINK, SOCK_RAW| SOCK_CLOEXEC, NETLINK_ROUTE);
	setsockopt(socket_fd, SOL_SOCKET, SO_RCVBUF, &sndbuf, sizeof(sndbuf));
 
	/*设定接收类型并绑定Socket*/
	bzero(&sa, sizeof(sa));
	sa.nl_family = AF_NETLINK;
	sa.nl_groups = 0;
	//sa.nl_groups = RTMGRP_LINK | RTMGRP_IPV4_IFADDR | RTMGRP_IPV4_ROUTE | RTMGRP_IPV6_IFADDR | RTMGRP_IPV6_ROUTE;
	if( bind(socket_fd, (struct sockaddr *) &sa, sizeof(sa)) < 0){
		return -1;
	}

	addr_len = sizeof(sa);
        if (getsockname(socket_fd, (struct sockaddr *)&sa,
                        &addr_len) < 0) {
                return -1;
        }
        if (addr_len != sizeof(sa)) {
                fprintf(stderr, "Wrong address length %d\n", addr_len);
                return -1;
        }
        if (sa.nl_family != AF_NETLINK) {
                fprintf(stderr, "Wrong address family %d\n",
                        sa.nl_family);
                return -1;
        }

	struct sockaddr_nl nladdr = { .nl_family = AF_NETLINK };
        struct iovec iov = {
                .iov_base = &req.n,
                .iov_len = req.n.nlmsg_len
        };
        struct msghdr msg = {
                .msg_name = &nladdr,
                .msg_namelen = sizeof(nladdr),
                .msg_iov = &iov,
                .msg_iovlen = 1,
        };
	
	if (sendmsg(socket_fd, &msg, 0) <0){
		perror("Cannot talk to rtnetlink");
	}

	close(socket_fd);
}
