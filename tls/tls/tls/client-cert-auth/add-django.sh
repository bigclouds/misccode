#!/bin/bash

set -eu
set -o pipefail

###

# install django
pip install django==1.11.10

# copy configuration files and wsgi app from data dir
cp /vagrant/data/httpd/ssl.conf.django /etc/httpd/conf.d/ssl.conf
cp /vagrant/data/app/django/hellodjango/wsgi.py /var/www/cgi-bin/django.py
cp -r /vagrant/data/app/django/hellodjango /usr/lib/python2.7/site-packages/

# restart apache http server
systemctl restart httpd
