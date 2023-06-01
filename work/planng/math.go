package main

import (
	"fmt"
	"math"
)

func mathFuncs() map[string]Func {
	return map[string]Func{
		"+": sum,
		"-": sub,
		"*": prod,
		"/": div,
		"%": mod,
		"^": pow,
		//"abs":   abs,
		">":  gt,
		"<":  lt,
		">=": ge,
		"<=": le,
		//"range": rangeInt,
		//"int":   toInt,
		//"float": toFloat,
	}
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

func gt(args []Expr) Expr {
	if len(args) != 2 {
		return ErrID
	}
	fInt := func(x int, y int) bool { return x > y }
	fFloat := func(x float64, y float64) bool { return x > y }

	b, err := compareNum(args[0].Eval(), args[1].Eval(), fInt, fFloat)
	if err == nil {
		if b {
			return TrueID
		}
		return FalseID
	}
	return ErrID
}

func lt(args []Expr) Expr {
	if len(args) != 2 {
		return ErrID
	}
	fInt := func(x int, y int) bool { return x < y }
	fFloat := func(x float64, y float64) bool { return x < y }

	b, err := compareNum(args[0].Eval(), args[1].Eval(), fInt, fFloat)
	if err == nil {
		if b {
			return TrueID
		}
		return FalseID
	}
	return ErrID
}

func ge(args []Expr) Expr {
	if len(args) != 2 {
		return ErrID
	}
	fInt := func(x int, y int) bool { return x >= y }
	fFloat := func(x float64, y float64) bool { return x >= y }

	b, err := compareNum(args[0].Eval(), args[1].Eval(), fInt, fFloat)
	if err == nil {
		if b {
			return TrueID
		}
		return FalseID
	}
	return ErrID
}

func le(args []Expr) Expr {
	if len(args) != 2 {
		return ErrID
	}
	fInt := func(x int, y int) bool { return x <= y }
	fFloat := func(x float64, y float64) bool { return x <= y }

	b, err := compareNum(args[0].Eval(), args[1].Eval(), fInt, fFloat)
	if err == nil {
		if b {
			return TrueID
		}
		return FalseID
	}
	return ErrID
}

func compareNum(e1 Expr, e2 Expr, fInt func(x int, y int) bool, fFloat func(x float64, y float64) bool) (bool, error) {
	b, err := compareInt(e1, e2, fInt)
	if err == nil {
		if b {
			return true, nil
		}
		return false, nil
	}
	b, err = compareFloat(e1, e2, fFloat)
	if err == nil {
		if b {
			return true, nil
		}
		return false, nil
	}
	b, err = compareToFloat(e1, e2, fFloat)
	if err == nil {
		if b {
			return true, nil
		}
		return false, nil
	}
	return false, fmt.Errorf("error compareNum")
}

func compareFloat(e1 Expr, e2 Expr, f func(x float64, y float64) bool) (bool, error) {
	f1, ok := e1.(*Float)
	if !ok {
		return false, fmt.Errorf("first arg not Float")
	}
	f2, ok := e2.(*Float)
	if !ok {
		return false, fmt.Errorf("second arg not Float")
	}
	return f(f1.Value, f2.Value), nil
}

func compareToFloat(e1 Expr, e2 Expr, f func(x float64, y float64) bool) (bool, error) {
	ef1, ok := e1.(*Float)
	var f1 float64
	if !ok {
		i1, ok := e1.(*Int)
		if !ok {
			return false, fmt.Errorf("first arg not Float abd not Int")
		}
		f1 = float64(i1.Value)
	} else {
		f1 = ef1.Value
	}
	ef2, ok := e2.(*Float)
	var f2 float64
	if !ok {
		i2, ok := e2.(*Int)
		if !ok {
			return false, fmt.Errorf("second arg not Float abd not Int")
		}
		f2 = float64(i2.Value)
	} else {
		f2 = ef2.Value
	}
	return f(f1, f2), nil
}

func compareInt(e1 Expr, e2 Expr, f func(x int, y int) bool) (bool, error) {
	i1, ok := e1.(*Int)
	if !ok {
		return false, fmt.Errorf("first arg not Int")
	}
	i2, ok := e2.(*Int)
	if !ok {
		return false, fmt.Errorf("second arg not Int")
	}
	return f(i1.Value, i2.Value), nil
}
