/*  
 *   *  hello.c
 *    *  简单的 hello 内核模块
 *     */
 
#include <linux/module.h>       /* 所有模块使用 module.h */
#include <linux/kernel.h>       /* 包含内核常用的函数声明等 */
#include <linux/init.h>         /* 进行内存初始化和清理 */
#include <linux/delay.h>
 
MODULE_AUTHOR("author");
MODULE_DESCRIPTION("This is a demo.");
MODULE_VERSION("0.0.1");
MODULE_LICENSE("GPL");
 

extern int rcu_cpu_stall_suppress;
extern bool rcu_gp_is_expedited(void);

static int count = 10;
module_param_named(count, count, int, 0444);
MODULE_PARM_DESC(count, "Set size");

struct work_struct my_work; /* 定义一个work */
void my_work_func(struct work_struct *work) {  /* 定义一个work处理函数 */
    int i = 0;
    for(i=0;i<=count;i++){
	msleep(1);
	if (i % 100 == 0)
		printk(KERN_INFO "Hello %d\n", i);
	synchronize_rcu();
    }
}



static int __init hello_init(void)
{
    int i = 0;
    printk(KERN_INFO "Hello, world! %d, %d\n", count, rcu_cpu_stall_suppress);
    printk(KERN_INFO "Hello, world! rcu_scheduler_active=%d, rcu_state=%d\n", rcu_scheduler_active, rcu_gp_is_expedited());
    for(i=0;i<10;i++){
	msleep(10);
	if (i % 5 == 0)
		printk(KERN_INFO "Hello %d\n", i);
	synchronize_rcu();
    }

    INIT_WORK(&my_work, my_work_func);
    schedule_work(&my_work);
    return 0;
}
 
static void __exit hello_exit(void)
{
    cancel_work_sync(&my_work);
    printk(KERN_INFO "Goodbye, world!\n");
}
 
module_init(hello_init);
module_exit(hello_exit);
