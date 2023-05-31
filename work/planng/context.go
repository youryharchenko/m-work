package main

type Context struct {
	vars map[string]Expr
}

var TopCtx = Context{
	vars: map[string]Expr{},
}

func (ctx *Context) Set(id *ID, expr Expr) {
	ctx.vars[id.Value] = expr
}

func (ctx *Context) Get(ref *Refer) (Expr, bool) {
	expr, ok := ctx.vars[ref.Value]
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
