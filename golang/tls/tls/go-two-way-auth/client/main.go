package main

import "crypto/tls"
import "github.com/cclin81922/tls/go-two-way-auth"
import "fmt"
import "io"
import "os"

//import "net"

func main() {

	config := common.MustGetTlsConfiguration()

	conn, err := tls.Dial("tcp", "localhost.localdomain:51000", config)
	if err != nil {
		panic(err)
	}
	err = conn.Handshake()
	if err != nil {
		fmt.Printf("Failed handshake:%v\n", err)
		return
	}

	_, err = io.Copy(os.Stdout, conn)
	if err != nil {
		fmt.Printf("Failed receiving data:%v\n", err)
	}

	conn.Close()
}
