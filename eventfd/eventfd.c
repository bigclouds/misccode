#include <stdio.h>
#include <stdlib.h>
#include <sys/eventfd.h>
#include <pthread.h>
#include <unistd.h>

int efd;
int xit=0;

void *threadFunc()
{
    uint64_t buffer;
    int rc;
    int i = 0;
    while(i++ < 30){
        rc = read(efd, &buffer, sizeof(buffer));

        if(rc == 8){
        	printf("thread rc = %llu, buffer = %lu\n",(unsigned long long)rc, buffer);
        }else {
		printf("thread exit %d", rc);
		return;
	}
    }//end while
    xit=1;
}

int main()
{
    pthread_t tid1, tid2;
    int rc;
    uint64_t buf = 3;
    int flags = 0;
    int initval = 5;
    int i = 0;
    void *status;

    efd = eventfd(initval, flags);     // blocking阻塞等待
    if(efd == -1){
        perror("eventfd");
    }

    //create thread
    if(pthread_create(&tid1, NULL, threadFunc, NULL) < 0){
    	perror("pthread_create");
    }
    
    while(i++ < 3){
        buf += i;
        rc = write(efd, &buf, sizeof(buf));
    
       if(rc != 8){
           perror("write");
       }
       printf("rc = %llu, buffer = %lu\n",(unsigned long long)rc, buf);
       sleep(2);
    }//end while
    //pthread_join(tid1, &status);
    close(efd);
    printf("--------\n") ;   
    buf = 3;
    flags = EFD_SEMAPHORE;
    initval = 5;
    i = 0;
    efd = eventfd(initval, flags);     // blocking阻塞等待, 信号量方式使用eventfd
    if(efd == -1){
        perror("eventfd");
    }
    sleep(2);
    xit=0;
    if(pthread_create(&tid2, NULL, threadFunc, NULL) < 0){
        perror("pthread_create");
    }

    while(i++ < 3){
        buf += i;
        rc = write(efd, &buf, sizeof(buf));

        if(rc != 8){
            perror("write");
        }
        printf("rc = %llu, buffer = %lu\n",(unsigned long long)rc, buf);
        sleep(2);
    }
    while(!xit) sleep(1);
      close(efd);

    return 0;
}
