#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

void test_big_shift(){
int i = 1, j = 0x80000000; //设int为32位
i = i << 33;   // 33 % 32 = 1 左移1位,i变成2
j = j << 33;   // 33 % 32 = 1 左移1位,j变成0,最高位被丢弃
printf("i=%d,j=%d\n", i, j);
}



int main(){
	char s[40];//要转换成的字符数组
	int j = -1;
	int i = 0x40000000;
	printf("j %d,%0x\n", j, j);
	j = j - 1;
	printf("j %d,%0x\n", j, j);
	printf("i %d,%0x\n", i, i);

	i = i << 1;
	printf("i %d,%0x\n", i, i);



	test_big_shift();
}
