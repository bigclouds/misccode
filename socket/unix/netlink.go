package main

import (
        "fmt"
        "net"
//        "os"
//        "os/exec"
        "runtime"

	"github.com/containernetworking/plugins/pkg/ns"
        "github.com/vishvananda/netlink"
        "github.com/vishvananda/netns"
)


type DNSInfo struct {
        Servers  []string
        Domain   string
        Searches []string
        Options  []string
}

type NetlinkIface struct {
        netlink.LinkAttrs
        Type string
}

type NetworkInfo struct {
        Iface     NetlinkIface
        DNS       DNSInfo
        Link      netlink.Link
        Addrs     []netlink.Addr
        Routes    []netlink.Route
        Neighbors []netlink.Neigh
}


var ns1 string = "/var/run/netns/cnitest-319c6299-66b7-18ef-1871-8e2184c3723f"

func main() {
	main1()
}

func main1() error {
	netnsHandle, err := netns.GetFromPath(ns1)
        if err != nil {
                return err
        }
        defer netnsHandle.Close()

        netlinkHandle, err := netlink.NewHandleAt(netnsHandle)
        if err != nil {
                return err
        }
        defer netlinkHandle.Close()

        linkList, err := netlinkHandle.LinkList()
        if err != nil {
                return err
        }
	fmt.Println(len(linkList))

        for _, link := range linkList {
                netInfo, err := networkInfoFromLink(netlinkHandle, link)
                if err != nil {
			fmt.Println("error1:", netInfo)
                        return err
                }

		fmt.Println(netInfo)
                if len(netInfo.Addrs) == 0 {
                        continue
                }

                // Skip any loopback interfaces:
                if (netInfo.Iface.Flags & net.FlagLoopback) != 0 {
                        continue
                }
		/*
		if err := doNetNS(ns, func(_ ns.NetNS) error {
                        _, err = n.addSingleEndpoint(ctx, s, netInfo, hotplug)
                        return err
                }); err != nil {
                        return err
                }
		*/
        }
	return nil
}




func networkInfoFromLink(handle *netlink.Handle, link netlink.Link) (NetworkInfo, error) {
        addrs, err := handle.AddrList(link, netlink.FAMILY_ALL)
        if err != nil {
                return NetworkInfo{}, err
        }

        routes, err := handle.RouteList(link, netlink.FAMILY_ALL)
        if err != nil {
                return NetworkInfo{}, err
        }

        neighbors, err := handle.NeighList(link.Attrs().Index, netlink.FAMILY_ALL)
        if err != nil {
                return NetworkInfo{}, err
        }

        return NetworkInfo{
                Iface: NetlinkIface{
                        LinkAttrs: *(link.Attrs()),
                        Type:      link.Type(),
                },
                Addrs:     addrs,
                Routes:    routes,
                Neighbors: neighbors,
                Link:      link,
        }, nil
}

func doNetNS(netNSPath string, cb func(ns.NetNS) error) error {
        // if netNSPath is empty, the callback function will be run in the current network namespace.
        // So skip the whole function, just call cb(). cb() needs a NetNS as arg but ignored, give it a fake one.
        if netNSPath == "" {
                var netNs ns.NetNS
                return cb(netNs)
        }

        runtime.LockOSThread()
        defer runtime.UnlockOSThread()

        currentNS, err := ns.GetCurrentNS()
        if err != nil {
                return err
        }
        defer currentNS.Close()

        targetNS, err := ns.GetNS(netNSPath)
        if err != nil {
                return err
        }

        if err := targetNS.Set(); err != nil {
                return err
        }
        defer currentNS.Set()

        return cb(targetNS)
}
