package main
import (
	"log"
	"fmt"
	"net"
	"github.com/moby/ipvs"
	"golang.org/x/sys/unix"
)

var ip1 net.IP =  net.ParseIP("172.17.1.10")
var ip2 net.IP =  net.ParseIP("172.17.1.11")

var s ipvs.Service = ipvs.Service {
	Address: ip1,
	Protocol: uint16(unix.IPPROTO_TCP),
	Port: 9898,
	SchedName: "rr",
	AddressFamily: unix.AF_INET,
	Netmask : 0xffffffff,
}
var d ipvs.Destination = ipvs.Destination{
	Address: ip2,
	Port: 9876,
}

func main() {
	handle, err := ipvs.New("")
	if err != nil {
		log.Fatalf("ipvs.New: %s", err)
	}
	svcs, err := handle.GetServices()
	if err != nil {
		log.Fatalf("handle.GetServices: %s", err)
	}
	fmt.Println(svcs)

	err = handle.NewService(&s)
	if err != nil {
		log.Fatalf("handle.NewServices: %s", err)
	}
	err = handle.NewDestination(&s, &d)
	if err != nil {
		log.Fatalf("handle.NewDestination: %s", err)
	}
	svcs, err = handle.GetServices()
	if err != nil {
		log.Fatalf("handle.GetServices: %s", err)
	}
	fmt.Println(svcs)
}
