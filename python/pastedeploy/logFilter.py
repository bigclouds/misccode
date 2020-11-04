class LogFilter:

    def __init__(self, app):

        self.app = app

    def __call__(self, environ, start_response):
        print("Log Filter")
        return self.app(environ,start_response)

    @classmethod
    def factory(cls, global_conf, **kwargs):
        return LogFilter
