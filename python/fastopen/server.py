# -- coding:utf-8 --
import socket

TCP_FASTOPEN = 23

def listen():
    connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    connection.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    # 设置 TCP Fast Open 队列
    connection.setsockopt(socket.SOL_TCP, TCP_FASTOPEN, 5)
    connection.bind(('0.0.0.0', 8005))
    connection.listen(10)
    while True:
        current_connection, address = connection.accept()
        while True:
            current_connection.send("1hello!")
            data = current_connection.recv(2048)

            if data:
                current_connection.send(data)
                print data
            current_connection.close()
            break


if __name__ == "__main__":
    try:
        listen()
    except KeyboardInterrupt:
        pass
