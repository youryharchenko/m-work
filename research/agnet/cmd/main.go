package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type Signal struct {
	N     uint
	Value float64
}

type Agent struct {
	Weights []float64
	Input   chan Signal
	Output  chan Signal
}

type NN struct {
}

func (nn *NN) Process(signals []Signal) (err error) {

	return
}

func getRoot(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("got / request\n")
	io.WriteString(w, "This is my website!\n")
}

func postJSON(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "must be POST method", http.StatusBadRequest)
		return
	}

	req := map[string]any{}

	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(req)
}

func main() {

	mux := http.NewServeMux()

	mux.HandleFunc("/", getRoot)
	mux.HandleFunc("/json", postJSON)

	http.ListenAndServe(":5678", mux)

}
