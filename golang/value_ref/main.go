package main

import "fmt"

func changea(a []int) {
	a[0] = 1
	fmt.Printf("&a %p\n", &a[0])
	fmt.Printf("&a %p\n", a)
	fmt.Printf("&a %p\n", &a)
}

func changeb(b [3]int) {
	b[0] = 1
	fmt.Printf("&b %p\n", &b[0])
	fmt.Printf("&b %p\n", b)
	fmt.Printf("&b %p\n", &b)
}

func main() {
	a := []int{9, 8, 7}
	b := [3]int{9, 8, 7}
	changea(a)
	fmt.Printf("vim-go %v, %p\n", a, &a)
	changeb(b)
	fmt.Printf("vim-go %v, %p\n", b, &b)
}
