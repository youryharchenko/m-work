package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/jdkato/prose/v2"
)

type Document struct {
	Sents []Sentence `json:"sents"`
	Inds  []uint64   `json:"inds"`
}

type Sentence struct {
	Sent string   `json:"sent"`
	Toks []string `json:"toks"`
	Inds []uint64 `json:"inds"`
}

func main() {

	fname := "./data/test02"

	buf, err := os.ReadFile(fname + ".txt")
	if err != nil {
		log.Fatalln(err)
	}

	doc, err := prose.NewDocument(string(buf))
	if err != nil {
		log.Fatalln(err)
	}

	//doc, _ := prose.NewDocument(strings.Join([]string{
	//	"I can see Mt. Fuji from here.",
	//	"St. Michael's Church is on 5th st. near the light."}, " "))

	sents := doc.Sentences()

	normSents := make([]Sentence, len(sents))
	normInds := make([]uint64, len(sents))
	cntSents := make(map[string]uint64)

	for i, sent := range sents {
		fmt.Println(i, sent.Text)

		sdoc, err := prose.NewDocument(sent.Text)
		if err != nil {
			log.Println("Error:", err, "text", sent.Text)
			continue
		}

		toks := make([]string, len(sdoc.Tokens()))
		inds := make([]uint64, len(sdoc.Tokens()))
		cnt := make(map[string]uint64)

		for j, tok := range sdoc.Tokens() {
			lowtok := strings.ToLower(tok.Text)
			ind, ok := cnt[lowtok]
			if !ok {
				cnt[lowtok] = 1
				ind = 0
			} else {
				cnt[lowtok] = ind + 1
			}
			inds[j] = ind
			toks[j] = lowtok
		}
		normSents[i].Inds = inds
		normSents[i].Toks = toks
		normSent := strings.Join(toks, " ")
		normSents[i].Sent = normSent

		indSent, ok := cntSents[normSent]
		if !ok {
			cntSents[normSent] = 1
			indSent = 0
		} else {
			cntSents[normSent] = indSent + 1
		}

		normInds[i] = indSent

		fmt.Println(normSents[i].Sent)
		fmt.Println(normSents[i].Inds)

	}

	document := Document{
		Sents: normSents,
		Inds:  normInds,
	}

	jsonDoc, err := json.MarshalIndent(document, "", "  ")
	if err != nil {
		log.Fatalln(err)
	}

	err = os.WriteFile(fname+".json", jsonDoc, 0755)
	if err != nil {
		log.Fatalln(err)
	}

	fmt.Println("Tokens", len(doc.Tokens()))
	//toks := doc.Tokens()
	//for _, tok := range toks {
	//	fmt.Println(tok.Text, tok.Label, tok.Tag)
	//}

	fmt.Println("Entities", len(doc.Entities()))
	//for _, ent := range doc.Entities() {
	//	fmt.Println(ent.Text, ent.Label)
	//}

}
