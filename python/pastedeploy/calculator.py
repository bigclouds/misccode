from webob import Request

class Calculator:
    def __init__(self):
        pass

    def __call__(self, environ, start_response):
        req = Request(environ)        
        param1 = int(req.GET.get("param1", 0))
        param2 = int(req.GET.get("param2", 0))                 
        start_response("200 OK",[("Content-type", "text/plain")])
        return ["RESULT={0}".format(param1+param2).encode('utf-8')]

    @classmethod
    def factory(cls, global_conf, **local_conf):        
        return Calculator()
