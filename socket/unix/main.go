// A quick and dirty demo of talking HTTP over Unix domain sockets

package main

import (
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"strings"
	"time"
)

type unixDialer struct {
	net.Dialer
}

// overriding net.Dialer.Dial to force unix socket connection
func (d *unixDialer) Dial(network, address string) (net.Conn, error) {
	parts := strings.Split(address, ":")
	return d.Dialer.Dial("unix", parts[0])
}

// copied from http.DefaultTransport with minimal changes
var transport http.RoundTripper = &http.Transport{
	Proxy: http.ProxyFromEnvironment,
	Dial: (&unixDialer{net.Dialer{
		Timeout:   30 * time.Second,
		KeepAlive: 30 * time.Second,
	},
	}).Dial,
	TLSHandshakeTimeout: 10 * time.Second,
}

type helloHandler struct{}

func (h *helloHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Hello, world!"))
}

func main() {
	os.Remove("http.sock")
	listener, err := net.Listen("unix", "http.sock")
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	http.Serve(listener, &helloHandler{}) // http.Serve takes any net.Listener implementation
	time.Sleep(10 * time.Second)
	c := http.Client{}
	c.Transport = transport // use the unix dialer
	resp, err := c.Get("http://http.sock/demo")
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	io.Copy(os.Stdout, resp.Body)
}
