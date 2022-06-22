#include <stdio.h>
#include <string.h>

static int atou(const char *s)
{       
        int i = 0;
        while (isdigit(*s))
                i = i * 10 + (*s++ - '0');
        return i;
}

int str2int(char* data, const char* str)
{       
        char *tmp;
        char num[6], *pnum = num;
        int i = 0;
        int v;
        
        if((tmp = strstr(data, str))){
                tmp = tmp + strlen(str);
                if (*tmp != '='){
                        return 0;
                }
                tmp += 1; 
                while(tmp != NULL && *tmp != ' ' && *tmp != ',' && *tmp != '\0'){
                        if(!isdigit(*tmp))
                                return 0;
                        *pnum++ = *tmp++;
                        i++;
                        if (i>=6){
                                return 0;
			}
                }
                *pnum = '\0';
                v = atou(num);
                return v;
        }
        return 0;
}
int main(void)
{
	int v1, v2;
	char *str="ESTABLISHED=300,FIN=50";

	v1 = str2int(str, "ESTABLISHED");
	v2 = str2int(str, "FIN");
	printf("v1=%d, v2=%d\n", v1, v2);

	return 0;
}
