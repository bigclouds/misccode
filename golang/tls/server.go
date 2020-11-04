package main

import (
	"fmt"
	"crypto/tls"
	"crypto/x509"
	"io"
	"io/ioutil"
	"log"
	"net/http"
)

func HelloServer(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, "hello, world!\n")
}

func main() {
        fmt.Println("Starting server.go")
	http.HandleFunc("/hello", HelloServer)

        fmt.Println("Reading ca.crt")
	caCert, err := ioutil.ReadFile("ca.crt")
	if err != nil {
                fmt.Println(err)
		log.Fatal(err)
	}
	caCertPool := x509.NewCertPool()
	caCertPool.AppendCertsFromPEM(caCert)

	// Setup HTTPS client
	tlsConfig := &tls.Config{
		ClientCAs: caCertPool,
		// NoClientCert
		// RequestClientCert
		// RequireAnyClientCert
		// VerifyClientCertIfGiven
		// RequireAndVerifyClientCert
		ClientAuth: tls.RequireAndVerifyClientCert,
	}
	tlsConfig.BuildNameToCertificate()

	server := &http.Server{
		Addr:      ":8080",
		TLSConfig: tlsConfig,
	}

        fmt.Println("Starting listener on port 8080")
//        http.ListenAndServe(":8080", nil)
	server.ListenAndServeTLS("server.crt", "server.key") //private cert
        fmt.Println("Listener started")
}

