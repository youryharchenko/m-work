package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/http/cgi"

	//"net/smtp"
	"os"
	//"strings"

	_ "github.com/go-sql-driver/mysql"
	//"github.com/jmoiron/sqlx"

	_ "embed"
)

//go:embed html/index.html
var index string

func main() {

	if err := cgi.Serve(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		file, err := os.OpenFile("../cgi.log", os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0666)
		if err != nil {
			fmt.Fprint(w, makeError(err.Error()))
		}
		log.SetOutput(file)

		respMap := map[string]interface{}{}

		header := w.Header()

		log.Println(r.Method, r.URL.String(), r.URL.Host, r.URL.Path, r.URL.Query(), r.RemoteAddr, r.UserAgent())

		switch r.Method {
		case "GET":
			header.Set("Content-Type", "text/html; charset=utf-8")
			query := r.URL.Query()
			page := query.Get("page")

			switch page {

			case "index":
				fmt.Fprint(w, index)

			default:
				fmt.Fprintf(w, `
				<div>
					<p>method: %s</p>
					<p>url: %s</p>
					<p>host: %s</p>
					<p>path: %s</p>
					<p>query: %s</p>
					<p>remoteAddr: %s</p>
					<p>referer: %s</p>
					<p>userAgent: %s</p>
				</div>
				`, r.Method, r.URL.String(), r.URL.Host, r.URL.Path, r.URL.Query(), r.RemoteAddr, r.Referer(), r.UserAgent())
			}

			return

		}

		/*
			r.ParseForm()
			form := r.Form
			for k := range form {
				fmt.Fprintln(w, "Form", k+":", form.Get(k))
			}

			post := r.PostForm
			for k := range post {
				fmt.Fprintln(w, "PostForm", k+":", post.Get(k))
			}

			for _, cookie := range r.Cookies() {
				fmt.Fprintln(w, "Cookie", cookie.Name+":", cookie.Value, cookie.Path, cookie.Domain, cookie.RawExpires)
			}
		*/

		buf, err := json.Marshal(respMap)
		if err != nil {
			fmt.Fprintf(w, makeError(err.Error()))
			return
		}
		fmt.Fprint(w, string(buf))

	})); err != nil {
		fmt.Println(err)
	}
}

func makeError(errStr string) (resp string) {
	buf, err := json.Marshal(map[string]interface{}{
		"error": errStr,
	})
	if err != nil {
		return fmt.Sprintf(`{"error": "makeError error"}`)
	}
	resp = string(buf)
	return
}
