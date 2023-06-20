package lib

import (
	"fmt"
	"log"
	"strconv"
	"strings"

	"github.com/jmoiron/sqlx"
)

var modelV = map[string]uint64{
	"document": 0,
	"sentence": 0,
	"token":    0,
	"tag":      0,
	"pattern":  0,
	"consists": 0,
	"is":       0,
	"number":   0,
	"0":        0,
	"title":    0,
	"_":        0,
}

var modelC = map[string]uint64{
	"document": 0,
	"sentence": 0,
	"token":    0,
	"tag":      0,
	"pattern":  0,
}

var modelR = map[string]uint64{
	"consists": 0,
	"is":       0,
}

var modelRC = map[[3]string]uint64{
	{"consists", "document", "sentence"}: 0,
	{"consists", "sentence", "token"}:    0,
	{"is", "token", "tag"}:               0,
	{"is", "sentence", "pattern"}:        0,
}

var modelA = map[string]uint64{
	"number": 0,
	"title":  0,
}

var modelAC = map[[3]string]uint64{
	{"document", "title", "_"}: 0,
}

var modelAR = map[[3]string]uint64{
	{"consists", "number", "0"}: 0,
}

var modelARC = map[[5]string]uint64{
	{"consists", "document", "sentence", "number", "0"}: 0,
	{"consists", "sentence", "token", "number", "0"}:    0,
}

func UploadDocument(conn *sqlx.DB, doc *Document) (err error) {

	err = initModel(conn)
	if err != nil {
		return
	}

	v_id_doc, err := makeV(conn, typeOf(doc.Name), doc.Name)
	if err != nil {
		return
	}

	o_id_doc, err := makeO(conn, v_id_doc)
	if err != nil {
		return
	}

	c_id_doc, ok := modelC["document"]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", "document")
	}

	c_id_sent, ok := modelC["sentence"]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", "sentence")
	}

	c_id_pattern, ok := modelC["pattern"]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", "pattern")
	}

	rc_id_doc_sent, ok := modelRC[[3]string{"consists", "document", "sentence"}]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", [3]string{"consists", "document", "sentence"})
	}

	rc_id_sent_pattern, ok := modelRC[[3]string{"is", "sentence", "pattern"}]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", [3]string{"is", "sentence", "pattern"})
	}

	co_id_doc, err := makeCO(conn, c_id_doc, o_id_doc)
	if err != nil {
		return
	}

	v_id_title, err := makeV(conn, typeOf(doc.Title), doc.Title)
	if err != nil {
		return
	}

	ac_id_doc_title, ok := modelAC[[3]string{"document", "title", "_"}]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", [3]string{"document", "title", "_"})
	}

	aco_id_doc_title, err := makeACO(conn, co_id_doc, ac_id_doc_title, v_id_title)
	if err != nil {
		return
	}

	arc_id_sent_number, ok := modelARC[[5]string{"consists", "document", "sentence", "number", "0"}]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", [5]string{"consists", "document", "sentence", "number", "0"})
	}

	c_id_tok, ok := modelC["token"]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", "token")
	}

	rc_id_sent_tok, ok := modelRC[[3]string{"consists", "sentence", "token"}]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", [3]string{"consists", "sentence", "token"})
	}

	arc_id_tok_number, ok := modelARC[[5]string{"consists", "sentence", "token", "number", "0"}]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", [5]string{"consists", "sentence", "token", "number", "0"})
	}

	c_id_tag, ok := modelC["tag"]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", "tag")
	}

	rc_id_tok_tag, ok := modelRC[[3]string{"is", "token", "tag"}]
	if !ok {
		return fmt.Errorf("UploadDocument: %s is missing", [3]string{"is", "token", "tag"})
	}

	log.Println("v_id_doc:", v_id_doc, "o_id_doc:", o_id_doc, "co_id_doc:", co_id_doc, "aco_id_doc_title:", aco_id_doc_title)

	for i, sent := range doc.Sents {

		co_id_sent, err := makeConsistsNumber(conn, sent.Sent, doc.Inds[i], i+1,
			co_id_doc, c_id_sent, rc_id_doc_sent, arc_id_sent_number)
		if err != nil {
			return err
		}

		err = makeIs(conn, strings.Join(sent.Tags, " "), c_id_pattern, co_id_sent, rc_id_sent_pattern)
		if err != nil {
			return err
		}

		for j, tok := range sent.Toks {

			co_id_tok, err := makeConsistsNumber(conn, tok, sent.Inds[j], j+1,
				co_id_sent, c_id_tok, rc_id_sent_tok, arc_id_tok_number)
			if err != nil {
				return err
			}

			err = makeIs(conn, sent.Tags[j], c_id_tag, co_id_tok, rc_id_tok_tag)
			if err != nil {
				return err
			}

		}

		log.Println(i, co_id_sent, sent)

	}

	return
}

func makeIs(conn *sqlx.DB, val_to string, c_id_to uint64, co_id_from uint64, rc_id uint64) (err error) {
	v_id_to, err := makeV(conn, typeOf(val_to), val_to)
	if err != nil {
		return
	}

	o_id_to, err := makeO(conn, v_id_to)
	if err != nil {
		return
	}

	co_id_to, err := makeCO(conn, c_id_to, o_id_to)
	if err != nil {
		return
	}

	_, err = makeRCO(conn, rc_id, co_id_from, co_id_to, 0)
	if err != nil {
		return
	}

	return
}

func makeConsistsNumber(conn *sqlx.DB, val string, ind uint64, num int,
	co_id_parent uint64, c_id_child uint64, rc_id uint64, arc_id uint64) (co_id_child uint64, err error) {

	v_id_child, err := makeV(conn, typeOf(val), val)
	if err != nil {
		return
	}

	o_id_child, err := makeO(conn, v_id_child)
	if err != nil {
		return
	}

	co_id_child, err = makeCO(conn, c_id_child, o_id_child)
	if err != nil {
		return
	}

	rco_id, err := makeRCO(conn, rc_id, co_id_parent, co_id_child, ind)
	if err != nil {
		return
	}

	v_id_number, err := makeV(conn, INT, fmt.Sprintf("%d", num))
	if err != nil {
		return
	}

	_, err = makeARCO(conn, rco_id, arc_id, v_id_number)
	if err != nil {
		return
	}
	return
}

func initModel(conn *sqlx.DB) (err error) {

	for k := range modelV {
		vid, err := makeV(conn, typeOf(k), k)
		if err != nil {
			return err
		}
		modelV[k] = vid
	}

	for k := range modelC {
		vid, ok := modelV[k]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k)
		}
		cid, err := makeC(conn, vid)
		if err != nil {
			return err
		}
		modelC[k] = cid
	}

	for k := range modelR {
		vid, ok := modelV[k]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k)
		}
		rid, err := makeR(conn, vid)
		if err != nil {
			return err
		}
		modelR[k] = rid
	}

	for k := range modelRC {

		rid, ok := modelR[k[0]]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k[0])
		}
		cfid, ok := modelC[k[1]]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k[1])
		}
		ctid, ok := modelC[k[2]]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k[2])
		}

		rcid, err := makeRC(conn, rid, cfid, ctid)
		if err != nil {
			return err
		}
		modelRC[k] = rcid
	}

	for k := range modelA {
		vid, ok := modelV[k]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k)
		}
		aid, err := makeA(conn, vid)
		if err != nil {
			return err
		}
		modelA[k] = aid
	}

	for k := range modelAC {

		cid, ok := modelC[k[0]]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k[0])
		}
		aid, ok := modelA[k[1]]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k[1])
		}
		vid, ok := modelV[k[2]]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k[2])
		}

		acid, err := makeAC(conn, cid, aid, vid)
		if err != nil {
			return err
		}
		modelAC[k] = acid
	}

	for k := range modelAR {

		rid, ok := modelR[k[0]]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k[0])
		}
		aid, ok := modelA[k[1]]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k[1])
		}
		vid, ok := modelV[k[2]]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k[2])
		}

		arid, err := makeAR(conn, rid, aid, vid)
		if err != nil {
			return err
		}
		modelAR[k] = arid
	}

	for k := range modelARC {

		rcid, ok := modelRC[[3]string{k[0], k[1], k[2]}]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", [3]string{k[0], k[1], k[2]})
		}
		arid, ok := modelAR[[3]string{k[0], k[3], k[4]}]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", [3]string{k[0], k[3], k[4]})
		}
		vid, ok := modelV[k[4]]
		if !ok {
			return fmt.Errorf("initModel: %s is missing", k[4])
		}

		arcid, err := makeARC(conn, rcid, arid, vid)
		if err != nil {
			return err
		}
		modelARC[k] = arcid
	}

	return
}

func typeOf(val string) uint8 {
	if _, err := strconv.Atoi(val); err == nil {
		return INT
	}
	return TEXT
}
