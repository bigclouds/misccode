import os
import sys
from wsgiref.simple_server import make_server
from paste.deploy import loadapp

#sys.path.append(os.getcwd()) 
#print(sys.path)

if __name__ == '__main__':
    configfile = 'config.ini'
    appname = 'calculator'
    wsgi_app = loadapp('config:%s' % os.path.abspath(configfile), appname)
 
    server = make_server('', 8000, wsgi_app)
    server.serve_forever()
