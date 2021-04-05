# Listener: Serverside
import socket

HOST = '' # if this is an empty string, then I can listen for any ip addresses not only localhost
PORT = 8089

serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
serversocket.bind((HOST, PORT))
serversocket.listen(5) # become a server socket, maximum 5 connections

try:
    while True:
        connection, address = serversocket.accept()
        buf = connection.recv(64)
        if len(buf) > 0:
            recived = buf.decode('utf-8')
            print(recived)

except KeyboardInterrupt:
    serversocket.close()
    print(' received, shutting down the listener')
    serversocket.close()