package main

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

	alter, ok := args[0].(*Alist)
	if !ok {
		return ErrID
	}

	fw := args[1].Eval()
	var res Expr
	TopCtx.SetStat(FailID)
	for _, expr := range alter.Value {
		switch fn := fw.(type) {
		case *ID:
			name := fn.Value
			f, ok := TopCtx.GetFunc(name)
			if !ok {
				return UndefID
			}
			res = f([]Expr{expr})
		case *Lambda:
			res = fn.Apply([]Expr{expr})
		}
		if !res.Equals(FailID) {
			TopCtx.SetStat(OkID)
			return res
		}
	}
	return FailID
	//expr := &Among{BaseExpr: BaseExpr{Name: "Among"}, Value: alter.Value, Index: 0}

}
