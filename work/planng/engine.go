package main

import (
	"bytes"
	"fmt"

	parsec "github.com/prataprc/goparsec"
)

type Engine struct {
	Y     parsec.Parser
	Debug bool
}

// New -
func New(debug bool) (eng *Engine) {
	eng = &Engine{
		//global:  &Context{parent: nil, vars: map[string]Expr{}},
		//current: sync.Map{}, // map[string]*Context{},
		Debug: debug,
	}
	eng.initParser()

	return
}

// Parse -
func (eng *Engine) Parse(src []byte) []parsec.ParsecNode {
	s := parsec.NewScanner(eng.skipComments(src))
	v, _ := eng.Y(s)
	return v.([]parsec.ParsecNode)
}

// EvalNodes -
func (eng *Engine) EvalNodes(nodes []parsec.ParsecNode) {
	var node any
	for _, node = range nodes {
		//eng.debug("evalNodes", node)
		switch node.(type) {
		case []parsec.ParsecNode:
			v := node.([]parsec.ParsecNode)
			eng.EvalNodes(v)
		default:
			TopCtx.SetStat(OkID)

			expr := nodeToExpr(node)
			res := expr.Eval()
			/*
				var res Expr
				var expr Expr

				TopCtx.Push(nodeToExpr(node))
				TopCtx.SetStat(OkID)

				for TopCtx.Len() > 0 {
					expr = TopCtx.Pop()
					res = expr.Eval()
				}
			*/
			eng.debug(TopCtx.GetStat(), " : ", expr, "=>", res) // "parent:", expr.GetParent()

		}
	}
}

func (eng *Engine) skipComments(src []byte) []byte {
	buf := bytes.Buffer{}
	skip := false
	for _, i := range src {
		if skip {
			if i == 0xA {
				skip = false
			}
			continue
		} else {
			if i == '#' {
				skip = true
				continue
			}
		}
		buf.WriteByte(i)

	}
	return buf.Bytes()
}

func (eng *Engine) debug(args ...interface{}) {
	if eng.Debug {
		fmt.Println(args...)
	}
}

func Oct() parsec.Parser {
	return parsec.Token(`0[oO][0-7]+`, "OCT")
}

func Op() parsec.Parser {
	return parsec.Token(`[+\-*/$%\^&=:;<>|]+`, "OP")
}

func (eng *Engine) initParser() {
	var value parsec.Parser
	var values = parsec.Kleene(nil, &value)

	var point = parsec.Atom(".", "POINT")
	var bang = parsec.Atom("!", "BANG")
	var at = parsec.Atom("@", "AT")

	//var pref = parsec.OrdChoice(nil, point, bang, at)

	var dotRefer = parsec.And(referNode, point, parsec.Ident())
	var segRefer = parsec.And(segReferNode, bang, dotRefer)
	var atRefer = parsec.And(atReferNode, at, parsec.Ident())
	//var oper = parsec.OrdChoice(nil, parsec.Atom("+", "OP"), parsec.Atom("-", "OP"), parsec.Atom("*", "OP"), parsec.Atom("/", "OP"), parsec.Atom("%", "OP"))
	var atom = parsec.OrdChoice(atomNode, parsec.Ident(), parsec.Float(), parsec.Hex(), Oct(), parsec.Int(), parsec.String(), Op(), dotRefer, segRefer, atRefer) // oper,

	var openSqrt = parsec.Atom("[", "OPENSQRT")
	var closeSqrt = parsec.Atom("]", "CLOSESQRT")
	var alist = parsec.And(alistNode, openSqrt, values, closeSqrt)

	var openPar = parsec.Atom("(", "OPENPAR")
	var closePar = parsec.Atom(")", "CLOSEPAR")
	var llist = parsec.And(llistNode, openPar, values, closePar)

	//var unOper = parseAnd(unOperNode, Op(), v)

	//var openAng = parsec.Atom("<", "OPENANG")
	//var closeAng = parsec.Atom(">", "CLOSEANG")
	//var mlist = parsec.And(mlistNode, openAng, values, closeAng)

	var colon = parsec.Atom(":", "COLON")
	var property = parsec.And(propNode, parsec.Ident(), colon, &value)
	//var property = parsec.And(propNode, parsec.OrdChoice(nil, parsec.Ident(), parsec.String()), colon, &value)
	var properties = parsec.Kleene(nil, property)

	var openBra = parsec.Atom("{", "OPENBRA")
	var closeBra = parsec.Atom("}", "CLOSEBRA")
	var dict = parsec.And(dictNode, openBra, properties, closeBra)

	value = parsec.OrdChoice(nil, atom, alist, llist, dict) //, mlist) //)

	eng.Y = parsec.OrdChoice(nil, values)

	//eng.Y = parsec.OrdChoice(nil, atom, alist, llist, mlist) //, dict)
}
