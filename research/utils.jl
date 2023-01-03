using DuckDB, DataFrames

sql_select_ids = Dict(
	:A => "SELECT id FROM A WHERE v = ?",
	:C => "SELECT id FROM C WHERE v = ?",
	:V => "SELECT id FROM V WHERE value = ?",
	:AC => "SELECT id FROM AC WHERE c = ? AND a = ?",
	:R => "SELECT id FROM R WHERE v = ?",
	:AR => "SELECT id FROM AR WHERE r = ? AND a = ?",
	:RC => "SELECT id FROM RC WHERE cf = ? AND r = ? AND ct = ?",
	:ARC => "SELECT id FROM ARC WHERE rc = ? AND a = ?",
	:O => "SELECT id FROM O WHERE v = ?",
	:CO => "SELECT id FROM CO WHERE c = ? AND o = ?",
	:ACO => "SELECT id FROM ACO WHERE co = ? AND a = ?",
	:RCO => "SELECT id FROM RCO	WHERE of = ? AND rc = ? AND ot = ?",
	:ARCO => "SELECT id FROM ARCO WHERE rco = ? AND a = ?",
)

sql_inserts = Dict(
	:A => "INSERT INTO A (id, v) VALUES(nextval('SEQ_A'), ?) RETURNING id",
	:C => "INSERT INTO C (id, v) VALUES(nextval('SEQ_C'), ?) RETURNING id",
	:V => "INSERT INTO V (id, value) VALUES(nextval('SEQ_V'), ?) RETURNING id",
	:AC => "INSERT INTO AC (id, c, a, v) VALUES(nextval('SEQ_AC'), ?, ?, ?) RETURNING id",
	:R => "INSERT INTO R (id, v) VALUES(nextval('SEQ_R'), ?) RETURNING id",
	:AR => "INSERT INTO AR (id, r, a, v) VALUES(nextval('SEQ_AR'), ?, ?, ?) RETURNING id",
	:RC => "INSERT INTO RC (id, cf, r, ct) VALUES(nextval('SEQ_RC'), ?, ?, ?) RETURNING id",
	:ARC => "INSERT INTO ARC (id, rc, a, v) VALUES(nextval('SEQ_ARC'), ?, ?, ?) RETURNING id",
	:O => "INSERT INTO O (id, v) VALUES(nextval('SEQ_O'), ?) RETURNING id",
	:CO => "INSERT INTO CO (id, c, o) VALUES(nextval('SEQ_CO'), ?, ?) RETURNING id",
	:ACO => "INSERT INTO ACO (id, co, a, v) VALUES(nextval('SEQ_ACO'), ?, ?, ?) RETURNING id",
	:RCO => "INSERT INTO RCO (id, of, rc, ot) VALUES(nextval('SEQ_RCO'), ?, ?, ?) RETURNING id",
	:ARCO => "INSERT INTO ARCO (id, rco, a, v) VALUES(nextval('SEQ_ARCO'), ?, ?, ?) RETURNING id",
)

function insert(db, table, params)
	#write(log, "*** insert begin\n")
	#write(log, "    table = $table, params = $params\n")
	
	#sql_id = sql_select_ids[table]
	ret = id(db, table, params) 
	
	if ret == -1

		#write(log, "    ret = $ret\n")
			
		sql_ins = sql_inserts[table]
		df = DataFrame(DuckDB.execute(db, sql_ins, params))

		#write(log, "    nrow(df) = $(nrow(df))\n")
		
		if table in [:A, :C, :R, :O, :AC, :AR, :ARC, :ACO, :ARCO]

			vc = value_count!(db, params[end])
			
			#write(log, "         value_count! = $vc\n")
			
		end
		ret = nrow(df) == 0 ? -1 : df[1, :id]
	end
	
	#write(log, "    ret = $ret\n")
	#write(log, "*** insert end\n")
	ret
end

function id(kb, table, params)
	sql_id = sql_select_ids[table]
	
	df_id = DataFrame(DuckDB.execute(kb, sql_id, 
		table in [:AC, :AR, :ARC, :ACO, :ARCO] ? params[1:end-1] : params))
	
	ret = nrow(df_id) == 0 ? -1 : df_id[1, :id]
end

function value_count!(db, param)
	sql_upd = "UPDATE V SET count = count + 1 WHERE id = ?"
	df = DataFrame(DuckDB.execute(db, sql_upd, [param]))
	param
end

function count_rco_from(db, rc, ot)
	sql = "SELECT count(id) as cnt FROM RCO WHERE rc = ? AND ot = ?"
	df = DataFrame(DuckDB.execute(db, sql, [rc, ot]))
	ret = nrow(df) == 0 ? -1 : df[1, :cnt]
end