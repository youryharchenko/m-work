package main

func type_(args []Expr) Expr {
	if len(args) != 1 {
		return ErrID
	}
	return &ID{BaseExpr: BaseExpr{Name: "ID"}, Value: args[0].GetName()}
}

func reftype(args []Expr) Expr {
	if len(args) != 1 {
		return ErrID
	}

	ref, ok := args[0].(*Refer)
	if !ok {
		return ErrID
	}
	expr := FindRef(ref)
	return &ID{BaseExpr: BaseExpr{Name: "ID"}, Value: expr.GetName()}
}

func findctx(args []Expr) Expr {
	if len(args) != 1 {
		return ErrID
	}
	return FindCtx(args[0]).vars
}

func parent(args []Expr) Expr {
	if len(args) != 1 {
		return ErrID
	}
	res := args[0].Eval().GetParent()
	if res != nil {
		return res
	}
	return NullID
}

func root(args []Expr) Expr {
	if len(args) != 1 {
		return ErrID
	}
	res := args[0].Eval().GetParent()
	if res != nil {
		r := res
		for r != nil {
			res = r
			r = res.GetParent()
			//fmt.Println(r)
		}
		return res
	}
	return NullID

}
