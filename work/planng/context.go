package main

func coreFuncs() map[string]Func {
	return map[string]Func{
		//"parse": parse,
		"quote": quote,
		"eval":  eval,
		"func":  lambda,
		"set":   set,
		"print": printExprs,
		"let":   let,
		"do":    do,
		"==":    eq,
	}
}

type Context struct {
	stack *Stack
	vars  *Dict
	funcs map[string]Func
}

var TopCtx = Context{
	stack: &Stack{a: []Expr{}, i: -1},
	vars:  &Dict{BaseExpr: BaseExpr{Name: "TopCtx"}, Value: map[string]Expr{}, CtxName: "main"},
	funcs: map[string]Func{},
}

func (ctx *Context) GetFunc(name string) (f Func, ok bool) {
	f, ok = ctx.funcs[name]
	return
}

func (ctx *Context) AddFuncs(funcs map[string]Func) {
	for key, fn := range funcs {
		ctx.funcs[key] = fn
	}
}

func (ctx *Context) Push(expr Expr) {
	ctx.stack.Push(expr)
}

func (ctx *Context) Pop() (expr Expr) {
	expr = ctx.stack.Pop()
	return
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

	for expr != nil {
		parent := expr.GetParent()
		if parent != nil {
			ctx := parent.GetCtx()
			if ctx != nil {
				val, ok := ctx.Get(ref)
				if ok {
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
