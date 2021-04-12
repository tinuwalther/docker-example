# Define colors
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
import os, sys, getopt, socket

# Show a detailed help like in powershell
def usage():
  import os, sys, getopt
  '''Show a detailed help like in powershell'''
  print(f"\nNAME")
  print(f"    {os.path.basename(str(sys.argv[0]))}\n\n")

  print("SYNOPSIS")
  print(f"    Send a message to the listener\n\n")

  print("SYNTAX")
  print(f"    python3 {str(sys.argv[0])} -l <listener> -m <message>\n\n")

  print("DESCRIPTION")
  print(f"    Send a message to the listener, the listener run a command based on the message\n\n")

  print("PARAMETERS")
  print(f"    -l listener name or ip address\n\n")

  print("PARAMETERS")
  print(f"    -m keyword of the message to send: srf, wetter or covid are active\n\n")

  print(f"    -------------------------- EXAMPLE 1 --------------------------\n")
  print(f"    python3 {str(sys.argv[0])} -l pyhost1 -m wetter\n\n")

  print(f"    -------------------------- EXAMPLE 2 --------------------------\n")
  print(f"    python3 {str(sys.argv[0])} -l pyhost1 -m srf\n\n")

  print(f"    -------------------------- EXAMPLE 3 --------------------------\n")
  print(f"    python3 {str(sys.argv[0])} -l pyhost1 -m covid\n\n")

# Define the main function
def main(argv):
  '''main function'''
  try:
    recipient = ''; message = ''

    opts, args = getopt.getopt(argv, "l:m:", ['help:h'])
    if not opts:
      usage()

    for opt, arg in opts:
      if opt in ['-l']:
        recipient = arg
      elif opt in ['-m']:
        message = arg
      elif opt in ('-h', '--help', 'help'):
        usage()

    if len(recipient) > 0 and len(message) > 0:
      clientsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
      clientsocket.connect((recipient, 8089))
      clientsocket.send(bytes(socket.gethostname() + ': ' + message , 'UTF-8'))

  except getopt.GetoptError:
      usage()

  except Exception as e:
    if e.args[0] == 111:
      print('{0}{1}{2}{3}'.format(colors.fg.cyan, "[INFO] [" + recipient + "] ", e.args[1], colors.reset))
    else:
      print('{0}{1}{2}{3}'.format(colors.fg.orange, "[WARN] [" + recipient + "] ", e, colors.reset))

# Call the main function
if __name__ =='__main__':
    main(sys.argv[1:])