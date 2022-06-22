#!/bin/bash

set -eu
set -o pipefail

###

# install pecan
pip install pecan==1.3.2

# copy configuration files and wsgi app from data dir
cp /vagrant/data/httpd/ssl.conf.pecan /etc/httpd/conf.d/ssl.conf
cp /vagrant/data/app/pecan/pecan.py /var/www/cgi-bin/
cp /vagrant/data/app/pecan/hellopecan/config.py /var/www/cgi-bin/pecan_config.py
cp -r /vagrant/data/app/pecan/hellopecan/hellopecan /usr/lib/python2.7/site-packages/

# restart apache http server
systemctl restart httpd
