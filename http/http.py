# coding:utf-8

import socket

from multiprocessing import Process


def handle_client(client_socket):
    """
    处理客户端请求
    """
    request_data = client_socket.recv(1024)
    # print("request data:", request_data)
    # 构造响应数据
    response_start_line = "HTTP/1.1 200 OK\r\n"
    response_headers = "Server: My server\r\n"
    response_body = "<h1>Python HTTP Test</h1>\n"
    response = response_start_line + response_headers + "\r\n" + response_body

    # 向客户端返回响应数据
    # print response
    client_socket.send(response.encode("utf-8"))

    # 关闭客户端连接
    client_socket.close()


if __name__ == "__main__":
    #server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(("::", 8080))
    #server_socket.bind(("fc00::1:5", 8080))
    #server_socket.bind(("0.0.0.0", 8080))
    server_socket.listen(128)
    i = 0

    while True:
        client_socket, client_address = server_socket.accept()
        # print("[%s, %s]用户连接上了" % client_address)
        handle_client_process = Process(target=handle_client, args=(client_socket,))
        handle_client_process.start()
        client_socket.close()
        i = i + 1
        print i
        if i % 100 == 0:
            print i
