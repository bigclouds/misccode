package main

import "fmt"

type A struct {
	a int
}

func testA(a A) {
	fmt.Printf("A: %p\n", &a)
}

func test(x map[string]int) {
	fmt.Printf("&x: %p, x: %p, len %d\n", &x, x, len(x))
	x["b"] = 'b'
	fmt.Printf("&x: %p, x: %p, len %d\n", &x, x, len(x))
}

// map paramter has the same view with outer map variable
func main1() {
	m := make(map[string]int, 0)
	m = map[string]int{}
	m["a"] = 'a'
	fmt.Printf("m: %p, %d\n", m, len(m))
	test(m)
	fmt.Printf("m: %p, %d\n", m, len(m))
	fmt.Printf("&m: %p\n", &m)

	m2 := map[string]int{}
	test(m2)
	m2["a"] = 'a'
	fmt.Printf("m2: %p\n", m2)

	a := A{2}
	testA(a)
	fmt.Printf("a: %p\n", &a)
}

func testbyte(x []byte) {
	fmt.Printf("x: %p, %d, %s\n", x, len(x), string(x))
	x = append(x, '1')
	fmt.Printf("x: %p, %d, %s\n", x, len(x), string(x))

}

// []byte paramter does not have the same view with outer variable
func main2() {
	m := make([]byte, 10)
	m = append(m, '0')
	fmt.Printf("m: %p, %d, %s\n", m, len(m), string(m))
	testbyte(m)
	fmt.Printf("m: %p, %d, %s\n", m, len(m), string(m))

}
func testint(x []int) {
	fmt.Printf("x: %p, %d, \n", x, len(x))
	x = append(x, 1)
	fmt.Printf("x: %p, %d, \n", x, len(x))

}

// []int paramter does not have the same view with outer variable
func main3() {
	m := make([]int, 10)
	m = append(m, 0)
	fmt.Printf("m: %p, %d, \n", m, len(m))
	testint(m)
	fmt.Printf("m: %p, %d, \n", m, len(m))

}

func main() {
	main1()
}
