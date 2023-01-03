
using DuckDB

tables = [
	(drop = true, create = true, file = "sql/create_V.sql", name = "V"),
	(drop = true, create = true, file = "sql/create_C.sql", name = "C"),
	(drop = true, create = true, file = "sql/create_R.sql", name = "R"),
	(drop = true, create = true, file = "sql/create_A.sql", name = "A"),
	(drop = true, create = true, file = "sql/create_RC.sql", name = "RC"),
	(drop = true, create = true, file = "sql/create_AC.sql", name = "AC"),
	(drop = true, create = true, file = "sql/create_AR.sql", name = "AR"),
	(drop = true, create = true, file = "sql/create_ARC.sql", name = "ARC"),
	(drop = true, create = true, file = "sql/create_O.sql", name = "O"),
	(drop = true, create = true, file = "sql/create_CO.sql", name = "CO"),
	(drop = true, create = true, file = "sql/create_ACO.sql", name = "ACO"),
	(drop = true, create = true, file = "sql/create_RCO.sql", name = "RCO"),
	(drop = true, create = true, file = "sql/create_ARCO.sql", name = "ARCO"),
]

function create_kb(file)
    db = DuckDB.open(file)
    
    drop_kb(db)
    create_seq(db)
    for t in tables
        create_table(db, t)
    end
    db
end

function save(db, dir)
	ts = ["ARCO","RCO","ACO","CO","O","ARC","AR","AC","RC","V","A","R","C"]
	rm(dir; force=true, recursive=true)
	d = mkpath(dir)
	for t in ts
		DuckDB.execute(db, "COPY (SELECT * FROM $t) TO '$d/$t.parquet' (FORMAT 'parquet')")
	end
	d
end

function load(dir)
	ts = ["V","A","R","C","RC","O","CO","RCO","AR","AC","ARC","ACO","ARCO"]
	db = create_kb(":memory:")
	for t in ts
		DuckDB.execute(db, "INSERT INTO $t SELECT * FROM read_parquet('$dir/$t.parquet')")
	end
	db
end

function create_seq(db)
	ts = ["ARCO","RCO","ACO","CO","O","ARC","AR","AC","RC","V","A","R","C"]
	for t in ts
		DuckDB.execute(db, "CREATE SEQUENCE IF NOT EXISTS SEQ_$t;")
	end
end

function drop_kb(db)
	ts = ["ARCO","RCO","ACO","CO","O","ARC","AR","AC","RC","V","A","R","C"]
	for t in ts
		DuckDB.execute(db, "DROP TABLE IF EXISTS $t;")
	end
	for t in ts
		DuckDB.execute(db, "DROP SEQUENCE IF EXISTS SEQ_$t;")
	end
end

function create_table(db, t)
	if t.drop
		sql = "DROP TABLE IF EXISTS $(t.name);"
		r = DuckDB.execute(db, sql)
	end
	if t.create
		sql = read(t.file, String)
		r = DuckDB.execute(db, sql)
	end
end