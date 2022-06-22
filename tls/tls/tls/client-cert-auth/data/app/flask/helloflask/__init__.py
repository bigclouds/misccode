from flask import Flask
from flask import request


app = Flask(__name__)


@app.route("/")
def hello():
    return "Hello Flask! (CN: %s)" % request.environ['SSL_CLIENT_S_DN_CN']


@app.route("/counter")
def counter():
    import sqlite3
    conn = sqlite3.connect('/var/lib/helloflask/helloflask.db')
    c = conn.cursor()
    cn = (request.environ['SSL_CLIENT_S_DN_CN'],)
    c.execute('UPDATE cncounter SET counter = counter + 1 WHERE cn = ?', cn)
    conn.commit()
    c.execute('SELECT counter FROM cncounter WHERE cn = ?', cn)
    r = c.fetchone()
    counter = r[0]
    conn.close()
    return "counter: %s" % counter


if __name__ == "__main__":
    app.run()
