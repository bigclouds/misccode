#include <linux/if_tun.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/if.h>
#include <error.h>
#include <string.h>   //memset
#include <arpa/inet.h> //ntohs
#include <stdio.h>

int tap_create(char *dev, int flags);

int main(int argc, char *argv[])
{
        int tap,ret,i,ret_all=0,time=0,pkts=0;
        char *tap_name = NULL;
        unsigned char buf[1024];

	if (argc < 2)
	{
	printf("Please input tap's name\n");
	return -1; 
	}


	if (argc == 2)
	{
		tap_name = argv[1];
	}
        tap = tap_create(tap_name, IFF_TAP | IFF_NO_PI);

        if (tap < 0) {
                perror("tap_create");
                return 1;
        }
        printf("TAP name is %s\n", tap_name);

        while (1) 
	{ 
		ret = read(tap, buf, sizeof(buf));
		if (ret < 0) {
			printf("delay 10 secs\n");
			sleep(10);
			continue;
		}

		pkts++;
		ret_all+=ret;
		printf("read all %d bytes %d pkts\n", ret_all, pkts);
		for(i=0;i<ret;i++)
		{
			if(i%16==0 && i!=0)
				printf("\n");
			printf("%02x ",buf[i]);
		}
		printf("\n");
				
		ret = write(tap, buf, ret);
		printf("write %d bytes\n", ret);
		for(i=0;i<ret;i++)
		{
			if(i%16==0 && i!=0)
				printf("\n");
			printf("%02x ",buf[i]);
		}
		printf("\n");
	}

	return 0;
}
	 
int tap_create(char *dev, int flags)
{
	struct ifreq ifr;
	int fd, err;

        if ((fd = open("/dev/net/tun", O_RDWR|O_NONBLOCK)) < 0)
         	return fd;

     memset(&ifr, 0, sizeof(ifr));
     ifr.ifr_flags |= flags;
     if (*dev != '\0')
         strncpy(ifr.ifr_name, dev, IFNAMSIZ);
     if ((err = ioctl(fd, TUNSETIFF, (void *)&ifr)) < 0) {
         close(fd);
         return err;
     }
     strcpy(dev, ifr.ifr_name);


     return fd;
 }
