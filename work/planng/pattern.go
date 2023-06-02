package main

func coreMathes() map[string]Match {
	return map[string]Match{
		"atom":  patAtom,
		"id":    patID,
		"num":   patNum,
		"int":   patInt,
		"float": patFloat,
		"text":  patText,
		"ref":   patRefer,
		"list":  patAlist,
		"apply": patLlist,
		"dict":  patDict,
		"func":  patLamb,
	}
}

func patAtom(args []Expr, e Expr) bool {
	if patNum(args, e) || patID(args, e) || patText(args, e) || patRefer(args, e) {
		return true
	}
	return false
}

func patID(args []Expr, e Expr) bool {
	if _, ok := e.(*ID); ok {
		return true
	}
	return false
}

func patInt(args []Expr, e Expr) bool {
	if _, ok := e.(*Int); ok {
		return true
	}
	return false
}

func patFloat(args []Expr, e Expr) bool {
	if _, ok := e.(*Float); ok {
		return true
	}
	return false
}

func patNum(args []Expr, e Expr) bool {
	if patInt(args, e) || patFloat(args, e) {
		return true
	}
	return false
}

func patText(args []Expr, e Expr) bool {
	if _, ok := e.(*Text); ok {
		return true
	}
	return false
}

func patRefer(args []Expr, e Expr) bool {
	if _, ok := e.(*Refer); ok {
		return true
	}
	return false
}

func patAlist(args []Expr, e Expr) bool {
	if _, ok := e.(*Alist); ok {
		return true
	}
	return false
}

func patLlist(args []Expr, e Expr) bool {
	if _, ok := e.(*Llist); ok {
		return true
	}
	return false
}

func patDict(args []Expr, e Expr) bool {
	if _, ok := e.(*Dict); ok {
		return true
	}
	return false
}

func patLamb(args []Expr, e Expr) bool {
	if _, ok := e.(*Lambda); ok {
		return true
	}
	return false
}

// Pattern -
type Pattern struct {
	ctx  *Context
	expr Expr
}

func (pat *Pattern) Commit() {
	oldCtx := FindCtx(pat.expr)
	oldCtx.MergeVars(pat.ctx)
}

func match(pat Expr, e Expr) Expr {

	//parent := pat.GetParent()

	//fmt.Println("math parent FindCtx(pat).vars (begin):", FindCtx(pat).vars)

	ctx := &Context{vars: &Dict{Value: map[string]Expr{}}}
	//parent.SetCtx(ctx)

	//fmt.Println("math parent ctx.vars (new):", ctx.vars)

	patCtx := &Pattern{ctx: ctx, expr: pat}
	//patCtx.begin()
	if patCtx.matchExpr(e) {
		//fmt.Println("math parent ctx.vars (commit):", ctx.vars)
		patCtx.Commit()
		//fmt.Println("math parent FindCtx(pat).vars (commit):", FindCtx(pat).vars)
		return TrueID
	}
	//patCtx.rollback()
	return FalseID
}

func (pat *Pattern) matchExpr(e Expr) (res bool) {
	switch pt := pat.expr.(type) {
	case *ID:
		res = pat.matchID(pt, e)
	case *Int:
		res = pat.matchInt(pt, e)
	case *Float:
		res = pat.matchFloat(pt, e)
	case *Llist:
		res = pat.matchLlist(pt, e)
	case *Refer:
		res = pat.matchRefer(pt, e)
	case *Alist:
		res = pat.matchAlist(pt, e)
		//case *Text:
		//	res = pat.matchText(pt, e)
	case *Dict:
		res = pat.matchDict(pt, e)
		//case *Mlist:
		//	res = pat.matchMlist(pt, e)
	}
	return
}

func (pat *Pattern) matchID(p *ID, e Expr) (res bool) {
	return p.Equals(e)
}

func (pat *Pattern) matchInt(p *Int, e Expr) (res bool) {
	return p.Equals(e)
}

func (pat *Pattern) matchFloat(p *Float, e Expr) (res bool) {
	return p.Equals(e)
}

func (pat *Pattern) matchLlist(p *Llist, e Expr) (res bool) {
	//return p.Equals(e)
	id, ok := p.Value[0].Eval().(*ID)
	if !ok {
		return false
	}
	name := id.Value
	f, ok := TopCtx.GetPat(name)
	if !ok {
		return false
	}
	return f(p.Value[1:], e)
}

func (pat *Pattern) matchRefer(p *Refer, e Expr) (res bool) {
	//c, _ := engine.current.Load(pat.ctxName)
	//ctx := c.(*Context)
	val := FindRef(p)
	if val.Equals(UndefID) {
		pat.ctx.Set(&ID{BaseExpr: p.BaseExpr, Value: p.Value}, e)
		return true
	}
	return p.Eval().Equals(e)

}

func (pat *Pattern) matchAlist(p *Alist, e Expr) (res bool) {
	eAlist, ok := e.(*Alist)
	if !ok {
		return false
	}
	//patAlist := p.expr.(*Alist)
	//if len(patAlist.Value) != len(eAlist.Value) {
	//	return false
	//}

	for i, item := range p.Value {
		epat := &Pattern{expr: item, ctx: pat.ctx}
		if !epat.matchExpr(eAlist.Value[i]) {
			return false
		}
	}
	return true
}

func (pat *Pattern) matchDict(p *Dict, e Expr) (res bool) {
	edict, ok := e.(*Dict)
	if !ok {
		return false
	}
	for key, item := range p.Value {
		v, ok := edict.Value[key]
		if !ok {
			return false
		}
		epat := &Pattern{expr: item, ctx: pat.ctx}
		if !epat.matchExpr(v) {
			return false
		}
	}
	return true
}
