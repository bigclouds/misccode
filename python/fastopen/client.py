# -- coding:utf-8 --
#!/usr/bin/env python
import socket
import sys

MSG_FASTOPEN = 0x20000000

host = sys.argv[1]
print("connecting to host {} ...".format(host))

addr = (host, 8005)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 以 Fast Open 方式发送数据，不需要 connect
s.sendto("2hello!", MSG_FASTOPEN, addr)

print s.recv(1000)
