package main

import (
	"fmt"
	"unsafe"
)

func main() {
	// can string been changed?
	//z := []byte("zhangjie")
	z := "zhangjie11223344556677889900zhangjie"
	t := *(*([]byte))(unsafe.Pointer(&z))
	c := 10
	fmt.Printf("%p %p %p %p\n", &z, unsafe.Pointer(&z), &t, &c)
	t[1] = 'L'
	fmt.Println(len(t), string(z))
}
