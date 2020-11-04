#!/bin/bash
#CA
#openssl genrsa -out key.pem 2048
#openssl req -new -x509 -key key.pem -out cert.pem -days 3650

#server
rm -f server.*
openssl genrsa -out server.key 2048
openssl req -new -key server.key -subj "/CN=woedge.com" -out server.csr
echo subjectAltName = IP:172.20.13.155,DNS:woedge.com,DNS:*.woedge.com > extfile.cnf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile extfile.cnf -out server.crt -days 365

openssl x509 -in server.crt -noout -text

