package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path"
	"strings"
	"testing"
)

var pathFmt = "%s/Projects/java/dict_uk/out/dict_corp_lt.txt"
var pathFmtDocs = "%s/Documents/NUBIP/Magistr/3/work/text/"

func TestMakeLexicon(t *testing.T) {

	pathDict := fmt.Sprintf(pathFmt, os.Getenv("HOME"))

	dict, err := LoadDict(pathDict)
	if err != nil {
		t.Error(err)
		return
	}

	blex, err := os.ReadFile("lexicon.json")
	if err != nil {
		t.Error(err)
		return
	}
	good := map[string]uint{}
	err = json.Unmarshal(blex, &good)
	if err != nil {
		t.Error(err)
		return
	}

	lexDict := map[string][]Item{}
	for k := range good {
		items, ok := dict[k]
		if !ok {
			log.Println("not found", k)
			continue
		}
		for _, item := range items {
			pitem, ok := dict[item.Parent]
			if !ok {
				log.Println("not found parent", item.Parent)
				continue
			}

			_, ok = lexDict[item.Parent]
			if !ok {
				lexDict[item.Parent] = pitem
			}
		}
	}

	jsn, err := json.MarshalIndent(lexDict, "", "  ")
	if err != nil {
		t.Error(err)
		return
	}
	//log.Println(string(jsn))
	log.Println(len(lexDict))

	err = os.WriteFile("lex-dict.json", jsn, 0775)
	if err != nil {
		t.Error(err)
		return
	}

	t.Log("ok")
}

func TestScanDocs(t *testing.T) {

	pathDict := fmt.Sprintf(pathFmt, os.Getenv("HOME"))

	dict, err := LoadDict(pathDict)
	if err != nil {
		t.Error(err)
		return
	}

	pathDocs := fmt.Sprintf(pathFmtDocs, os.Getenv("HOME"))
	entries, err := os.ReadDir(pathDocs)
	if err != nil {
		t.Error(err)
		return
	}

	mwords := map[string]uint{}
	for _, e := range entries {
		if !e.IsDir() && path.Ext(e.Name()) == ".txt" {
			log.Println(e.Name())

			file, err := os.Open(pathDocs + e.Name())
			if err != nil {
				t.Error(err)
				return
			}

			scanner := bufio.NewScanner(file)

			for scanner.Scan() {
				line := scanner.Text()
				line = CleanLine(line)
				rec := strings.Split(line, " ")
				for _, w := range rec {
					w = strings.TrimSpace(w)
					c, ok := mwords[w]
					if ok {
						mwords[w] = c + 1
					} else {
						mwords[w] = 1
					}
				}
			}

		}

	}

	good := map[string]uint{}

	for k, v := range mwords {
		_, ok := dict[k]
		if ok {
			good[k] = v
			continue
		}
		k = strings.ToLower(k)
		_, ok = dict[k]
		if ok {
			c, ok := good[k]
			if ok {
				good[k] = v + c
			} else {
				good[k] = v
			}
			continue
		}
		//if v > 1 {
		//	fmt.Println(k, v)
		//}

	}

	jsn, err := json.MarshalIndent(good, "", "  ")
	if err != nil {
		t.Error(err)
		return
	}
	//log.Println(string(jsn))
	log.Println(len(good))

	err = os.WriteFile("lexicon.json", jsn, 0775)
	if err != nil {
		t.Error(err)
		return
	}

	t.Log("ok")

}

func TestDictWords2(t *testing.T) {

	path := fmt.Sprintf(pathFmt, os.Getenv("HOME"))

	mwords, err := LoadDict(path)
	if err != nil {
		t.Error(err)
		return
	}

	log.Println(len(mwords))
	t.Log("ok")

}

func TestDictWords(t *testing.T) {

	path := fmt.Sprintf(pathFmt, os.Getenv("HOME"))

	file, err := os.Open(path)
	if err != nil {
		t.Error(err)
		return
	}
	defer file.Close()

	mwords := map[string][]Item{}
	scanner := bufio.NewScanner(file)
	i := 0
	j := 0
	log.Println(i)

	for scanner.Scan() {
		line := scanner.Text()
		rec := strings.Split(line, " ")
		tags := strings.Split(rec[2], ":")
		items, ok := mwords[line]
		if ok {
			items = append(items, Item{Parent: rec[1], Tags: tags})
			mwords[rec[0]] = items
		} else {
			mwords[rec[0]] = []Item{{Parent: rec[1], Tags: tags}}
		}

		i += 1
		j += 1
		if j == 10000 {
			fmt.Print(".")
			j = 0
		}
	}
	fmt.Println("")
	log.Println(len(mwords))
	log.Println(i)
	t.Log("ok")

}

func TestDictTags(t *testing.T) {

	path := fmt.Sprintf(pathFmt, os.Getenv("HOME"))

	file, err := os.Open(path)
	if err != nil {
		t.Error(err)
		return
	}
	defer file.Close()

	mtags := map[string]uint{}
	scanner := bufio.NewScanner(file)
	i := 0
	log.Println(i)
	for scanner.Scan() {
		rec := strings.Split(scanner.Text(), " ")
		tags := strings.Split(rec[2], ":")
		for _, t := range tags {
			c, ok := mtags[t]
			if ok {
				mtags[t] = c + 1
			} else {
				mtags[t] = 1
			}
		}
		i += 1
	}
	log.Println(i)
	json, err := json.MarshalIndent(mtags, "", "  ")
	if err != nil {
		t.Error(err)
		return
	}
	log.Println(string(json))
	t.Log("ok")
}

func TestScanDict(t *testing.T) {

	path := fmt.Sprintf(pathFmt, os.Getenv("HOME"))

	file, err := os.Open(path)
	if err != nil {
		t.Error(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	i := 0
	log.Println(i)
	for scanner.Scan() {
		rec := strings.Split(scanner.Text(), " ")
		strings.Split(rec[2], ":")
		i += 1
	}
	log.Println(i)
	t.Error("ok")
}
