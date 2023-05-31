package main

import (
	"fmt"
	"math"
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

func coreFuncs() map[string]Func {
	return map[string]Func{
		//"parse": parse,
		"quote": quote,
		"eval":  eval,
		"set":   set,
		"print": printExprs,
		"+":     sum,
		"*":     prod,
		"-":     sub,
		"/":     div,
		"%":     mod,
		"^":     pow,
	}
}

func applyFunc(llist *Llist) Expr {

	fn := llist.Value[0].Eval()
	args := llist.Value[1:]

	switch fnExpr := fn.(type) {
	case *ID:
		name := fnExpr.Value
		f, ok := coreFuncs()[name]
		if !ok {
			return UndefID
		}
		res := f(args)
		//engine.debug("applyFunc", fn.Debug(), args, res)
		return res
		//case *Lamb:
		//	res := fnExpr.Apply(args, ctxName)
		//engine.debug("applyFunc", ctxName, fn.Debug(), args, res)
		//	return res
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

func sum(args []Expr) Expr {
	if len(args) < 2 {
		return ErrID
	}

	bInt := true
	si := 0
	sf := 0.0
	for _, arg := range args {
		a := arg.Eval()
		switch a.(type) {
		case *Int:
			si += a.(*Int).Value
		case *Float:
			sf += a.(*Float).Value
			bInt = false
		}
	}
	if bInt {
		//return &Int{Value: si, Name: "Num"}
		return &Int{BaseExpr: BaseExpr{Name: "Num"}, Value: si, CtxName: "sum"}
	}
	sf += float64(si)
	//return &Float{Value: sf, Name: "Num", CtxName: ctxName}
	return &Float{BaseExpr: BaseExpr{Name: "Num"}, Value: sf, CtxName: "sum"}
}

func prod(args []Expr) Expr {
	if len(args) < 2 {
		return ErrID
	}
	bInt := true
	si := 1
	sf := 1.0
	for _, arg := range args {
		a := arg.Eval()
		switch a.(type) {
		case *Int:
			si *= a.(*Int).Value
		case *Float:
			sf *= a.(*Float).Value
			bInt = false
		}
	}
	if bInt {
		//return &Int{Value: si, Name: "Num", CtxName: ctxName}
		return &Int{BaseExpr: BaseExpr{Name: "Num"}, Value: si, CtxName: "prod"}
	}
	sf *= float64(si)
	//return &Float{Value: sf, Name: "Num", CtxName: ctxName}
	return &Float{BaseExpr: BaseExpr{Name: "Num"}, Value: sf, CtxName: "prod"}
}

func sub(args []Expr) Expr {
	if len(args) != 2 {
		return ErrID
	}
	bInt := true
	var si int
	var sf float64
	for i, arg := range args[:2] {
		a := arg.Eval()
		switch a.(type) {
		case *Int:
			if i == 0 {
				si = a.(*Int).Value
				sf = float64(a.(*Int).Value)
			} else {
				si -= a.(*Int).Value
				sf -= float64(a.(*Int).Value)
			}
		case *Float:
			if i == 0 {
				sf = a.(*Float).Value
			} else {
				sf -= a.(*Float).Value
			}
			bInt = false
		}
	}
	if bInt {
		//return &Int{Value: si, Name: "Num", CtxName: ctxName}
		return &Int{BaseExpr: BaseExpr{Name: "Num"}, Value: si, CtxName: "sub"}
	}
	//return &Float{Value: sf, Name: "Num", CtxName: ctxName}
	return &Float{BaseExpr: BaseExpr{Name: "Num"}, Value: sf, CtxName: "sub"}
}

func div(args []Expr) Expr {
	if len(args) != 2 {
		return ErrID
	}
	var sf float64
	for i, arg := range args[:2] {
		a := arg.Eval()
		switch a.(type) {
		case *Int:
			if i == 0 {
				sf = float64(a.(*Int).Value)
			} else {
				sf /= float64(a.(*Int).Value)
			}
		case *Float:
			if i == 0 {
				sf = a.(*Float).Value
			} else {
				sf /= a.(*Float).Value
			}
		}
	}
	//return &Float{Value: sf, Name: "Num", CtxName: ctxName}
	return &Float{BaseExpr: BaseExpr{Name: "Num"}, Value: sf, CtxName: "div"}
}

func mod(args []Expr) Expr {
	if len(args) != 2 {
		return ErrID
	}
	var si int
	for i, arg := range args[:2] {
		a := arg.Eval()
		switch a.(type) {
		case *Int:
			if i == 0 {
				si = a.(*Int).Value
			} else {
				si %= a.(*Int).Value
			}
		case *Float:
			if i == 0 {
				si = int(a.(*Float).Value)
			} else {
				si %= int(a.(*Float).Value)
			}
		}
	}
	//return &Int{Value: si, Name: "Num", CtxName: ctxName}
	return &Int{BaseExpr: BaseExpr{Name: "Num"}, Value: si, CtxName: "mod"}
}

func pow(args []Expr) Expr {
	if len(args) != 2 {
		return ErrID
	}

	bInt := true
	var x float64
	var y float64
	for i, arg := range args[:2] {
		a := arg.Eval()
		switch a.(type) {
		case *Int:
			if i == 0 {
				x = float64(a.(*Int).Value)
			} else {
				y = float64(a.(*Int).Value)
			}
		case *Float:
			if i == 0 {
				x = a.(*Float).Value
			} else {
				y = a.(*Float).Value
			}
			bInt = false
		}
	}
	if bInt {
		//return &Int{Value: int(math.Pow(x, y)), Name: "Num", CtxName: ctxName}
		return &Int{BaseExpr: BaseExpr{Name: "Num"}, Value: int(math.Pow(x, y)), CtxName: "pow"}
	}
	//return &Float{Value: math.Pow(x, y), Name: "Num"}
	return &Float{BaseExpr: BaseExpr{Name: "Num"}, Value: math.Pow(x, y), CtxName: "pow"}
}
