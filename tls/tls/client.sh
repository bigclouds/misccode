openssl genrsa -out client.key 2048
openssl req -new -sha256 -out client.csr -key client.key -config client.conf
openssl x509 -req -days 3650 -CA ca.crt -CAkey ca.key -CAcreateserial -in client.csr -out client.crt -extensions req_ext -extfile client.conf
