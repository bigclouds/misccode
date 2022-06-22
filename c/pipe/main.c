#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
 
int main(void){
	int fd[2];
	int ret;
	char writebuf[8192];
	char readbuf[8192];
 
	ret = pipe(fd);
	if(ret != 0) {
		printf("create pipe failed!\n");
		return -1;
	}
	bzero(readbuf, sizeof(readbuf));
        //从pipe的fd[0]里读数据
	read(fd[0], readbuf, sizeof(readbuf));
	printf("read from pipe[0] = %s\n", readbuf);
 
	strcpy(writebuf, "Hello World!");
	memset(writebuf,'1',8192);
	writebuf[8191] = '\n';
        //向pipe的fd[1]里写数据
	write(fd[1], writebuf, strlen(writebuf));
	printf("write to pipe[1] = %s\n", writebuf);
 
        //从pipe的fd[0]里读数据
	read(fd[0], readbuf, sizeof(readbuf));
	printf("read from pipe[0] = %s\n", readbuf);
 
	return 0;
}
