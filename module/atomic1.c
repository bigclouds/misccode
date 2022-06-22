#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/refcount.h>

static atomic_t BiscuitOS_counter = ATOMIC_INIT(8);
refcount_t              refcnt;

/* atomic_* */
static int __init atomic_demo_init(void)
{
	int val;

	refcount_set(&refcnt, 1);

	/* Atomic cmpxchg: Old == original */
	val = atomic_cmpxchg(&BiscuitOS_counter, 8, 9);

	printk("[0]Atomic: oiginal-> %d new-> %d\n", val,
			atomic_read(&BiscuitOS_counter));

	/* Atomic cmpxchg: Old != original */
	val = atomic_cmpxchg(&BiscuitOS_counter, 1, 5);


	printk("[1]Atomic: original-> %d new-> %d\n", val,
			atomic_read(&BiscuitOS_counter));
	val = refcount_dec_if_one(&refcnt);
	printk("val = %d, refcnt = %d\n", val, refcount_read(&refcnt));

	return 0;
}

static void __exit ip_vs_cleanup(void)
{}


module_init(atomic_demo_init);
module_exit(ip_vs_cleanup);
MODULE_LICENSE("GPL");
