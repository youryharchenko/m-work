package main

import "fmt"

func coreFuncs() map[string]Func {
	return map[string]Func{
		//"parse": parse,
		"quote":   quote,
		"eval":    eval,
		"func":    lambda,
		"set":     set,
		"print":   printExprs,
		"let":     let,
		"do":      do,
		"if":      iff,
		"==":      eq,
		"<>":      neq,
		"not":     not,
		"is":      is,
		"test":    test,
		"among":   among,
		"type":    type_,
		"reftype": reftype,
		"ctx":     findctx,
		"parent":  parent,
		"root":    root,
	}
}

type Context struct {
	stack *Stack
	stat  *ID
	vars  *Dict
	funcs map[string]Func
	patts map[string]Match
}

var TopCtx = Context{
	stack: &Stack{a: []Expr{}, i: -1},
	vars:  &Dict{BaseExpr: BaseExpr{Name: "TopCtx"}, Value: map[string]Expr{}, CtxName: "main"},
	funcs: map[string]Func{},
	patts: map[string]Match{},
}

func (ctx *Context) MergeVars(nctx *Context) {
	for k, v := range nctx.vars.Value {
		ctx.vars.Value[k] = v
	}
}

func (ctx *Context) GetFunc(name string) (f Func, ok bool) {
	f, ok = ctx.funcs[name]
	return
}

func (ctx *Context) GetPat(name string) (f Match, ok bool) {
	f, ok = ctx.patts[name]
	return
}

func (ctx *Context) AddFuncs(funcs map[string]Func) {
	for key, fn := range funcs {
		ctx.funcs[key] = fn
	}
}

func (ctx *Context) AddMatches(matches map[string]Match) {
	for key, fn := range matches {
		ctx.patts[key] = fn
	}
}

func (ctx *Context) Push(expr Expr) {
	ctx.stack.Push(expr)
}

func (ctx *Context) Pop() (expr Expr) {
	expr = ctx.stack.Pop()
	return
}

func (ctx *Context) Len() int {
	return ctx.stack.Len()
}

func (ctx *Context) SetStat(stat *ID) {
	ctx.stat = stat
}

func (ctx *Context) GetStat() *ID {
	return ctx.stat
}

func (ctx *Context) Set(id *ID, expr Expr) {
	ctx.vars.Set(id.Value, expr)
}

func (ctx *Context) Get(ref *Refer) (Expr, bool) {
	expr, ok := ctx.vars.Get(ref.Value)
	return expr, ok
}

func FindCtx(expr Expr) (ctx *Context) {
	for expr != nil {
		parent := expr.GetParent()
		if parent != nil {
			ctx = parent.GetCtx()
			if ctx != nil {
				return
			}
		}
		expr = parent
	}
	ctx = &TopCtx
	return
}

func FindRef(ref *Refer) Expr {
	var expr Expr = ref
	fmt.Println("FindRef:----start: ", ref)
	for expr != nil {
		parent := expr.GetParent()
		if parent != nil {
			ctx := parent.GetCtx()
			if ctx != nil {
				fmt.Println("FindRef: ", parent.GetName(), ctx, ctx.vars.Value, expr.GetParent())
				val, ok := ctx.Get(ref)
				if ok {
					fmt.Println("FindRef:---finish: ", val)
					return val
				}
			}
		}
		expr = parent
	}

	val, ok := TopCtx.Get(ref)
	if ok {
		return val
	}

	return UndefID
}

func TraceCtx(expr Expr) {
	for expr != nil {
		if expr.GetCtx() != nil {
			fmt.Println("TraceCtx: ", expr, expr.GetCtx().vars)
		} else {
			fmt.Println("TraceCtx: ", expr, expr.GetCtx())
		}
		expr = expr.GetParent()
	}
}
