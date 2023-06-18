package lib

import (
	"fmt"
	"log"
	"strconv"

	"github.com/jmoiron/sqlx"
)

var modelV = map[string]uint64{
	"document": 0,
	"sentence": 0,
	"token":    0,
	"consists": 0,
	"number":   0,
	"0":        0,
	"title":    0,
	"_":        0,
}

var modelC = map[string]uint64{
	"document": 0,
	"sentence": 0,
	"token":    0,
}

var modelR = map[string]uint64{
	"consists": 0,
}

var modelRC = map[[3]string]uint64{
	{"consists", "document", "sentence"}: 0,
	{"consists", "sentence", "token"}:    0,
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

	v_id_doc, err := makeV(conn, TEXT, doc.Name)
	if err != nil {
		//log.Println("uploadDocument error:", err)
		return
	}

	log.Println("v_id_doc:", v_id_doc)

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
