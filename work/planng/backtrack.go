package main

import (
	"fmt"
	"time"
)

type Among struct {
	BaseExpr

	Value []Expr
	//Alter []Expr

	Index int
}

func among(args []Expr) Expr {
	if len(args) < 2 {
		return ErrID
	}

	alter, ok := args[0].Eval().(*Alist)
	if !ok {
		return ErrID
	}

	fw := args[1].Eval()
	out := make(chan Expr, len(alter.Value))

	TopCtx.SetStat(FailID)

	for _, expr := range alter.Value {
		go gosub(out, fw, []Expr{expr})
	}

	i := 0
	ret := &Alist{BaseExpr: BaseExpr{Name: "Alist"}}
	sols := []Expr{}
	for i < len(alter.Value) {
		select {
		case res := <-out:

			if !res.Equals(FailID) {
				//ret = res
				sols = append(sols, res)
				TopCtx.SetStat(OkID)
			}
			fmt.Println("Among: ", i, res)
			i += 1
		case <-time.After(10 * time.Second):
			//fmt.Println("timeout")
			return ErrID
		}
	}
	ret.Value = sols
	return ret
	//expr := &Among{BaseExpr: BaseExpr{Name: "Among"}, Value: alter.Value, Index: 0}
}

func gosub(out chan Expr, f Expr, args []Expr) {
	fmt.Println("gosub start: ", f, args)
	var res Expr
	switch fn := f.(type) {
	case *ID:
		name := fn.Value
		f, ok := TopCtx.GetFunc(name)
		if !ok {
			out <- UndefID
			return
		}
		res = f(args)
	case *Lambda:
		res = fn.Apply(args)
	}
	if !res.Equals(FailID) {
		//TopCtx.SetStat(OkID)
		out <- res
		fmt.Println("gosub finish: ", f, args, res)
		return
	}
	out <- FailID
	fmt.Println("gosub finish: ", f, args, FailID)
}
