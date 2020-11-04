package main

import (
	"fmt"
)

func main() {
	fmt.Println("a")
	var ch chan int

	ch = make(chan int, 1)

	close(ch)
	_, ok := <-ch
	fmt.Println(ok)
	_, ok = <-ch
	fmt.Println(ok)
}
