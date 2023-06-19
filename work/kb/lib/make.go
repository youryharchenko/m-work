package lib

import (
	"github.com/jmoiron/sqlx"
)

const (
	TEXT uint8 = iota
	INT
)

func makeV(conn *sqlx.DB, t uint8, val string) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_v(?, ?, ?)", t, val, &id)
	v := new(V)
	err = row.StructScan(v)
	if err != nil {
		return
	}
	//log.Println(v)
	id = v.ID
	return
}

func makeC(conn *sqlx.DB, v uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_c(?, ?)", v, &id)
	c := new(C)
	err = row.StructScan(c)
	if err != nil {
		return
	}
	//log.Println(v)
	id = c.ID
	return
}

func makeO(conn *sqlx.DB, v uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_o(?, ?)", v, &id)
	o := new(O)
	err = row.StructScan(o)
	if err != nil {
		return
	}
	//log.Println(v)
	id = o.ID
	return
}

func makeCO(conn *sqlx.DB, c uint64, o uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_co(?, ?, ?)", c, o, &id)
	co := new(CO)
	err = row.StructScan(co)
	if err != nil {
		return
	}
	//log.Println(v)
	id = co.ID
	return
}

func makeR(conn *sqlx.DB, v uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_r(?, ?)", v, &id)
	r := new(R)
	err = row.StructScan(r)
	if err != nil {
		return
	}
	//log.Println(v)
	id = r.ID
	return
}

func makeRC(conn *sqlx.DB, r uint64, cf uint64, ct uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_rc(?, ?, ?, ?)", r, cf, ct, &id)
	rc := new(RC)
	err = row.StructScan(rc)
	if err != nil {
		return
	}
	//log.Println(v)
	id = rc.ID
	return
}

func makeRCO(conn *sqlx.DB, rc uint64, cof uint64, cot uint64, i uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_rco(?, ?, ?, ?, ?)", rc, cof, cot, i, &id)
	rco := new(RCO)
	err = row.StructScan(rco)
	if err != nil {
		return
	}
	//log.Println(v)
	id = rco.ID
	return
}

func makeA(conn *sqlx.DB, v uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_a(?, ?)", v, &id)
	a := new(A)
	err = row.StructScan(a)
	if err != nil {
		return
	}
	//log.Println(v)
	id = a.ID
	return
}

func makeAC(conn *sqlx.DB, c uint64, a uint64, v uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_ac(?, ?, ?, ?)", c, a, v, &id)
	ac := new(AC)
	err = row.StructScan(ac)
	if err != nil {
		return
	}
	//log.Println(v)
	id = ac.ID
	return
}

func makeACO(conn *sqlx.DB, co uint64, ac uint64, v uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_aco(?, ?, ?, ?)", co, ac, v, &id)
	aco := new(ACO)
	err = row.StructScan(aco)
	if err != nil {
		return
	}
	//log.Println(v)
	id = aco.ID
	return
}

func makeAR(conn *sqlx.DB, r uint64, a uint64, v uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_ar(?, ?, ?, ?)", r, a, v, &id)
	ar := new(AR)
	err = row.StructScan(ar)
	if err != nil {
		return
	}
	//log.Println(v)
	id = ar.ID
	return
}

func makeARC(conn *sqlx.DB, rc uint64, ar uint64, v uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_arc(?, ?, ?, ?)", rc, ar, v, &id)
	arc := new(ARC)
	err = row.StructScan(arc)
	if err != nil {
		return
	}
	//log.Println(v)
	id = arc.ID
	return
}

func makeARCO(conn *sqlx.DB, rco uint64, arc uint64, v uint64) (id uint64, err error) {
	row := conn.QueryRowx("CALL make_arco(?, ?, ?, ?)", rco, arc, v, &id)
	arco := new(ARCO)
	err = row.StructScan(arco)
	if err != nil {
		return
	}
	//log.Println(v)
	id = arco.ID
	return
}
