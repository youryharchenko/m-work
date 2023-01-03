### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ a93b7ea6-89aa-11ed-0fc7-2b4a8ad2c066
using DuckDB, PlutoUI, TextAnalysis, Languages, DataFrames, Julog, UUIDs

# ╔═╡ e87665ee-d7a0-4747-941f-123d3c01300d


# ╔═╡ 60960960-0375-40fd-8998-73f36e46ed7c
function result(r, cols)
	if r[1]
		(:yes, DataFrames.select(DataFrame([NamedTuple(zip(Symbol.(keys(d)), collect(values(d)))) for d in r[2]]), cols))
	else
		:no
	end
end

# ╔═╡ 030d2a17-5e2f-40a6-a70c-3ddd2a5a4aa7
function result(r)
	if r[1]
		(:yes, DataFrame([NamedTuple(zip(Symbol.(keys(d)), collect(values(d)))) for d in r[2]]))
	else
		:no
	end
end

# ╔═╡ 3d149bd9-8777-4916-83ce-1f84e8e99cf9
function select(db, table)
	DataFrame(DuckDB.execute(db, "SELECT * FROM $table"))
end

# ╔═╡ 8e99d3e9-82b6-4fac-9833-8b9330ecb3f3
function table2clauses(db, t)
	df = select(db, t)
	clauses = Vector{Julog.Clause}(undef, nrow(df))
	
	i = 0
	for r in eachrow(df)
		i+=1
		clauses[i] = Clause(
			Compound(t, [Const(x) for x in r]), [])
	end
	clauses
end

# ╔═╡ c9a5a3bd-2346-4d16-8d29-b311cfe9de57
rules = @julog [
	Attr(ID, Name) <<= A(ID, V) & V(V, Name, _),
	Cat(ID, Name) <<= C(ID, V) & V(V, Name, _),
	Rel(ID, Name) <<= R(ID, V) & V(V, Name, _),
	Obj(ID, Name) <<= O(ID, _, V) & V(V, Name, _),
	
	CatObj(ID, CatID, ObjID, CatName, ObjName) <<= 
		CO(ID, CatID, ObjID,) & Cat(CatID, CatName) & Obj(ObjID, ObjName),
	
	RelCat(ID, RelID, CatFromID, CatToID, RelName, CatFromName, CatToName) <<= 
		RC(ID, RelID, CatFromID, CatToID) & Rel(RelID, RelName) & Cat(CatFromID, CatFromName) & Cat(CatToID, CatToName),
	
	RelCatObj(ID, RelCatID, RelID, CatFromID, ObjFromID, CatToID, ObjToID, RelName, 	CatFromName, ObjFromName, CatToName, ObjToName) <<= 
		RCO(ID, RelCatID, ObjFromID, ObjToID) & RelCat(RelCatID, RelID, CatFromID, CatToID, RelName, CatFromName, CatToName) & Obj(ObjFromID, ObjFromName) & Obj(ObjToID, ObjToName),

	AttrCat(ID, CatID, AttrID, ValueID, CatName, AttrName, Value) <<= 
		AC(ID, CatID, AttrID, ValueID) & Attr(AttrID, AttrName) & Cat(CatID, CatName) & V(ValueID, Value, _),

	AttrCatObj(ID, CatObjID, CatID, ObjID, AttrID, ValueID, CatName, ObjName, AttrName, Value) <<= 
		ACO(ID, CatObjID, AttrID, ValueID) & CatObj(CatObjID, CatID, ObjID, CatName, ObjName) & Attr(AttrID, AttrName) & Cat(CatID, CatName) & V(ValueID, Value, _),

	AttrRel(ID, RelID, AttrID, ValueID, RelName, AttrName, Value) <<= 
		AR(ID, RelID, AttrID, ValueID) & Attr(AttrID, AttrName) & Rel(RelID, CatName) & V(ValueID, Value, _),

	AttrRelCat(ID, RelCatID, RelID, CatFromID, CatToID, AttrID, ValueID, RelName, CatFromName, CatToName, AttrName, Value) <<= 
		ARC(ID, RelCatID, AttrID, ValueID) & RelCat(RelCatID, RelID, CatFromID, CatToID, RelName, CatFromName, CatToName)  & Attr(AttrID, AttrName) & V(ValueID, Value, _),

	AttrRelCatObj(ID, RelCatObjID, RelID, CatFromID, ObjFromID, CatToID, ObjToID, AttrID, ValueID, RelName, CatFromName, ObjFromName, CatToName, ObjToName, AttrName, Value) <<= 
		ARCO(ID, RelCatObjID, AttrID, ValueID) & RelCatObj(RelCatObjID, RelCatID, RelID, CatFromID, ObjFromID, CatToID, ObjToID, RelName, CatFromName, ObjFromName, CatToName, ObjToName)  & Attr(AttrID, AttrName) & V(ValueID, Value, _),

	InvValue(ValueID, Value, Count, ID, a, name) <<= V(ValueID, Value, Count) & A(ID, ValueID),
	InvValue(ValueID, Value, Count, ID, c, name) <<= V(ValueID, Value, Count) & C(ID, ValueID),
	InvValue(ValueID, Value, Count, ID, r, name) <<= V(ValueID, Value, Count) & R(ID, ValueID),
	InvValue(ValueID, Value, Count, ID, o, name) <<= V(ValueID, Value, Count) & O(ID, _, ValueID),
	InvValue(ValueID, Value, Count, ID, ac, AttrName) <<= V(ValueID, Value, Count) & AC(ID, _, AttrID, ValueID) & Attr(AttrID, AttrName),
	InvValue(ValueID, Value, Count, ID, ar, AttrName) <<= V(ValueID, Value, Count) & AR(ID, _, AttrID, ValueID) & Attr(AttrID, AttrName),
	InvValue(ValueID, Value, Count, ID, aco, AttrName) <<= V(ValueID, Value, Count) & ACO(ID, _, AttrID, ValueID) & Attr(AttrID, AttrName),
	InvValue(ValueID, Value, Count, ID, arc, AttrName) <<= V(ValueID, Value, Count) & ARC(ID, _, AttrID, ValueID) & Attr(AttrID, AttrName),
	InvValue(ValueID, Value, Count, ID, arco, AttrName) <<= V(ValueID, Value, Count) & ARCO(ID, _, AttrID, ValueID) & Attr(AttrID, AttrName),
	
]

# ╔═╡ 452fe33c-8f1e-4107-a6d6-c79b82f93532
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

# ╔═╡ dbe990ac-b8ea-4954-80b8-9722b85f206f
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

# ╔═╡ a63cfb47-bdf0-41e5-813b-8d86e3a3c880
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

# ╔═╡ 962905ef-dddb-498b-bffa-0d8900bed8e6
function create_table(db, t)
	o = ""
	if t.drop
		sql = "DROP TABLE IF EXISTS $(t.name);"
		r = DuckDB.execute(db, sql)
		o = o * "executed:\n$sql\nresult: $r\n"
	end
	if t.create
		sql = read(t.file, String)
		r = DuckDB.execute(db, sql)
		o = o * "executed:\n$sql\nresult: $r\n"
	end
	o == "" ? "table: $t.name - nothing executed\n" : o
end

# ╔═╡ d33a5c73-af83-457d-addf-79c2d3777f7f
function drop_kb(db)
	ts = ["ARCO","RCO","ACO","CO","O","ARC","AR","AC","RC","V","A","R","C"]
	for t in ts
		DuckDB.execute(db, "DROP TABLE IF EXISTS $t;")
	end
	for t in ts
		DuckDB.execute(db, "DROP SEQUENCE IF EXISTS SEQ_$t;")
	end
end

# ╔═╡ 290e1c7e-71e3-450f-899e-22b194774dd0
function create_seq(db)
	ts = ["ARCO","RCO","ACO","CO","O","ARC","AR","AC","RC","V","A","R","C"]
	for t in ts
		DuckDB.execute(db, "CREATE SEQUENCE IF NOT EXISTS SEQ_$t;")
	end
end

# ╔═╡ caac65aa-87e4-4182-b2b9-8a37de43334f
function create_kb(ts, file)
	db = DuckDB.open(file)
	out = ""
	drop_kb(db)
	create_seq(db)
	for t in ts
		out = out * create_table(db, t)
	end
	(db, Text(out))
end

# ╔═╡ 4dfe6fc2-2e72-4f99-b407-b4983815fa3c
function save(db, dir)
	ts = ["ARCO","RCO","ACO","CO","O","ARC","AR","AC","RC","V","A","R","C"]
	rm(dir; force=true, recursive=true)
	d = mkpath(dir)
	for t in ts
		DuckDB.execute(db, "COPY (SELECT * FROM $t) TO '$d/$t.parquet' (FORMAT 'parquet')")
	end
	d
end

# ╔═╡ 12581db0-b24f-4d42-811f-9301cc51ca8d
function load(dir, tables)
	ts = ["V","A","R","C","RC","O","CO","RCO","AR","AC","ARC","ACO","ARCO"]
	db, _ = create_kb(tables, ":memory:")
	for t in ts
		DuckDB.execute(db, "INSERT INTO $t SELECT * FROM read_parquet('$dir/$t.parquet')")
	end
	db
end

# ╔═╡ d14ecba6-c8ee-4e94-809a-194c9120ebc0
function id(kb, table, params)
	sql_id = sql_select_ids[table]
	
	df_id = DataFrame(DuckDB.execute(kb, sql_id, 
		table in [:AC, :AR, :ARC, :ACO, :ARCO] ? params[1:end-1] : params))
	
	ret = nrow(df_id) == 0 ? -1 : df_id[1, :id]
end

# ╔═╡ 19be8fe7-be79-47ac-b7c4-0262bea611e3
function value_count!(db, param)
	sql_upd = "UPDATE V SET count = count + 1 WHERE id = ?"
	df = DataFrame(DuckDB.execute(db, sql_upd, [param]))
	param
end

# ╔═╡ 962eec34-bb4a-4fe8-aadb-201b787b2925
function count_rco_from(db, rc, ot)
	sql = "SELECT count(id) as cnt FROM RCO WHERE rc = ? AND ot = ?"
	df = DataFrame(DuckDB.execute(db, sql, [rc, ot]))
	ret = nrow(df) == 0 ? -1 : df[1, :cnt]
end

# ╔═╡ a3f9f94b-4c51-478e-bf36-7916876c5f7b
#log = open("log.txt", "w")

# ╔═╡ b5831412-d23e-41f5-bb2d-300ffef30611
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

# ╔═╡ 8371c9e9-1484-4fef-9a73-a6202ec01cc0
function document(file, lang)
	l = StringDocument(text(FileDocument(file)))
	TextAnalysis.remove_whitespace!(l)
	sents = TextAnalysis.sentence_tokenize(lang, TextAnalysis.text(l))
	crps = Corpus([StringDocument(String(s)) for s in sents])
	languages!(crps, lang)
	remove_case!(crps)
	sent_lcase = [TextAnalysis.text(d) for d in crps]
	prepare!(crps, strip_punctuation | strip_numbers)
	#remove_words!(crps, ["на","і","що","в","до","не","для"])
	update_lexicon!(crps)
	#lex = lexicon(crps)
	update_inverse_index!(crps)
	inverse_index(crps)
	(sent_lcase, crps)
end

# ╔═╡ b059d1b6-4bd2-439c-84e0-5e0b130fe0bf
function proc_doc!(kb, file)

	# log = open("log.txt", "w")

	sent_lcase, crps = document(file, Languages.English())
		
	v_nothing = insert(kb, :V, ["nothing"])
	v_author1 = insert(kb, :V, ["Russell, Stuart; Norvig, Peter"])
	v_doc1 = insert(kb, :V, ["Preface To Artificial Intelligence: A Modern Approach"])

	v_c_doc = insert(kb, :V, ["Document"])
	v_c_author = insert(kb, :V, ["Author"])
	v_c_sentence = insert(kb, :V, ["Sentence"])
	v_c_sentence_inst = insert(kb, :V, ["SentenceInst"])
	v_c_word = insert(kb, :V, ["Word"])
	v_c_word_inst = insert(kb, :V, ["WordInst"])


	v_a_title = insert(kb, :V, ["Title"])
	v_a_name = insert(kb, :V, ["Name"])
	v_a_number = insert(kb, :V, ["Number"])

	v_r_is_author = insert(kb, :V, ["is a author"])
	v_r_has_parts = insert(kb, :V, ["has parts"])
	v_r_inst_of = insert(kb, :V, ["inst of"])

	# select_all(kb, :V)
	
	insert(kb, :C, [v_c_doc])
	insert(kb, :C, [v_c_author])
	insert(kb, :C, [v_c_sentence])
	insert(kb, :C, [v_c_sentence_inst])
	insert(kb, :C, [v_c_word])
	insert(kb, :C, [v_c_word_inst])
	
	# select_all(kb, :C)

	insert(kb, :A, [v_a_title])
	insert(kb, :A, [v_a_name])
	insert(kb, :A, [v_a_number])
	
	# select_all(kb, :A)

	

	insert(kb, :AC, [id(kb, :C, [v_c_author]), id(kb, :A, [v_a_name]), v_nothing])
	insert(kb, :AC, [id(kb, :C, [v_c_doc]), id(kb, :A, [v_a_title]), v_nothing])
	

	# select_all(kb, :AC)

	insert(kb, :R, [v_r_is_author])
	insert(kb, :R, [v_r_has_parts])
	insert(kb, :R, [v_r_inst_of])
		
	# select_all(kb, :R)

	insert(kb, :AR, [id(kb, :R, [v_r_has_parts]), id(kb, :A, [v_a_number]), v_nothing])
	
	# select_all(kb, :AR)

	insert(kb, :RC, [id(kb, :C, [v_c_author]), id(kb, :R, [v_r_is_author]), id(kb, :C, [v_c_doc])])
	
	rc1 = insert(kb, :RC, [id(kb, :C, [v_c_doc]), id(kb, :R, [v_r_has_parts]), id(kb, :C, [v_c_sentence_inst])])
	rc2 = insert(kb, :RC, [id(kb, :C, [v_c_sentence]), id(kb, :R, [v_r_has_parts]), id(kb, :C, [v_c_word_inst])])
	rc3 = insert(kb, :RC, [id(kb, :C, [v_c_sentence_inst]), id(kb, :R, [v_r_inst_of]), id(kb, :C, [v_c_sentence])])
	rc4 = insert(kb, :RC, [id(kb, :C, [v_c_word_inst]), id(kb, :R, [v_r_inst_of]), id(kb, :C, [v_c_word])])

	# select_all(kb, :RC)

	insert(kb, :ARC, [rc1, id(kb, :A, [v_a_number]), v_nothing])
	insert(kb, :ARC, [rc2, id(kb, :A, [v_a_number]), v_nothing])
	
	# select_all(kb, :ARC)

	insert(kb, :O, [v_author1])
	insert(kb, :O, [v_doc1])
		
	co1 = insert(kb, :CO, [id(kb, :C, [v_c_author]), id(kb, :O, [v_author1])])
	co2 = insert(kb, :CO, [id(kb, :C, [v_c_doc]), id(kb, :O, [v_doc1])])
		
	# filter(r -> r.c in [id(kb, :C, ["Автор"]), id(kb, :C, ["Документ"])], select_all(kb, :CO))

	insert(kb, :ACO, [co1, id(kb, :A, [v_a_name]), v_author1])
	insert(kb, :ACO, [co2, id(kb, :A, [v_a_title]), v_doc1])

	c = id(kb, :C, [v_c_sentence])
	
	for s in sent_lcase
		o = insert(kb, :O, [insert(kb, :V, [s])])
		if o > 0
			insert(kb, :CO, [c, o])	
		end
	end
		
	# filter(r -> r.c == c, select_all(kb, :CO))

	c = id(kb, :C, [v_c_word])
	
	for s in keys(lexicon(crps))
		o = insert(kb, :O, [insert(kb, :V, [s])])
		if o > 0
			insert(kb, :CO, [c, o])	
		end
	end
		
	# filter(r -> r.c == c, select_all(kb, :CO))

	r = id(kb, :R, [v_r_has_parts])
	rp = id(kb, :R, [v_r_inst_of])

	cf = id(kb, :C, [v_c_doc])
	ct = id(kb, :C, [v_c_sentence_inst])
	cp = id(kb, :C, [v_c_sentence])

	rc = id(kb, :RC, [cf, r, ct])
	rcp = id(kb, :RC, [ct, rp, cp])
	
	of = id(kb, :O, [v_doc1])

	a = id(kb, :A, [v_a_number])
		
	for i in eachindex(sent_lcase)
		v_sent = insert(kb, :V, [sent_lcase[i]])
		ot_p = insert(kb, :O, [v_sent])
		k = count_rco_from(kb, rcp, ot_p)
		v_sent_inst = insert(kb, :V, ["rc$rcp:ot$ot_p:$(k+1)"])
		ot = insert(kb, :O, [v_sent_inst])
		insert(kb, :RCO, [ot, rcp, ot_p])
		
		rco = insert(kb, :RCO, [of, rc, ot])
		v_i = insert(kb, :V, ["$i"])
		arco = insert(kb, :ARCO, [rco, a, v_i])
	end
		
	# filter(r -> r.rc == rc, select_all(kb, :RCO))
	# select_all(kb, :ARCO)
	# DuckDB.execute(kb, "EXPORT DATABASE 'semantic.duckdb'")
	#close(log)
	kb
end

# ╔═╡ d204293b-aa77-447a-8018-d3cb7ee866ad
db = let
	kb, _ = create_kb(tables, ":memory:")
	proc_doc!(kb, """Russell, Stuart; Norvig, Peter. "Preface To Artificial Intelligence: A Modern Approach".txt""")
	save(kb, "save")
	load("save", tables)
end

# ╔═╡ 673652c7-9045-4970-8254-b86e5652ff0e
clauses = let 
	ts = [:V, :A, :C, :R, :RC, :O, :CO, :RCO, :AC, :AR, :ARC, :ACO, :ARCO]
	cl = Clause[]
	for t in ts
		cl = vcat(cl, table2clauses(db, t))
	end
	cl
end 

# ╔═╡ c616ab08-0f9e-4ef1-9fa4-1a5f3a194d1b
kb = vcat(clauses, rules)

# ╔═╡ 1984b586-1c48-4606-85a6-b4f3d7a577b8
result(
	resolve(@julog([V(ValueID, Value, Count), Count == 0]), kb), 
	[:ValueID, :Value, :Count]
)

# ╔═╡ 89609488-e619-4a4d-a015-56124f360692
result(
	resolve(@julog([ARCO(ID, RelCatObjID, AttrID, ValueID), RelCatObj(RelCatObjID, RelCatID, RelID, CatFromID, ObjFromID, CatToID, ObjToID, RelName, CatFromName, ObjFromName, CatToName, ObjToName), Attr(AttrID, AttrName), V(ValueID, Value, Count), Count == 0]), kb), 
	[:Value, :RelName, :ObjFromName, :ObjToName, :AttrName, :Count]
) 

# ╔═╡ 15cb0397-a8b9-4f87-9c60-faaac11bca69
resolve(@julog([ARCO(ID, RelCatObjID, AttrID, ValueID), RelCatObj(RelCatObjID, RelCatID, RelID, CatFromID, ObjFromID, CatToID, ObjToID, RelName, CatFromName, ObjFromName, CatToName, ObjToName), Attr(AttrID, AttrName), V(ValueID, Value, Count), Count >= 0]), kb)

# ╔═╡ 447cd259-da17-44ed-af51-ed0c7208b3ab
resolve(@julog([ARC(ID, RelCatID, AttrID, ValueID), RelCat(RelCatID, RelID, CatFromID, CatToID, RelName, CatFromName, CatToName), Attr(AttrID, AttrName), V(ValueID, Value, Count), Count == 0]), kb)

# ╔═╡ f8f56753-199f-4388-90fe-a59f2bc40961
resolve(@julog([ACO(ID, CatObjID, AttrID, ValueID), CatObj(CatObjID, CatID, ObjID, CatName, ObjName), Attr(AttrID, AttrName), Cat(CatID, CatName), V(ValueID, Value, Count), Count >= 0]), kb)

# ╔═╡ 1552bfed-3e19-4efe-b26a-13b387b9de45
resolve(@julog([O(ID, _, ValueID), V(ValueID, Value, Count), Count >= 1]), kb)

# ╔═╡ 15e4848d-0554-4efc-93f6-365581d48ff7
resolve(@julog([AttrRelCatObj(ID, RelCatObjID, RelID, CatFromID, ObjFromID, CatToID, ObjToID, AttrID, ValueID, RelName, CatFromName, ObjFromName, CatToName, ObjToName, AttrName, "100")]), kb)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DuckDB = "d2f5444f-75bc-4fdf-ac35-56f514c445e1"
Julog = "5d8bcb5e-2b2c-4a96-a2b1-d40b3d3c344f"
Languages = "8ef0a80b-9436-5d2c-a485-80b904378c43"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
TextAnalysis = "a2db99b7-8b79-58f8-94bf-bbc811eef33d"
UUIDs = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[compat]
DataFrames = "~1.4.4"
DuckDB = "~0.6.0"
Julog = "~0.1.15"
Languages = "~0.4.3"
PlutoUI = "~0.7.49"
TextAnalysis = "~0.7.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "f04169718081d46721ec4aacd88ad471549d3357"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DBInterface]]
git-tree-sha1 = "9b0dc525a052b9269ccc5f7f04d5b3639c65bca5"
uuid = "a10d1c49-ce27-4219-8d33-6db1a4562965"
version = "2.5.0"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataDeps]]
deps = ["HTTP", "Libdl", "Reexport", "SHA", "p7zip_jll"]
git-tree-sha1 = "bc0a264d3e7b3eeb0b6fc9f6481f970697f29805"
uuid = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
version = "0.7.10"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d4f69885afa5e6149d0cab3818491565cf41446d"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.4"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DuckDB]]
deps = ["DBInterface", "DataFrames", "Dates", "DuckDB_jll", "FixedPointDecimals", "Tables", "UUIDs", "WeakRefStrings"]
git-tree-sha1 = "ed4444e2cb653fef6f4d50bed5b942caefc6a4c0"
uuid = "d2f5444f-75bc-4fdf-ac35-56f514c445e1"
version = "0.6.0"

[[deps.DuckDB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c8c21439116b0ed6b6640db22b7e782d0447cd5"
uuid = "2cbbab25-fc8b-58cf-88d4-687a02676033"
version = "0.6.1+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointDecimals]]
git-tree-sha1 = "9056462184023d22fdfc40f8b70b274f3a42c898"
uuid = "fb4d412d-6eee-574d-9565-ede6634db7b0"
version = "0.4.1"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.HTML_Entities]]
deps = ["StrTables"]
git-tree-sha1 = "c4144ed3bc5f67f595622ad03c0e39fa6c70ccc7"
uuid = "7693890a-d069-55fe-a829-b4a6d304f0ee"
version = "1.0.1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "2e13c9956c82f5ae8cbdb8335327e63badb8c4ff"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.6.2"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "0cf92ec945125946352f3d46c96976ab972bde6f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.3.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.Julog]]
git-tree-sha1 = "191e4f6de2ddf2dc60d5d90c412d066814f1655b"
uuid = "5d8bcb5e-2b2c-4a96-a2b1-d40b3d3c344f"
version = "0.1.15"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Languages]]
deps = ["InteractiveUtils", "JSON"]
git-tree-sha1 = "b1a564061268ccc3f3397ac0982983a657d4dcb8"
uuid = "8ef0a80b-9436-5d2c-a485-80b904378c43"
version = "0.4.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "df6830e37943c7aaa10023471ca47fb3065cc3c4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.2"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "6466e524967496866901a78fca3f2e9ea445a559"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "96f6db03ab535bdb901300f88335257b0018689d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Snowball]]
deps = ["Languages", "Snowball_jll", "WordTokenizers"]
git-tree-sha1 = "d38c1ff8a2fca7b1c65a51457dabebef28052399"
uuid = "fb8f903a-0164-4e73-9ffe-431110250c3b"
version = "0.1.0"

[[deps.Snowball_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ff3a185a583dca7265cbfcaae1da16aa3b6a962"
uuid = "88f46535-a3c0-54f4-998e-4320a1339f51"
version = "2.2.0+0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StrTables]]
deps = ["Dates"]
git-tree-sha1 = "5998faae8c6308acc25c25896562a1e66a3bb038"
uuid = "9700d1a9-a7c8-5760-9816-a99fda30bb8f"
version = "1.0.1"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TextAnalysis]]
deps = ["DataStructures", "DelimitedFiles", "JSON", "Languages", "LinearAlgebra", "Printf", "ProgressMeter", "Random", "Serialization", "Snowball", "SparseArrays", "Statistics", "StatsBase", "Tables", "WordTokenizers"]
git-tree-sha1 = "bc85e54209c30e69e1925460ec0257a916683f59"
uuid = "a2db99b7-8b79-58f8-94bf-bbc811eef33d"
version = "0.7.3"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "e4bdc63f5c6d62e80eb1c0043fcc0360d5950ff7"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.10"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WordTokenizers]]
deps = ["DataDeps", "HTML_Entities", "StrTables", "Unicode"]
git-tree-sha1 = "01dd4068c638da2431269f49a5964bf42ff6c9d2"
uuid = "796a5d58-b03d-544a-977e-18100b691f6e"
version = "0.5.6"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═a93b7ea6-89aa-11ed-0fc7-2b4a8ad2c066
# ╠═d204293b-aa77-447a-8018-d3cb7ee866ad
# ╠═c616ab08-0f9e-4ef1-9fa4-1a5f3a194d1b
# ╠═e87665ee-d7a0-4747-941f-123d3c01300d
# ╠═1984b586-1c48-4606-85a6-b4f3d7a577b8
# ╠═89609488-e619-4a4d-a015-56124f360692
# ╠═15cb0397-a8b9-4f87-9c60-faaac11bca69
# ╠═447cd259-da17-44ed-af51-ed0c7208b3ab
# ╠═f8f56753-199f-4388-90fe-a59f2bc40961
# ╠═1552bfed-3e19-4efe-b26a-13b387b9de45
# ╠═15e4848d-0554-4efc-93f6-365581d48ff7
# ╠═673652c7-9045-4970-8254-b86e5652ff0e
# ╠═60960960-0375-40fd-8998-73f36e46ed7c
# ╠═030d2a17-5e2f-40a6-a70c-3ddd2a5a4aa7
# ╠═3d149bd9-8777-4916-83ce-1f84e8e99cf9
# ╠═8e99d3e9-82b6-4fac-9833-8b9330ecb3f3
# ╠═c9a5a3bd-2346-4d16-8d29-b311cfe9de57
# ╠═452fe33c-8f1e-4107-a6d6-c79b82f93532
# ╠═dbe990ac-b8ea-4954-80b8-9722b85f206f
# ╠═a63cfb47-bdf0-41e5-813b-8d86e3a3c880
# ╠═caac65aa-87e4-4182-b2b9-8a37de43334f
# ╠═962905ef-dddb-498b-bffa-0d8900bed8e6
# ╠═d33a5c73-af83-457d-addf-79c2d3777f7f
# ╠═290e1c7e-71e3-450f-899e-22b194774dd0
# ╠═4dfe6fc2-2e72-4f99-b407-b4983815fa3c
# ╠═12581db0-b24f-4d42-811f-9301cc51ca8d
# ╠═d14ecba6-c8ee-4e94-809a-194c9120ebc0
# ╠═19be8fe7-be79-47ac-b7c4-0262bea611e3
# ╠═962eec34-bb4a-4fe8-aadb-201b787b2925
# ╠═a3f9f94b-4c51-478e-bf36-7916876c5f7b
# ╠═b5831412-d23e-41f5-bb2d-300ffef30611
# ╠═8371c9e9-1484-4fef-9a73-a6202ec01cc0
# ╠═b059d1b6-4bd2-439c-84e0-5e0b130fe0bf
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
