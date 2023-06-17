package main

import (
	"fmt"
	"log"
	"os"

	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
)

type V struct {
	ID    uint64 `db:"id"`
	Type  uint8  `db:"type_"`
	Value string `db:"value"`
}

func (v V) String() string {
	return fmt.Sprintf("v(id: %d, type: %d, value: %s)", v.ID, v.Type, v.Value)
}

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

	res := []V{}
	err = conn.Select(&res, "SELECT * FROM v;")
	if err != nil {
		log.Println("Exec error:", err)
		return
	}
	log.Println(res)
	for _, v := range res {
		log.Println(v)
	}

}
