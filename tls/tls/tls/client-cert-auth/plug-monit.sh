#!/bin/bash

set -eu
set -o pipefail

###

# install monit
yum -y install monit-5.25.1-1.el7

# copy configuration files from data dir
cp /vagrant/data/monit/monitrc /etc/monitrc
cp /vagrant/data/monit/httpd /etc/monit.d/

# start monit daemon
systemctl start monit # use port 2812
