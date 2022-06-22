#encoding:utf-8
# server.py
# 从wsgiref模块导入:
from wsgiref.simple_server import make_server
from webob import Request

def application(environ, start_response):
    start_response('200 OK', [('Content-Type', 'text/html')])
    return '<h1>Hello, web!</h1>'

class app:
    def __init__(self):
        pass

    def __call__(self,environ, start_response):
        req = Request(environ)        
        param1 = int(req.GET.get("param1", 0))
        param2 = int(req.GET.get("param2", 0))                 
        start_response("200 OK",[("Content-type", "text/plain")])
        return ["RESULT={0}".format(param1+param2).encode('utf-8')]

# 创建一个服务器，IP地址为空，端口是8000，处理函数是application:
#httpd = make_server('', 8000, application)
httpd = make_server('', 8000, app())
print "Serving HTTP on port 8000..."
# 开始监听HTTP请求:
httpd.serve_forever()
