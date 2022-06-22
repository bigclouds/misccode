FROM httpd:2.4

COPY ./data/docker/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./data/docker/httpd-ssl.conf /usr/local/apache2/conf/extra/httpd-ssl.conf
COPY ./data/docker/ca.cert.pem /usr/local/apache2/conf/ca.cert.pem
COPY ./data/docker/server.cert.pem /usr/local/apache2/conf/server.cert.pem
COPY ./data/docker/server.key.pem /usr/local/apache2/conf/server.key.pem
