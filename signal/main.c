#include <signal.h>
#include <stdio.h>

const char *signal_name(int signum, char *namebuf, size_t bufsize)
{       
#if HAVE_DECL_SYS_SIGLIST
    if (signum >= 0 && signum < N_SIGNALS) {
        const char *name = sys_siglist[signum];
        if (name) {
            return name;
        }
    }
#endif  

    snprintf(namebuf, bufsize, "signal %d", signum);
    return namebuf;
}

const void func(int sig){
	printf("receive %d\n", sig);
}
 
int main(void)
{
    char namebuf[32];
    char *signame;
    int i;

    for(i=0; i<sizeof(namebuf); i++){
    	namebuf[i] = '\0';
    }
    signame = signal_name(SIGALRM, namebuf, sizeof namebuf);
    //printf("SIGALRM=%s\n", signame);   /* never reached */
    //signame = signal_name(SIGINT, namebuf, sizeof namebuf);
    //printf("SIGINT=%s\n", signame);   /* never reached */
    /* using the default signal handler */
    //raise(SIGTERM);
    signal(SIGALRM, SIG_DFL);
    signal(SIGALRM, func);
    signal(SIGKILL, func);
    raise(SIGALRM);
    //raise(SIGINT);
    printf("Exit main()\n");   /* never reached */
}
