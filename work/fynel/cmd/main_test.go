package main

import (
	"log"
	"testing"
)

func TestOpenEnv(t *testing.T) {
	env, err := OpenEnv("")
	if err != nil {
		t.Error(err)
		return
	}
	log.Println(env)
	env.Close()
	t.Error("ok")
}
