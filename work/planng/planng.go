package main

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"os"
)

func main() {
	flag.Parse()

	if len(flag.Args()) < 1 {
		log.Println("try with parameters")
		os.Exit(0)
	}

	file := flag.Args()[0]
	src, err := ioutil.ReadFile(file)
	if err != nil {
		log.Fatalln(err)
	}

	eng := New(true)
	nodes := eng.Parse(src)

	json, err := json.MarshalIndent(nodes, "", "  ")
	if err == nil {
		ioutil.WriteFile(file+".json", json, 0755)
	}

	//fmt.Println(nodes)
	eng.EvalNodes(nodes)

}
