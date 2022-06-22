#include <linux/kernel.h>
#include <linux/module.h>
#include <net/net_namespace.h>
#include <linux/rcupdate.h>
#include <linux/init.h>
#include <net/ip_fib.h>
#include <linux/inetdevice.h>
#include <linux/inet.h>
#include <linux/string.h>

#define NIPQUAD(addr) \
((unsigned char *)&addr)[0], \
((unsigned char *)&addr)[1], \
((unsigned char *)&addr)[2], \
((unsigned char *)&addr)[3]

__be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh)
{
        nh->nh_saddr = inet_select_addr(nh->nh_dev,
                                        nh->nh_gw,
                                        nh->nh_parent->fib_scope);
        nh->nh_saddr_genid = atomic_read(&net->ipv4.dev_addr_genid);

        return nh->nh_saddr;
}   

static int get_src_addr(struct net *net, __be32 daddr, __be32 saddr){
	__be32 src;
	int ifd = 0;

	struct fib_result res;
	struct flowi4 fl4;
	char buf[16];
	char *name = NULL;
	
	if (net == NULL) {
		net = &init_net;
	}
	res.fi = NULL;
        res.table = NULL;
	fl4.flowi4_oif = 0;
        fl4.flowi4_iif = 3;
	fl4.flowi4_scope = RT_SCOPE_UNIVERSE; 
        fl4.flowi4_flags = 0;
	fl4.daddr = daddr;
	fl4.saddr = saddr;

	//rcu_read_lock();
	if (fib_lookup(net, &fl4, &res) == 0){
		src = FIB_RES_PREFSRC(&init_net, res);
		name = FIB_RES_DEV(res)->name;
		ifd = FIB_RES_OIF(res);
	}
	//rcu_read_unlock();
	snprintf(buf, 15, "%pI4", &src);
	printk("%s, outdev name=%s,id=%d  %d\n", buf, name, ifd, res.type == RTN_UNICAST);
        return src;
}

static int __init hello_init(void)
{
	char *dip = "10.0.0.1";
	char *sip = "192.168.122.1";
	char buf[16];
	__be32 daddr = in_aton(dip);
	__be32 saddr = in_aton(sip);



	printk(KERN_INFO "hello_init\n");
	saddr = get_src_addr(NULL, daddr, saddr);
	snprintf(buf, 15, "%pI4", &saddr);
	printk("saddr = %s\n", buf);
	return 0;
}



static void __exit hello_exit(void)
{
	printk(KERN_INFO "hello_exit\n");
}

module_init(hello_init)
module_exit(hello_exit)
MODULE_LICENSE("GPL v2");
