package main

import (
	"fmt"
	"strconv"
	"strings"

	parsec "github.com/prataprc/goparsec"
)

func atomNode(ns []parsec.ParsecNode) parsec.ParsecNode {
	fmt.Println("atomNode:", ns)
	if ns == nil || len(ns) < 1 {
		return nil
	}
	switch n := ns[0].(type) {
	case *parsec.Terminal:
		//engine.debug("atomNode", *n)
		switch n.Name {
		case "INT":
			i, _ := strconv.Atoi(n.Value)
			return &Int{BaseExpr: BaseExpr{Node: n, Name: "Num"}, Value: i, CtxName: "main"}
		case "OCT":
			i, _ := strconv.ParseInt(n.Value, 0, 0)
			return &Int{BaseExpr: BaseExpr{Node: n, Name: "Num"}, Value: int(i), CtxName: "main"}
		case "HEX":
			i, _ := strconv.ParseInt(n.Value, 0, 0)
			return &Int{BaseExpr: BaseExpr{Node: n, Name: "Num"}, Value: int(i), CtxName: "main"}
		case "FLOAT":
			f, _ := strconv.ParseFloat(n.Value, 64)
			return &Float{BaseExpr: BaseExpr{Node: n, Name: "Num"}, Value: f, CtxName: "main"}
		case "IDENT":
			return &ID{BaseExpr: BaseExpr{Node: n, Name: "ID"}, Value: n.Value, CtxName: "main"}
		case "OP":
			return &ID{BaseExpr: BaseExpr{Node: n, Name: "ID"}, Value: n.Value, CtxName: "main"}
		default:
			fmt.Println("Unknown n.Name", n.Name)
			return nil
		}

	case []parsec.ParsecNode:
		//engine.debug("atomNode", n[0], n[1])
		return n
	//case map[string]interface{}:
	//	return n
	case string:
		return &Text{BaseExpr: BaseExpr{Node: n, Name: "Text"}, Value: strings.ReplaceAll(n, `"`, ""), CtxName: "main"}
	case *Refer:
		return n
	case *SegRefer:
		return n
	case *AtRefer:
		return n
	default:
		//engine.debug("atomNode: unknown type", reflect.TypeOf(n).String())
		fmt.Println("Unknown ns[0].(type)", n)
	}
	return nil
}

func referNode(ns []parsec.ParsecNode) parsec.ParsecNode {
	fmt.Println("referNode:", ns)
	if ns == nil || len(ns) < 1 {
		return nil
	}
	//engine.debug("referNode", ns)
	//fmt.Println(ns)
	id := nodeToExpr(ns[1]).String()
	return &Refer{BaseExpr: BaseExpr{Node: ns[1], Name: "Refer"}, Value: id, CtxName: "main"}
}

func segReferNode(ns []parsec.ParsecNode) parsec.ParsecNode {
	fmt.Println("segReferNode:", ns)
	if ns == nil || len(ns) < 1 {
		return nil
	}
	//engine.debug("referNode", ns)
	//fmt.Println(ns)
	ref := nodeToExpr(ns[1])
	return &SegRefer{BaseExpr: BaseExpr{Node: ns[1], Name: "SegRefer"}, Value: ref, CtxName: "main"}
}

func atReferNode(ns []parsec.ParsecNode) parsec.ParsecNode {
	fmt.Println("atReferNode:", ns)
	if ns == nil || len(ns) < 1 {
		return nil
	}
	//engine.debug("referNode", ns)
	//fmt.Println(ns)
	id := nodeToExpr(ns[1]).String()
	return &AtRefer{BaseExpr: BaseExpr{Node: ns[1], Name: "AtRefer"}, Value: id, CtxName: "main"}
}

func alistNode(ns []parsec.ParsecNode) parsec.ParsecNode {
	fmt.Println("alistNode:", ns)
	if ns == nil || len(ns) < 1 {
		return nil
	}
	//engine.debug("alistNode", ns)
	ilist, ok := ns[1].([]parsec.ParsecNode)
	if !ok {
		return nil
	}

	alist := &Alist{BaseExpr: BaseExpr{Node: ns[1], Name: "Alist"}, CtxName: "main"}
	list := []Expr{}
	for _, item := range ilist {
		iexpr := nodeToExpr(item)
		iexpr.SetParent(alist)
		list = append(list, iexpr)
	}
	alist.Value = list
	return alist //&Alist{BaseExpr: BaseExpr{Node: ns[1], Name: "Alist"}, Value: list, CtxName: "main"}
}

/*
	func mlistNode(ns []parsec.ParsecNode) parsec.ParsecNode {
		if ns == nil || len(ns) < 1 {
			return nil
		}
		//engine.debug("mlistNode", ns)
		ilist, ok := ns[1].([]parsec.ParsecNode)
		if !ok {
			return nil
		}
		list := []Expr{}
		for _, item := range ilist {
			list = append(list, nodeToExpr(item))
		}
		return &Mlist{Node: ns[1], Value: list, Name: "Mlist", CtxName: "main"}
	}
*/
func llistNode(ns []parsec.ParsecNode) parsec.ParsecNode {
	fmt.Println("llistNode:", ns)
	if ns == nil || len(ns) < 1 {
		return nil
	}
	//engine.debug("llistNode", ns)
	ilist, ok := ns[1].([]parsec.ParsecNode)
	if !ok {
		return nil
	}

	llist := &Llist{BaseExpr: BaseExpr{Node: ns[1], Name: "Llist"}, CtxName: "main"}
	list := []Expr{}
	for _, item := range ilist {
		iexpr := nodeToExpr(item)
		iexpr.SetParent(llist)
		list = append(list, iexpr)
	}
	llist.Value = list
	return llist
}

func propNode(ns []parsec.ParsecNode) parsec.ParsecNode {
	if ns == nil || len(ns) < 1 {
		return nil
	}
	//engine.debug("propNode", ns)
	var key string
	switch e := nodeToExpr(ns[0]).(type) {
	case *ID:
		key = e.Value
	//case *Text:
	//	key = e.Value
	default:
		key = e.String()
	}
	item := nodeToExpr(ns[2])
	return &Prop{BaseExpr: BaseExpr{Node: ns[1], Name: "Prop"}, Key: key, Value: item, CtxName: "main"}
}

func dictNode(ns []parsec.ParsecNode) parsec.ParsecNode {
	if ns == nil || len(ns) < 1 {
		return nil
	}
	//engine.debug("dictNode", ns)
	ilist, ok := ns[1].([]parsec.ParsecNode)
	if !ok {
		return nil
	}
	dict := &Dict{BaseExpr: BaseExpr{Node: ns[1], Name: "Dict"}, CtxName: "main"}
	m := map[string]Expr{}
	for _, item := range ilist {
		prop := nodeToExpr(item).(*Prop)

		iexpr := nodeToExpr(prop.Value)
		iexpr.SetParent(dict)

		m[prop.Key] = iexpr
	}
	dict.Value = m
	return dict
}

/*
func commentNode(ns []parsec.ParsecNode) parsec.ParsecNode {
	if ns == nil || len(ns) < 1 {
		return nil
	}
	comment := ns[1].(*parsec.Terminal)
	//engine.debug("commentNode", comment.Value)
	return &Comment{Node: ns[1], Value: comment.Value, Name: "Comment"}
}
*/

func nodeToExpr(node parsec.ParsecNode) (res Expr) {
	switch n := node.(type) {
	case *Int:
		res = node.(*Int)
	case *Float:
		res = node.(*Float)
	case *ID:
		res = node.(*ID)
	case *Refer:
		res = node.(*Refer)
	case *SegRefer:
		res = node.(*SegRefer)
	case *AtRefer:
		res = node.(*AtRefer)
	case *Alist:
		res = node.(*Alist)
	//case *Mlist:
	//	res = node.(*Mlist)
	case *Llist:
		res = node.(*Llist)
	case *Prop:
		res = node.(*Prop)
	case *Dict:
		res = node.(*Dict)
	case *Text:
		res = node.(*Text)
	case string:
		return &Text{BaseExpr: BaseExpr{Node: node, Name: "Text"}, Value: strings.ReplaceAll(n, `"`, ""), CtxName: "main"}
	//case *Comment:
	//	res = node.(*Comment)
	case []parsec.ParsecNode:
		//engine.debug("nodeToExpr: []parsec.ParsecNode:", node)
		fmt.Println("nodeToExpr: []parsec.ParsecNode:", node)
		nodes := node.([]parsec.ParsecNode)
		if len(nodes) == 1 {
			res = nodeToExpr(nodes[0])
		} else {
			//engine.debug("nodeToExpr: []parsec.ParsecNode: len > 1", node)
			//fmt.Println("nodeToExpr: []parsec.ParsecNode: len != 1", node)
			//res =
		}
	case *parsec.Terminal:
		//engine.debug("nodeToExpr: *parsec.Terminal", node)
		fmt.Println("nodeToExpr: *parsec.Terminal", node)
		switch n.Name {
		case "INT":
			i, _ := strconv.Atoi(n.Value)
			res = &Int{BaseExpr: BaseExpr{Node: n, Name: "Num"}, Value: i, CtxName: "main"}
		case "FLOAT":
			f, _ := strconv.ParseFloat(n.Value, 64)
			res = &Float{BaseExpr: BaseExpr{Node: n, Name: "Num"}, Value: f, CtxName: "main"}
		case "IDENT":
			res = &ID{BaseExpr: BaseExpr{Node: n, Name: "ID"}, Value: n.Value, CtxName: "main"}
		case "OP":
			res = &ID{BaseExpr: BaseExpr{Node: n, Name: "ID"}, Value: n.Value, CtxName: "main"}
		}
	default:
		//engine.debug("nodeToExpr: unknown type", reflect.TypeOf(node))
	}
	return
}

/*
func debugNodes(nodes []parsec.ParsecNode, deep int) {

	for _, node := range nodes {
		switch node.(type) {
		case *parsec.Terminal:
			v := node.(*parsec.Terminal)
			engine.debug(strings.Repeat(".", deep*2), v.Name, v.Value, v.Position, v.Attributes)
		case *Int:
			v := node.(*Int)
			engine.debug(strings.Repeat(".", deep*2), v.Debug())
		case *Float:
			v := node.(*Float)
			engine.debug(strings.Repeat(".", deep*2), v.Debug())
		case *ID:
			v := node.(*ID)
			engine.debug(strings.Repeat(".", deep*2), v.Debug())
		case *Refer:
			v := node.(*Refer)
			engine.debug(strings.Repeat(".", deep*2), v.Debug())
		case *Alist:
			v := node.(*Alist)
			engine.debug(strings.Repeat(".", deep*2), v.Debug())
		case *Mlist:
			v := node.(*Mlist)
			engine.debug(strings.Repeat(".", deep*2), v.Debug())
		case *Llist:
			v := node.(*Llist)
			engine.debug(strings.Repeat(".", deep*2), v.Debug())
		case *Dict:
			v := node.(*Dict)
			engine.debug(strings.Repeat(".", deep*2), v.Debug())
		case *Text:
			v := node.(*Text)
			engine.debug(strings.Repeat(".", deep*2), v.Debug())
		case []parsec.ParsecNode:
			v := node.([]parsec.ParsecNode)
			debugNodes(v, deep+1)
		default:
			engine.debug(reflect.TypeOf(node).String())
		}
	}
}
*/
