import socket

BUFSIZE = 80000
#66635 - 20 - 4 - 8
LEN = 65503
LEN = 14072
# 1500 - 20 -4 -8
LEN = 1468
LEN = 1500

def udp1():
    ip = "127.0.0.1"
    ip1 = "192.168.20.3"
    ipport = ('0.0.0.0', 9080)
    client = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
    client.bind(ipport)
    #client.setsockopt(socket.SOL_SOCKET,socket.SO_NO_CHECK,1)
    i = 0
    while True:
        #msg = raw_input(">> ")
        msg = "bhu123abcg" * 15000
        ip_port = (ip1, 80)
	data1 = str(msg[0:LEN])
        client.sendto(data1, ip_port)
 
        data, server_addr = client.recvfrom(BUFSIZE)
	same = data == data1.upper()
        print('client : ', len(data), same, server_addr)
        # print('client : ', len(data), data, server_addr)
        i = i + 1
        if i >= 1:
            break
    client.close()
c = 1
while c>0:
    udp1()
    c = c - 1
