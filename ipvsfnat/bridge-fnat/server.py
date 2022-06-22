import socket
BUFSIZE = 15000000
ip_port = ('0.0.0.0', 8080)
server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server.setsockopt(socket.SOL_SOCKET,socket.SO_NO_CHECK,1)
server.bind(ip_port)
while True:
    data, client_addr = server.recvfrom(BUFSIZE)
    print('server :', len(data), client_addr)
    # print('server :', len(data), data, client_addr)
    server.sendto(data.upper(), client_addr)
 
server.close()
