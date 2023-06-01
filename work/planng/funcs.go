package main

import (
	"fmt"
)

// Constants -
const (
	TRUE      = "true"
	FALSE     = "false"
	ERROR     = "error"
	NULL      = "null"
	UNDEFINED = "undefined"
	//BREAK     = "break"
	//CONTINUE  = "contunue"
)

var (
	TrueID  = &ID{Value: TRUE, BaseExpr: BaseExpr{Name: "ID"}}
	FalseID = &ID{Value: FALSE, BaseExpr: BaseExpr{Name: "ID"}}
	ErrID   = &ID{Value: ERROR, BaseExpr: BaseExpr{Name: "ID"}}
	NullID  = &ID{Value: NULL, BaseExpr: BaseExpr{Name: "ID"}}
	UndefID = &ID{Value: UNDEFINED, BaseExpr: BaseExpr{Name: "ID"}}
)

func applyFunc(llist *Llist) Expr {

	fn := llist.Value[0].Eval()
	args := llist.Value[1:]

	switch fnExpr := fn.(type) {
	case *ID:
		name := fnExpr.Value
		f, ok := TopCtx.GetFunc(name)
		if !ok {
			return UndefID
		}
		res := f(args)
		//engine.debug("applyFunc", fn.Debug(), args, res)
		return res
	case *Lambda:
		res := fnExpr.Apply(args)
		//engine.debug("applyFunc", ctxName, fn.Debug(), args, res)
		return res
	}
	//engine.debug("applyFunc", fn.Debug(), args, UndefID)
	return UndefID
}

func quote(args []Expr) Expr {
	if len(args) == 0 {
		return NullID
	}
	if len(args) > 1 {
		return ErrID
	}
	return args[0]
}

func eval(args []Expr) Expr {
	if len(args) == 0 {
		return NullID
	}
	if len(args) > 1 {
		return ErrID
	}
	return args[0].Eval().Eval()
}

func printExprs(args []Expr) Expr {
	for _, arg := range args {
		fmt.Println(arg.Eval())
	}
	return &Int{BaseExpr: BaseExpr{Name: "Num"}, Value: len(args), CtxName: "print"}
}

func set(args []Expr) Expr {
	if len(args) != 2 {
		return ErrID
	}

	val := args[1].Eval()
	id, ok := args[0].Eval().(*ID)
	if !ok {
		return ErrID
	}

	ctx := FindCtx(id)

	ctx.Set(id, val)
	return val

	//c, _ := engine.current.Load(ctxName)
	//return c.(*Context).set(args[0].Eval().String(), args[1].Eval())
	//return engine.current[ctxName].set(args[0].Eval().String(), args[1].Eval())
}

func let(args []Expr) Expr {
	if len(args) < 1 {
		return ErrID
	}
	parent := args[0].GetParent()

	d, ok := args[0].Eval().(*Dict)
	if !ok {
		return ErrID
	}

	parent.SetCtx(&Context{vars: d})

	res := do(args[1:])

	//engine.debug("let", d.CtxName)
	//c, _ := engine.current.Load(ctxName)
	//c.(*Context).push(d.Value, ctxName)

	//engine.current[ctxName].push(d.Value, ctxName)
	//do(args[1:], ctxName)
	//c, _ = engine.current.Load(ctxName)
	//res = c.(*Context).dict()
	//res = engine.current[ctxName].dict()
	//c, _ = engine.current.Load(ctxName)
	//c.(*Context).pop(ctxName)
	//engine.current[ctxName].pop(ctxName)
	return res
}

func do(args []Expr) Expr {
	var res Expr = NullID
	for _, item := range args {
		res = item.Eval()
		//id, ok := res.(*ID)
		//if ok && id.Value == BREAK {
		//	break
		//}
		//if ok && id.Value == CONTINUE {
		//	break
		//}
	}
	return res
}

func lambda(args []Expr) Expr {
	if len(args) != 2 {
		return ErrID
	}
	alist, ok := args[0].(*Alist)
	if !ok {
		return ErrID
	}
	params := []*ID{}
	for _, item := range alist.Value {
		param, ok := item.Eval().(*ID)
		if !ok {
			return ErrID
		}
		params = append(params, param)
	}
	body := args[1]
	return &Lambda{BaseExpr: BaseExpr{Name: "Lambda", Parent: args[0].GetParent()}, Params: params, Body: body, CtxName: "lambda"}
}

func eq(args []Expr) Expr {
	if len(args) != 2 {
		return ErrID
	}
	if args[0].Eval().Equals(args[1].Eval()) {
		return TrueID
	}
	return FalseID
}
