#include <signal.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

static void handle_prof_signal(int sig_no, siginfo_t* info, void *context)
{
  printf("Done si_signo=%d,si_code=%d,si_pid=%d,si_uid=%d,pid=%d\n", info->si_signo, info->si_code, info->si_pid, info->si_uid,  getpid());
  //exit(1);
}

void main()
{
  struct sigaction sig_action;
  memset(&sig_action, 0, sizeof(sig_action));
  sig_action.sa_sigaction = handle_prof_signal;
  sig_action.sa_flags = SA_RESTART | SA_SIGINFO;
  sigemptyset(&sig_action.sa_mask);
  sigaction(SIGPROF, &sig_action, 0);

  struct itimerval timeout;
  timeout.it_value.tv_sec=1;
  setitimer(ITIMER_PROF, &timeout, 0);

  do { } while(1);
}
