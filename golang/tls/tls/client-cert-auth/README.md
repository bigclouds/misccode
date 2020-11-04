# client certificate authentication

a.k.a. two-way ssl authentication

Usage 1

```
# @ vagrant host
vagrant up
vagrant ssh

# @ vagrant guest
sudo su

cd /vagrant
bash provision.sh

cd /vagrant/data/pki
curl --cert ./client.cert.pem --key ./client.key.pem --cacert ca.cert.pem https://localhost.localdomain
curl --cert ./client.cert.pem --key ./client.key.pem --insecure https://localhost.localdomain
curl --cert ./client.cert.pem --key ./client.key.pem --insecure https://localhost.localdomain/wsgi
curl --cert ./client.cert.pem --key ./client.key.pem --insecure https://localhost.localdomain/flask/
curl --cert ./client.cert.pem --key ./client.key.pem --insecure https://localhost.localdomain/flask/counter
curl --cert ./client.cert.pem --key ./client.key.pem --insecure https://localhost.localdomain/django/
curl --cert ./client.cert.pem --key ./client.key.pem --insecure https://localhost.localdomain/pecan/
```

Usage 2

```
bash build-docker-image.sh
bash run-docker-container.sh

cd /vagrant/data/pki
curl --cert ./client.cert.pem --key ./client.key.pem --cacert ca.cert.pem https://localhost.localdomain:8443
curl --cert ./client.cert.pem --key ./client.key.pem --insecure https://localhost.localdomain:8443
```

---

How to manually change domain from localhost.localdomain to 127.0.0.1.xip.io

Step 1. Modify file /etc/httpd/conf.d/ssl.conf

```
ServerName 127.0.0.1.xip.io:443
```

Step 2. Re-issue cert file /etc/pki/self-signed/server.cert.pem

```
CN=127.0.0.1.xip.io
```

Step 3. Restart apache http server

```
systemctl restart httpd
```
