# Actions to run
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

def srfnewsreader(url, links=True, images=True, emphasis=True):
    '''Reads the given url and print a markdown'''
    import requests, html2text, re
    from datetime import datetime
    now = datetime.now()

    response = requests.get(url)
    if(response.status_code == 200):
        print(colors.bold + colors.fg.blue +'{2}{0}'.format('\n', '>' * 80, f'NEWS FROM: {url}', '<' * 80, now.strftime("%Y-%m-%d %H:%M:%S")) + colors.reset)
        html = response.content.decode('utf-8')
        md = html2text.HTML2Text()
        md.ignore_links    = not links
        md.ignore_images   = not images
        md.ignore_emphasis = not emphasis
        md.body_width      = 100
        data  = md.handle(html)

        #read from '###  Neueste Beiträge'
        start = data.find('###  Neueste Beiträge')
        end   = data.find('## Footer')
        stream = [(data[start:end])]
        for i in stream:
            if(i is not None):
                line = i.replace('Mit Video\n\n','').replace('Mit Audio\n\n','')
                if str.startswith(line, '*'):
                    print('{0}{1}{2}'.format(colors.fg.lightred, line, colors.reset))
                else:
                    print('{0}{1}{2}'.format(colors.fg.green, line, colors.reset))

        print(colors.bold + colors.fg.blue +'END'+ colors.reset)

def covidnewsreader(url, links=True, images=True, emphasis=True):
    '''Reads the given url and print a markdown'''
    import requests, html2text, re
    from datetime import datetime
    now = datetime.now()

    response = requests.get(url)
    if(response.status_code == 200):
        print(colors.bold + colors.fg.blue +'{2}{0}'.format('\n', '>' * 80, f'NEWS FROM: {url}', '<' * 80, now.strftime("%Y-%m-%d %H:%M:%S")) + colors.reset)
        html = response.content.decode('utf-8')
        md = html2text.HTML2Text()
        md.ignore_links    = not links
        md.ignore_images   = not images
        md.ignore_emphasis = not emphasis
        md.body_width      = 100
        data  = md.handle(html)

        #read from '### Laborbestätigte'
        start = data.find('### Laborbestätigte Fälle')
        end   = data.find('### Tests und Anteil positive Tests')
        stream = [(data[start:end])]
        for i in stream:
            if(i is not None):
                line = i.replace('Detailinformationen\n\n','')
                line = line.replace('7-⁠Tage-⁠Schnitt\n\n','')
                line = line.replace('Beschreibungen einblenden\n\n','')
                line = line.replace('Neu gemeldet\n\n','')
                line = line.replace('\nFälle\n','')
                print('{0}{1}{2}'.format(colors.fg.green, line, colors.reset))

        print(colors.bold + colors.fg.blue +'END'+ colors.reset)

# Listener: Serverside
import socket, re

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
            if re.search("srf", recived):
              srfnewsreader('https://www.srf.ch/news/neuste-beitraege', False, False)
            elif re.search("covid", recived):
              covidnewsreader('https://www.covid19.admin.ch/de/overview', False, False)

except KeyboardInterrupt:
    serversocket.close()
    print(' received, shutting down the listener')
    serversocket.close()