using DuckDB, DataFrames

function select_co(db, cname)
	sql = """
    SELECT
        C.id as cid,
        (SELECT value FROM V WHERE V.id = C.v) as cname,
        O.id as oid,
        (SELECT value FROM V WHERE V.id = O.v) as oname,
    FROM CO, C, O  
    WHERE CO.c = C.id
        AND CO.o = O.id
        AND C.v = (SELECT id FROM V WHERE value == ?)
    ORDER BY oname
    """
	DataFrame(DuckDB.execute(db, sql, [cname]))
end