#openssl genrsa -out server.key 2048
openssl req -new -sha256 -out server.csr -key server.key -config server.conf
openssl x509 -req -days 3650 -CA ca.crt -CAkey ca.key -CAcreateserial -in server.csr -out server.crt -extensions req_ext -extfile server.conf
