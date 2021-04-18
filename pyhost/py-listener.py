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

# Show a detailed help like in powershell
def usage():
  import os, sys, getopt
  '''Show a detailed help like in powershell'''
  print(f"\nNAME")
  print(f"    {os.path.basename(str(sys.argv[0]))}\n\n")

  print("SYNOPSIS")
  print(f"    Listen for a message from a sender\n\n")

  print("SYNTAX")
  print(f"    python3 {str(sys.argv[0])} -s <sender> -p <port> -c <max. connections>\n\n")

  print("DESCRIPTION")
  print(f"    Listen for a message from a sender, the listener run a command based on the message\n\n")

  print("PARAMETERS")
  print(f"    -s sender name or ip address\n\n")

  print("PARAMETERS")
  print(f"    -p TCP port to listen\n\n")

  print("PARAMETERS")
  print(f"    -c max. allowed connections\n\n")

  print(f"    -------------------------- EXAMPLE 1 --------------------------\n")
  print(f"    python3 {str(sys.argv[0])}\n\n")

  print(f"    -------------------------- EXAMPLE 2 --------------------------\n")
  print(f"    python3 {str(sys.argv[0])} -s pyhost1\n\n")

  print(f"    -------------------------- EXAMPLE 3 --------------------------\n")
  print(f"    python3 {str(sys.argv[0])} -s pyhost1 -p 8089\n\n")

  print(f"    -------------------------- EXAMPLE 4 --------------------------\n")
  print(f"    python3 {str(sys.argv[0])} -s pyhost1 -p 8089 -c 5\n\n")

# Newsreader functions
def srfnewsreader(url, search_from, search_to, links=True, images=True, emphasis=True):
    '''Reads the given url and print a markdown'''
    now = datetime.now()
    response = requests.get(url)
    if(response.status_code == 200):
        site = url.split('/')[2]
        print(colors.bold + colors.fg.blue +'{1}{0}{4} {2}{0}{3}{0}'.format('\n', '>' * 68, f'NEWS FROM: {site}', '<' * 68, now.strftime("%Y-%m-%d %H:%M:%S")) + colors.reset)
        html_content = response.content.decode('utf-8')
        # Format to markdown
        md = html2text.HTML2Text()
        md.ignore_links    = not links
        md.ignore_images   = not images
        md.ignore_emphasis = not emphasis
        md.body_width      = 68
        md_data            = md.handle(html_content)
        #read from start-pattern to end-pattern
        start = md_data.find(search_from)
        end   = md_data.find(search_to)
        stream = [(md_data[start:end])]
        for i in stream:
            if(i is not None):
                line = i
                line = line.replace('Mit Video\n\n','')
                line = line.replace('Mit Audio\n\n','')
                line = line.replace('###  Neueste Beiträge\n\n','')
                line = line.replace('  * ','### ')
                print('{0}{1}{2}'.format(colors.fg.green, line, colors.reset))

        print(colors.bold + colors.fg.blue +'END'+ colors.reset)

def covidnewsreader(url, search_from, search_to, links=True, images=True, emphasis=True):
    '''Reads the given url and print a markdown'''
    response = requests.get(url)
    if(response.status_code == 200):
        html_content = response.content.decode('utf-8')
        # Format to markdown
        md = html2text.HTML2Text()
        md.ignore_links    = not links
        md.ignore_images   = not images
        md.ignore_emphasis = not emphasis
        md.body_width      = 68
        md_data            = md.handle(html_content)
        #read from start-pattern to end-pattern
        start = md_data.find(search_from)
        end   = md_data.find(search_to)
        stream = [(md_data[start:end])]
        for i in stream:
            if(i is not None):
                line = i
                line = line.replace('\n---|--- ','')
                line = line.replace('| ', ': ')
                line = line.replace('Detailinformationen\n\n','')
                line = line.replace('7-⁠Tage-⁠Schnitt\n\n','')
                line = line.replace('Beschreibungen einblenden\n\n','')
                line = line.replace('Neu gemeldet\n\n','')
                line = line.replace('\nFälle\n','')
                #print('{0}{1}{2}'.format(colors.fg.green, line, colors.reset))

    return stream

# Start the listener
def start(HOST, PORT, connections):
  '''Start the listener'''
  #HOST = '' # if this is an empty string, then I can listen for any ip addresses not only localhost
  serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  serversocket.bind((HOST, PORT))
  serversocket.listen(connections) # become a server socket, maximum 5 connections

  try:
    if HOST == '':
        print(f'Listen for any address on {PORT}')
    else:
        print(f'Listen for {HOST} on {PORT}')
    
    while True:
      connection, address = serversocket.accept()
      buf = connection.recv(64)
      if len(buf) > 0:
        recived = buf.decode('utf-8')
        print(recived)
      if re.search("srf", recived):
        srfnewsreader('https://www.srf.ch/news/neuste-beitraege', '###  Neueste Beiträge','## Footer', False, False)
      elif re.search("covid", recived):
        site = 'www.covid19.admin.ch'
        now  = datetime.now()
        print(colors.bold + colors.fg.blue +'{1}{0}{4} {2}{0}{3}{0}'.format('\n', '>' * 68, f'NEWS FROM: {site}', '<' * 68, now.strftime("%Y-%m-%d %H:%M:%S")) + colors.reset)
        
        ### Get data from www.covid19.admin.ch
        data = covidnewsreader('https://www.covid19.admin.ch/de/overview?ovTime=total', '### Laborbestätigte Fälle', '### Laborbestätigte Hospitalisationen', False, False)
        for line in data:
          if(line is not None):
              Datum      = (re.findall('\w+\:\s\d{2}\.\d{2}\.\d{4}',line)[0]).replace('Stand: ','')
              Fälle      = int((re.findall('[A-Z][a-z]+\|\s\d{2,}',line)[0]).replace('Vortag| ',''))
              TotalFälle = int(((re.findall('Total seit 24.02.2020+\|\s\d{1,}\s\d{1,}',line)[0]).split('| ')[1]).replace(' ',''))
              break
        
        data = covidnewsreader('https://www.covid19.admin.ch/de/overview?ovTime=total', '### Laborbestätigte Hospitalisationen', '### Laborbestätigte Todesfälle', False, False)
        for line in data:
          if(line is not None):
              Hospitalisationen = int((re.findall('[A-Z][a-z]+\|\s\d{2,}',line)[0]).replace('Vortag| ',''))
              TotalHosp         = int(((re.findall('Total seit 24.02.2020+\|\s\d{1,}\s\d{1,}',line)[0]).split('| ')[1]).replace(' ',''))
              break
        
        data = covidnewsreader('https://www.covid19.admin.ch/de/overview?ovTime=total', '### Laborbestätigte Todesfälle', '### Tests und Anteil positive Tests', False, False)
        for line in data:
            if(line is not None):
              Todesfälle = int((re.findall('[A-Z][a-z]+\|\s\d{1,}',line)[0]).replace('Vortag| ',''))
              TotalDead  = int(((re.findall('Total seit 24.02.2020+\|\s\d{1,}',line)[0]).split('| ')[1]))
              break

        ### Print data frame set as table
        locale.setlocale(locale.LC_ALL, 'de_CH.utf-8')
        dict_data = {
          'Laborbestätigte'      : ['Neue Fälle', 'Hospitalisationen', 'Todesfälle'],
          f'Neu seit {Datum}'    : [locale.format_string('%d', Fälle, 1), locale.format_string('%d', Hospitalisationen, 1), locale.format_string('%d', Todesfälle, 1)],
          'Total seit 24.02.2020': [locale.format_string('%d', TotalFälle, 1), locale.format_string('%d', TotalHosp, 1), locale.format_string('%d', TotalDead, 1)]
        }
        table = pd.DataFrame(data = dict_data)
        print('{0}{1}{2}'.format(colors.fg.green, table, colors.reset))
        print('\n{0}{1}\n{2}ENDE{2}\n{1}{3}'.format(colors.bold + colors.fg.blue, '-' * 68, ' ' * 32, colors.reset))
      elif re.search("wetter", recived):
        srfnewsreader('https://www.srf.ch/meteo/wetterbericht', '#  Wetterbericht','## Footer', False, False)

  except KeyboardInterrupt:
        serversocket.close()
        print(' (Ctrl. + C) received, shutting down the listener')
        serversocket.close()

# Define the main function
def main(argv):
  '''main function'''
  try:
    sender = ''; port = 8089; connections = 5
    opts, args = getopt.getopt(argv, "s:p:c:", ['help:h'])

    for opt, arg in opts:
      if opt in ['-s']:
        sender = arg
      elif opt in ['-p']:
        port = arg
      elif opt in ['-c']:
        connections = arg
      elif opt in ('-h', '--help', 'help'):
        usage()
        break
    
    start(sender, port, connections)

  except getopt.GetoptError:
      usage()

# Call the main function
import os, sys, getopt, socket
import locale, requests, html2text, re
import pandas as pd
from datetime import datetime

if __name__ =='__main__':
    main(sys.argv[1:])