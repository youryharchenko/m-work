package main

type Stack struct {
	a []Expr
	i int
}

func (st *Stack) Push(expr Expr) {
	if st.i < len(st.a)-1 {
		st.i += 1
		st.a[st.i] = expr
	} else if st.i == len(st.a)-1 {
		st.i += 1
		st.a = append(st.a, expr)
	}
}

func (st *Stack) Pop() (expr Expr) {
	if st.i < 0 {
		return nil
	}

	expr = st.a[st.i]
	st.a[st.i] = nil
	st.i -= 1
	return
}

func (st *Stack) Len() int {
	return st.i + 1
}
