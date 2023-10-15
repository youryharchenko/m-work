package main

import (
	"bufio"
	"os"
	"strings"
)

type Lexicon struct {
}

type Item struct {
	Parent string   `json:"parent"`
	Tags   []string `json:"tags"`
}

func LoadDict(path string) (mwords map[string][]Item, err error) {

	file, err := os.Open(path)
	if err != nil {
		return
	}
	defer file.Close()

	mwords = map[string][]Item{}
	scanner := bufio.NewScanner(file)

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
	}

	return
}

func CleanLine(w string) string {
	w = strings.ReplaceAll(w, "1", " ")
	w = strings.ReplaceAll(w, "2", " ")
	w = strings.ReplaceAll(w, "3", " ")
	w = strings.ReplaceAll(w, "4", " ")
	w = strings.ReplaceAll(w, "5", " ")
	w = strings.ReplaceAll(w, "6", " ")
	w = strings.ReplaceAll(w, "7", " ")
	w = strings.ReplaceAll(w, "8", " ")
	w = strings.ReplaceAll(w, "9", " ")
	w = strings.ReplaceAll(w, "0", " ")

	w = strings.ReplaceAll(w, ".", " ")
	w = strings.ReplaceAll(w, ",", " ")
	w = strings.ReplaceAll(w, "!", " ")
	w = strings.ReplaceAll(w, "?", " ")
	w = strings.ReplaceAll(w, ";", " ")
	w = strings.ReplaceAll(w, ":", " ")
	w = strings.ReplaceAll(w, "/", " ")
	w = strings.ReplaceAll(w, "'", " ")
	w = strings.ReplaceAll(w, "_", " ")
	w = strings.ReplaceAll(w, "-", " ")
	w = strings.ReplaceAll(w, "+", " ")
	w = strings.ReplaceAll(w, "*", " ")
	w = strings.ReplaceAll(w, "=", " ")
	w = strings.ReplaceAll(w, "\\", " ")
	w = strings.ReplaceAll(w, "«", " ")
	w = strings.ReplaceAll(w, "»", " ")
	w = strings.ReplaceAll(w, "(", " ")
	w = strings.ReplaceAll(w, ")", " ")
	w = strings.ReplaceAll(w, "[", " ")
	w = strings.ReplaceAll(w, "]", " ")
	w = strings.ReplaceAll(w, "{", " ")
	w = strings.ReplaceAll(w, "}", " ")
	w = strings.ReplaceAll(w, "–", " ")
	w = strings.ReplaceAll(w, "\"", " ")
	w = strings.ReplaceAll(w, "“", " ")
	w = strings.ReplaceAll(w, "№", " ")
	w = strings.ReplaceAll(w, "‒", " ")
	w = strings.ReplaceAll(w, "", " ")
	w = strings.ReplaceAll(w, " ", " ")

	w = strings.ReplaceAll(w, "’", "'")

	return strings.TrimSpace(w)
}
