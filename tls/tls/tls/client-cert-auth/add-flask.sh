#!/bin/bash

set -eu
set -o pipefail

###

# install flask
yum -y install python2-pip-8.1.2-5.el7
pip install flask==0.12.2

# copy configuration files and wsgi app from data dir
cp /vagrant/data/httpd/ssl.conf.flask /etc/httpd/conf.d/ssl.conf
cp /vagrant/data/app/flask/flask.py /var/www/cgi-bin/
cp -r /vagrant/data/app/flask/helloflask /usr/lib/python2.7/site-packages/

# restart apache http server
systemctl restart httpd
