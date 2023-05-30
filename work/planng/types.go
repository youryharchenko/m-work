package main

import (
	"fmt"

	parsec "github.com/prataprc/goparsec"
)

// Expr -
type Expr interface {
	fmt.Stringer
	Eval() Expr
	Equals(Expr) bool
	//Clone() Expr
	//ChangeContext(string)
	//Debug() string
}

// ID -
type ID struct {
	Expr
	//json.Marshaler
	//json.Unmarshaler
	Node    parsec.ParsecNode
	Name    string
	Value   string
	CtxName string
}

func (id *ID) String() (res string) {
	return fmt.Sprintf("%s", id.Value)
}

// Eval -
func (id *ID) Eval() (res Expr) {
	return id
}

// Int -
type Int struct {
	Expr
	//json.Marshaler
	//json.Unmarshaler
	Node    parsec.ParsecNode
	Name    string
	Value   int
	CtxName string
}

func (num *Int) String() (res string) {
	return fmt.Sprintf("%d", num.Value)
}

// Eval -
func (num *Int) Eval() (res Expr) {
	return num
}

// Float -
type Float struct {
	Expr
	//json.Marshaler
	//json.Unmarshaler
	Node    parsec.ParsecNode
	Name    string
	Value   float64
	CtxName string
}

func (num *Float) String() (res string) {
	return fmt.Sprintf("%.4f", num.Value)
}

// Eval -
func (num *Float) Eval() (res Expr) {
	return num
}

// Text -
type Text struct {
	Expr
	//json.Marshaler
	//json.Unmarshaler
	Node    parsec.ParsecNode
	Name    string
	Value   string
	CtxName string
}

func (text *Text) String() (res string) {
	return fmt.Sprintf(`"%s"`, text.Value)
}

// Refer -
type Refer struct {
	Expr
	//json.Marshaler
	Node    parsec.ParsecNode
	Name    string
	Value   string
	CtxName string
}

func (ref *Refer) String() (res string) {
	return fmt.Sprintf(".%s", ref.Value)
}

// Eval -
func (ref *Refer) Eval() (res Expr) {
	//c, _ := engine.current.Load(ref.CtxName)
	//return c.(*Context).get(ref.Value)
	//return engine.current[ref.CtxName].get(ref.Value)
	return
}

// SegRefer -
type SegRefer struct {
	Expr
	//json.Marshaler
	Node    parsec.ParsecNode
	Name    string
	Value   Expr
	CtxName string
}

func (ref *SegRefer) String() (res string) {
	return fmt.Sprintf("!%s", ref.Value)
}

// Eval -
func (ref *SegRefer) Eval() (res Expr) {
	//c, _ := engine.current.Load(ref.CtxName)
	//return c.(*Context).get(ref.Value)
	//return engine.current[ref.CtxName].get(ref.Value)
	return
}

// Refer -
type AtRefer struct {
	Expr
	//json.Marshaler
	Node    parsec.ParsecNode
	Name    string
	Value   string
	CtxName string
}

func (ref *AtRefer) String() (res string) {
	return fmt.Sprintf(".%s", ref.Value)
}

// Eval -
func (ref *AtRefer) Eval() (res Expr) {
	//c, _ := engine.current.Load(ref.CtxName)
	//return c.(*Context).get(ref.Value)
	//return engine.current[ref.CtxName].get(ref.Value)
	return
}

// Alist -
type Alist struct {
	Expr
	//json.Marshaler
	//json.Unmarshaler
	Node    parsec.ParsecNode
	Name    string
	Value   []Expr
	CtxName string
}

func (alist *Alist) String() (res string) {
	res = "["
	sep := ""
	for _, item := range alist.Value {
		res += fmt.Sprintf("%s%v", sep, item)
		sep = " "
	}
	res += "]"
	return
}

// Eval -
func (alist *Alist) Eval() (res Expr) {
	a := []Expr{}
	for _, item := range alist.Value {
		a = append(a, item.Eval())
	}
	return &Alist{Node: alist.Node, Name: alist.Name, Value: a, CtxName: alist.CtxName}
}

// Mlist -
type Mlist struct {
	Expr
	//json.Marshaler
	Node    parsec.ParsecNode
	Name    string
	Value   []Expr
	CtxName string
}

// Llist -
type Llist struct {
	Expr
	//json.Marshaler
	Node    parsec.ParsecNode
	Name    string
	Value   []Expr
	CtxName string
}

func (llist *Llist) String() (res string) {
	res = "("
	sep := ""
	for _, item := range llist.Value {
		res += fmt.Sprintf("%s%v", sep, item)
		sep = " "
	}
	res += ")"
	return
}

// Eval -
func (llist *Llist) Eval() (res Expr) {
	//if len(llist.Value) == 0 {
	//	return nullID
	//}
	//return applyFunc(llist.CtxName, llist.Value[0].Eval(), llist.Value[1:])
	return
}
