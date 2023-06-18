package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"work/lib"

	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
)

const fname = "./data/test01.json"

func main() {

	kbHost := os.Getenv("KB_HOST")
	kbDB := os.Getenv("KB_DB")
	kbUser := os.Getenv("KB_USER")
	kbPwd := os.Getenv("KB_PWD")

	log.Printf("host: %s, db: %s, user: %s, pwd: %s\n", kbHost, kbDB, kbUser, kbPwd)

	connStr := fmt.Sprintf("%s:%s@tcp(%s)/%s?multiStatements=true",
		kbUser, kbPwd, kbHost, kbDB)

	conn, err := sqlx.Open("mysql", connStr)
	if err != nil {
		log.Println("Open connection error:", connStr, err)
		return
	}
	defer conn.Close()

	jsonDoc, err := os.ReadFile(fname)
	if err != nil {
		log.Fatalln(err)
	}

	document := new(lib.Document)

	err = json.Unmarshal(jsonDoc, document)
	if err != nil {
		log.Fatalln(err)
	}

	err = lib.UploadDocument(conn, document)
	if err != nil {
		log.Println("uploadDocument error:", err)
	}

	/*
		res := []lib.V{}
		err = conn.Select(&res, "SELECT * FROM v;")
		if err != nil {
			log.Println("Exec error:", err)
			return
		}
		log.Println(res)
		for _, v := range res {
			log.Println(v)
		}
	*/

}
