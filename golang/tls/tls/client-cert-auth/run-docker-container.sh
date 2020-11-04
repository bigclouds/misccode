#!/bin/bash

docker run -dit -h localhost.localdomain --name httpd-2.4 -p 8080:80 -p 8443:443 -v "$PWD":/usr/local/apache2/htdocs/ my-httpd-2.4
docker logs httpd-2.4
