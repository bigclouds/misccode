package main

import (
	"crypto/tls"
	"fmt"
	"io/ioutil"
	"net/http"
)

const (
	HOST  = "https://vm155:8080/hello"
	HOST1 = "https://ylg.com:8080/hello" // CN is ylg.com
)

func main() {
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: false},
	}
	client := &http.Client{Transport: tr}
	resp, err := client.Get(HOST1)
	if err != nil {
		fmt.Println("error:", err)
		return
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	fmt.Println(string(body))
}
