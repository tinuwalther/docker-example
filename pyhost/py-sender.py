# Listener: Clientside
import sys, socket

if len(sys.argv) == 1:
  recipient = ''
  message = ''
elif len(sys.argv) == 3:
  recipient = str(sys.argv[1])
  message = str(sys.argv[2])

if len(recipient) == 0 or len(message) == 0 or recipient == '--help':
  print('Usage: python3 ' + str(sys.argv[0]) + ' <argument>')
  print('  Argument: hostname or ip-address to send a message')
  print('  Example:  172.17.0.2 "Send message from me"')
else:
  clientsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  clientsocket.connect((recipient, 8089))
  clientsocket.send(bytes(socket.gethostname() + ': ' + message , 'UTF-8'))