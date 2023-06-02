package main

import (
	"fmt"
	"sort"

	parsec "github.com/prataprc/goparsec"
)

// Expr -
type Expr interface {
	fmt.Stringer

	SetParent(Expr)
	GetParent() Expr

	SetCtx(*Context)
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

func (expr *BaseExpr) SetCtx(ctx *Context) {
	expr.Ctx = ctx
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

// Equals -
func (id *ID) Equals(e Expr) (res bool) {
	v, ok := e.(*ID)
	res = ok && id.Value == v.Value
	return
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

// Equals -
func (num *Int) Equals(e Expr) (res bool) {
	v, ok := e.(*Int)
	if !ok {
		v, ok := e.(*Float)
		return ok && num.Value == int(v.Value)
	}
	res = ok && num.Value == v.Value
	return
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

// Equals -
func (num *Float) Equals(e Expr) (res bool) {
	v, ok := e.(*Float)
	if !ok {
		v, ok := e.(*Int)
		return ok && num.Value == float64(v.Value)
	}
	res = ok && num.Value == v.Value
	return
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

// Eval -
func (text *Text) Eval() (res Expr) {
	return text
}

// Equals -
func (text *Text) Equals(e Expr) (res bool) {
	v, ok := e.(*Text)
	res = ok && text.Value == v.Value
	return
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

// Equals -
func (ref *Refer) Equals(e Expr) (res bool) {
	v, ok := e.(*Refer)
	res = ok && ref.Value == v.Value
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

// Equals -
func (ref *SegRefer) Equals(e Expr) (res bool) {
	v, ok := e.(*SegRefer)
	res = ok && ref.Value == v.Value
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

// Equals -
func (ref *AtRefer) Equals(e Expr) (res bool) {
	v, ok := e.(*AtRefer)
	res = ok && ref.Value == v.Value
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

// Equals -
func (alist *Alist) Equals(e Expr) (res bool) {
	v, ok := e.(*Alist)
	if !ok {
		return false
	}
	res = true
	for i, item := range alist.Value {
		if !item.Equals(v.Value[i]) {
			return false
		}
	}
	return
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

// Equals -
func (llist *Llist) Equals(e Expr) (res bool) {
	v, ok := e.(*Llist)
	if !ok {
		return false
	}
	res = true
	for i, item := range llist.Value {
		if !item.Equals(v.Value[i]) {
			return false
		}
	}
	return
}

// Dict -
type Dict struct {
	BaseExpr

	//json.Marshaler
	//json.Unmarshaler
	//Node    parsec.ParsecNode
	//Name    string

	Value   map[string]Expr
	CtxName string
}

func (dict *Dict) String() (res string) {
	res = "{"
	sep := ""
	keys := []string{}
	for key := range dict.Value {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	for _, key := range keys {
		res += fmt.Sprintf("%s%s:%v", sep, key, dict.Value[key])
		sep = " "
	}
	res += "}"
	return
}

// Eval -
func (dict *Dict) Eval() (res Expr) {
	d := map[string]Expr{}
	for key, item := range dict.Value {
		d[key] = item.Eval()
	}
	return &Dict{BaseExpr: dict.BaseExpr, Value: d, CtxName: dict.CtxName}
}

// Equals -
func (dict *Dict) Equals(e Expr) (res bool) {
	v, ok := e.(*Dict)
	if !ok {
		return false
	}
	res = true
	for key, item := range dict.Value {
		p, ok := v.Value[key]
		if !(ok && item.Equals(p)) {
			return false
		}
	}
	return
}

func (dict *Dict) Set(id string, expr Expr) {
	dict.Value[id] = expr
}

func (dict *Dict) Get(id string) (expr Expr, ok bool) {
	expr, ok = dict.Value[id]
	return expr, ok
}

// Prop -
type Prop struct {
	BaseExpr

	//Node    parsec.ParsecNode
	//Name    string

	Key     string
	Value   Expr
	CtxName string
}

func (prop *Prop) String() (res string) {
	return fmt.Sprintf("%s:%v", prop.Key, prop.Value)
}

// Lamb -
type Lambda struct {
	BaseExpr

	//json.Marshaler
	//Name    string

	Params  []*ID
	Body    Expr
	CtxName string
}

func (lamb *Lambda) String() (res string) {
	return fmt.Sprintf("%v->%v", lamb.Params, lamb.Body)
}

// Eval -
func (lamb *Lambda) Eval() (res Expr) {
	return lamb
}

// Equals -
func (lamb *Lambda) Equals(e Expr) (res bool) {
	v, ok := e.(*Lambda)
	res = ok && lamb == v
	return
}

// Apply -
func (lamb *Lambda) Apply(args []Expr) (res Expr) {
	//engine.debug(lamb.Debug(), args, ctxName)
	//fmt.Println("Lambdf Apply args: ", args)
	if len(lamb.Params) != len(args) {
		return ErrID
	}
	vars := map[string]Expr{}
	for i, item := range lamb.Params {
		vars[item.Value] = args[i].Eval()
	}

	lamb.GetParent().SetCtx(&Context{vars: &Dict{BaseExpr: lamb.BaseExpr, Value: vars}})
	//if ctxName != lamb.CtxName && ctxName == "main" {
	//	ctxName = lamb.CtxName
	//}
	//engine.debug("Lamb Apply", "locking...", lamb.Debug(), args)
	//lambLock.Lock()
	//engine.debug("Lamb Apply", "locked", lamb.Debug(), args)
	//engine.debug("Lamb Apply", "ctxName:", ctxName)
	//c, _ := engine.current.Load(ctxName)
	//c.(*Context).push(vars, ctxName)
	//engine.current[ctxName].push(vars, ctxName)
	//fmt.Println("Lambda Apply expr: ", lamb)
	//fmt.Println("Lambda Apply parent: ", lamb.GetParent())
	//fmt.Println("Lambda Apply Body Parent: ", lamb.Body.GetParent())
	res = lamb.Body.Eval()
	//c, _ = engine.current.Load(ctxName)
	//c.(*Context).pop(ctxName)
	//engine.current[ctxName].pop(ctxName)
	//lambLock.Unlock()
	//engine.debug("Lamb Apply", "Unlocked", lamb.Debug(), args)
	return
}

// Func -
type Func func([]Expr) Expr

// Match -
type Match func([]Expr, Expr) bool
