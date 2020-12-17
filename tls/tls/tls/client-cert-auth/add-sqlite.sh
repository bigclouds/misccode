#!/bin/bash

set -eu
set -o pipefail

###

# copy wsgi app and sqlite db from data dir
cp /vagrant/data/app/flask/helloflask/__init__.py /usr/lib/python2.7/site-packages/helloflask/__init__.py
mkdir /var/lib/helloflask
cp /vagrant/data/sqlite/helloflask.db /var/lib/helloflask/
chown -R apache:apache /var/lib/helloflask

# restart apache http server
systemctl restart httpd
