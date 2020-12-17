package main

import (
	"io"
	"log"
	"net/http"
)

func HelloServer(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, "hello, world!\n")
}
func main() {
	http.HandleFunc("/hello", HelloServer)
	err := http.ListenAndServeTLS(":8080", "server.crt", "server.key", nil)
	//err := http.ListenAndServeTLS(":8080", "ca.crt", "ca.key", nil)
	//err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
