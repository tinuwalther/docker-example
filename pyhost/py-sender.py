class colors: 
    '''Colors class:reset all colors with colors.reset'''
    reset         = '\033[0m'
    bold          = '\033[01m'
    disable       = '\033[02m'
    underline     = '\033[04m'
    reverse       = '\033[07m'
    strikethrough = '\033[09m'
    invisible     = '\033[08m'

    class fg: 
        ''' Define the foreground-colors
        use as colors.fg.colorname
        '''
        black      = '\033[30m'
        red        = '\033[31m'
        green      = '\033[32m'
        orange     = '\033[33m'
        blue       = '\033[34m'
        purple     = '\033[35m'
        cyan       = '\033[36m'
        lightgrey  = '\033[37m'
        darkgrey   = '\033[90m'
        lightred   = '\033[91m'
        lightgreen = '\033[92m'
        yellow     = '\033[93m'
        lightblue  = '\033[94m'
        pink       = '\033[95m'
        lightcyan  = '\033[96m'

    class bg: 
        ''' Define the background-colors
        use as colors.bg.colorname
        '''
        black     = '\033[40m'
        red       = '\033[41m'
        green     = '\033[42m'
        orange    = '\033[43m'
        blue      = '\033[44m'
        purple    = '\033[45m'
        cyan      = '\033[46m'
        lightgrey = '\033[47m'

# Listener: Clientside
import sys, socket

try:

  if len(sys.argv) == 1 or len(sys.argv) > 3:
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

except Exception as e:
  if e.args[0] == 111:
    print('{0}{1}{2}{3}'.format(colors.fg.cyan, "[INFO] [" + recipient + "] ", e.args[1], colors.reset))
  else:
    print('{0}{1}{2}{3}'.format(colors.fg.orange, "[WARN] [" + recipient + "] ", e, colors.reset))