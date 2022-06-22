package main

import (
	tls "crypto/tls"
	"fmt"
	"log"
	"os"
	"bufio"
	"time"

	"golang.org/x/net/websocket"
)

const (
	WS_BASE_URL1 = "wss://localhost:2375"
	WS_BASE_URL = "wss://173.20.3.78:2375"
	ORIGIN1      = "https://localhost"
	ORIGIN      = "https://173.20.3.78"
)

func main() {
	if len(os.Args) != 3 {
		fmt.Println("Usage : <program>  <contain id> <cmd>")
		return
	}

	id := os.Args[1]
	cmd := os.Args[2]

	wsURL := fmt.Sprintf("%s/v1.40/containers/%s/attach/ws?logs=0&stream=1&stdin=1&stdout=1&stderr=1", WS_BASE_URL, id)
	useXNet(wsURL, cmd)
}

func useXNet(url string, cmd string) {
	fmt.Printf("URL : %s\n", url)
	config, err := websocket.NewConfig(url, ORIGIN)
        config.TlsConfig = new(tls.Config)
        config.TlsConfig.InsecureSkipVerify = true
        ws, err := websocket.DialConfig(config)
	if err != nil {
		log.Fatal(err)
	}
	defer ws.Close()

	message := []byte(cmd + "\n")
	fmt.Printf("Send: %s\n", message)

	if _, err := ws.Write(message); err != nil {
		log.Fatal(err)
	}

	ws.SetReadDeadline(time.Now().Add(20 * time.Second))
	reader := bufio.NewReader(os.Stdin)

	go func(){
	  for{
		cmd, _ = reader.ReadString('\n')
		if cmd == "exit\n"{
			os.Exit(0)
		}
		message := []byte(cmd)
		if _, err := ws.Write(message); err != nil {
			log.Fatal(err)
		}
	    }
	}()

	for {
		var msg = make([]byte, 1024)
		var n int
		if n, err = ws.Read(msg); err != nil {
			break // usually is time out
		}
		fmt.Printf("%s", msg[:n])
		msg = nil

	}
}
