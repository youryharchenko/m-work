package lib

import "fmt"

type Document struct {
	Name  string     `json:"name"`
	Sents []Sentence `json:"sents"`
	Inds  []uint64   `json:"inds"`
}

type Sentence struct {
	Sent string   `json:"sent"`
	Toks []string `json:"toks"`
	Inds []uint64 `json:"inds"`
}

type V struct {
	ID    uint64 `db:"id"`
	Type  uint8  `db:"type_"`
	Value string `db:"value"`
}

func (v V) String() string {
	return fmt.Sprintf("v(id: %d, type: %d, value: %s)", v.ID, v.Type, v.Value)
}

type C struct {
	ID uint64 `db:"id"`
	V  uint64 `db:"v"`
}

func (c C) String() string {
	return fmt.Sprintf("c(id: %d, v: %d)", c.ID, c.V)
}

type R struct {
	ID uint64 `db:"id"`
	V  uint64 `db:"v"`
}

func (r R) String() string {
	return fmt.Sprintf("r(id: %d, v: %d)", r.ID, r.V)
}

type RC struct {
	ID uint64 `db:"id"`
	R  uint64 `db:"r"`
	CF uint64 `db:"cf"`
	CT uint64 `db:"ct"`
}

func (rc RC) String() string {
	return fmt.Sprintf("rc(id: %d, r: %d, cf: %d, ct: %d)", rc.ID, rc.R, rc.CF, rc.CT)
}

type A struct {
	ID uint64 `db:"id"`
	V  uint64 `db:"v"`
}

func (a A) String() string {
	return fmt.Sprintf("a(id: %d, v: %d)", a.ID, a.V)
}

type AC struct {
	ID uint64 `db:"id"`
	C  uint64 `db:"c"`
	A  uint64 `db:"a"`
	V  uint64 `db:"v"`
}

func (ac AC) String() string {
	return fmt.Sprintf("ac(id: %d, c: %d, a: %d, v: %d)", ac.ID, ac.C, ac.A, ac.V)
}

type AR struct {
	ID uint64 `db:"id"`
	R  uint64 `db:"r"`
	A  uint64 `db:"a"`
	V  uint64 `db:"v"`
}

func (ar AR) String() string {
	return fmt.Sprintf("ar(id: %d, r: %d, a: %d, v: %d)", ar.ID, ar.R, ar.A, ar.V)
}

type ARC struct {
	ID uint64 `db:"id"`
	RC uint64 `db:"rc"`
	AR uint64 `db:"ar"`
	V  uint64 `db:"v"`
}

func (arc ARC) String() string {
	return fmt.Sprintf("arc(id: %d, rc: %d, ar: %d, v: %d)", arc.ID, arc.RC, arc.AR, arc.V)
}
