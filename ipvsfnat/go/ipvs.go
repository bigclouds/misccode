package main

import (
	"fmt"
	"log"

	"github.com/moby/ipvs"
)

func main() {
	handle, err := ipvs.New("")
	if err != nil {
		log.Fatalf("ipvs.New: %s", err)
	}
	svcs, err := handle.GetServices()
	if err != nil {
		log.Fatalf("handle.GetServices: %s", err)
	}
	fmt.Println(svcs[0].Address, svcs[0].Port)
}
