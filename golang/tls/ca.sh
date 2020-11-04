openssl genrsa -out ca.key 2048
openssl req -new -sha256 -out ca.csr -key ca.key -config ca.conf
openssl x509 -req -days 3650 -in ca.csr -signkey ca.key -out ca.crt
