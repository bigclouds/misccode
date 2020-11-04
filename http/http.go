package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"sync/atomic"
	"runtime"
	"strconv"
	"strings"
	"time"
)

var c int32 = 0
var v *bool
var vv *bool
var s *int
var f string

func ReadLine(filePth string, w http.ResponseWriter) error {
	f, err := os.Open(filePth)
	if err != nil {
		return err
	}
	defer f.Close()

	bfRd := bufio.NewReader(f)
	for {
		line, err := bfRd.ReadBytes('\n')
		w.Write(line) //放在错误处理前面，即使发生错误，也会处理已经读取到的数据。
		//fmt.Println("" + string(line))
		if err != nil { //遇到任何错误立即返回，并忽略 EOF 错误信息
			if err == io.EOF {
				return nil
			}
			return err
		}
	}
	return nil
}

func IndexHandler1(w http.ResponseWriter, r *http.Request) {
	if *s>0 {
		time.Sleep(time.Duration(*s) * time.Second)
	}
	if *v {
		//c = c + 1
		atomic.AddInt32(&c, 1);
		w.Header().Set("Content-type", "application/text")
		w.WriteHeader(200)
		if *vv {
			fmt.Fprintln(w, "Protocol:"+r.Proto+",Host:"+r.Host+",remote:"+r.RemoteAddr+", "+strconv.Itoa(int(atomic.LoadInt32(&c))))
		}
		fmt.Println("Protocol:" + r.Proto + ",Host:" + r.Host + ",remote:" + r.RemoteAddr + "," + "close keepalive:" + strconv.FormatBool(r.Close) + ", " + strconv.Itoa(int(atomic.LoadInt32(&c))))
		//fmt.Println(r.Header)
		//if c % 1000 == 0{
		//	fmt.Println(c)
		//}
	}
	//fmt.Fprintln(w, r.RemoteAddr + ", " + r.Host)
}

func IndexHandler2(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-type", "application/text")
	w.WriteHeader(200)
	if f != "" {
		ReadLine(f, w)
	}
}

func IndexHandler(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.URL.Path == "/":
		IndexHandler1(w, r)
	case strings.HasPrefix(r.URL.Path, "/file/"):
		f = strings.TrimLeft(r.URL.Path, "/file/")
		IndexHandler2(w, r)
	default:
		http.Error(w, "Unsupported path", http.StatusNotFound)
	}
}

func init() {
	runtime.GOMAXPROCS(8)
}

func main() {
	runtime.GOMAXPROCS(8)
	var port string
	v = flag.Bool("v", false, "verbose")
	vv = flag.Bool("vv", false, "verbose")
	s = flag.Int("s", 0, "sleep")
	flag.StringVar(&port, "p", ":8080", "port")
	flag.Parse()
	http.HandleFunc("/", IndexHandler)
	go http.ListenAndServe(port, nil)
	go http.ListenAndServe(port, nil)
	go http.ListenAndServe(port, nil)
	http.ListenAndServe(port, nil)
}
