#!/bin/bash

set -eu
set -o pipefail

###

# install wsgi
yum -y install mod_wsgi-3.4-12.el7_0

# copy configuration files and wsgi app from data dir
cp /vagrant/data/httpd/ssl.conf.wsgi /etc/httpd/conf.d/ssl.conf
cp /vagrant/data/app/wsgi/wsgi.py /var/www/cgi-bin/

# restart apache http server
systemctl restart httpd
