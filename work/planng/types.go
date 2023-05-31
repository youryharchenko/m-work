package main

import (
	"fmt"

	parsec "github.com/prataprc/goparsec"
)

// Expr -
type Expr interface {
	fmt.Stringer
	SetParent(Expr)
	GetParent() Expr
	GetCtx() *Context
	Eval() Expr
	Equals(Expr) bool
	//Clone() Expr
	//ChangeContext(string)
	//Debug() string
}

type BaseExpr struct {
	Expr

	Parent Expr
	Node   parsec.ParsecNode
	Ctx    *Context
	Name   string
}

func (expr *BaseExpr) SetParent(parent Expr) {
	fmt.Println("SetParent", parent)
	expr.Parent = parent
}

func (expr *BaseExpr) GetParent() (parent Expr) {
	parent = expr.Parent
	return
}

func (expr *BaseExpr) GetCtx() (ctx *Context) {
	ctx = expr.Ctx
	return
}

// ID -
type ID struct {
	BaseExpr

	//json.Marshaler
	//json.Unmarshaler
	//Node    parsec.ParsecNode
	//Name    string

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
	BaseExpr

	//json.Marshaler
	//json.Unmarshaler
	//Node    parsec.ParsecNode
	//Name    string

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
	BaseExpr

	//json.Marshaler
	//json.Unmarshaler
	//Node    parsec.ParsecNode
	//Name    string

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
	BaseExpr

	//json.Marshaler
	//json.Unmarshaler
	//Node    parsec.ParsecNode
	//Name    string

	Value   string
	CtxName string
}

func (text *Text) String() (res string) {
	return fmt.Sprintf(`"%s"`, text.Value)
}

// Refer -
type Refer struct {
	BaseExpr

	//json.Marshaler
	//Node    parsec.ParsecNode
	//Name    string

	Value   string
	CtxName string
}

func (ref *Refer) String() (res string) {
	return fmt.Sprintf(".%s", ref.Value)
}

// Eval -
func (ref *Refer) Eval() (res Expr) {
	res = FindRef(ref)
	//c, _ := engine.current.Load(ref.CtxName)
	//return c.(*Context).get(ref.Value)
	//return engine.current[ref.CtxName].get(ref.Value)
	return
}

// SegRefer -
type SegRefer struct {
	BaseExpr

	//json.Marshaler
	//Node    parsec.ParsecNode
	//Name    string

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
	BaseExpr

	//json.Marshaler
	//Node    parsec.ParsecNode
	//Name    string

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
	BaseExpr

	//json.Marshaler
	//json.Unmarshaler
	//Node    parsec.ParsecNode
	//Name    string

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
		e := item.Eval()
		//fmt.Println("expr:", item, "=>", e, "parent:", item.GetParent())
		a = append(a, e)
	}
	return &Alist{BaseExpr: alist.BaseExpr, Value: a, CtxName: alist.CtxName}
}

// Mlist -
type Mlist struct {
	BaseExpr

	//json.Marshaler
	//Node    parsec.ParsecNode
	//Name    string

	Value   []Expr
	CtxName string
}

// Llist -
type Llist struct {
	BaseExpr

	//json.Marshaler
	//Node    parsec.ParsecNode
	//Name    string

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
	if len(llist.Value) == 0 {
		return NullID
	}
	//res = applyFunc(llist.Value[0].Eval(), llist.Value[1:])
	res = applyFunc(llist)
	return
}

// Func -
type Func func([]Expr) Expr
