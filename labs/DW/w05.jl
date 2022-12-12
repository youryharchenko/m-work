### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ ebdf79fe-70bb-11ed-1238-eb60f38082ec
using DuckDB, PlutoUI, CommonMark, TextAnalysis, Languages, DataFrames, LibPQ

# ╔═╡ f622df43-b3f5-45f2-99e8-e6c35066fb00
using Dates, Random, Statistics

# ╔═╡ d20e2f26-3cac-4af9-af0b-639cd39479a6
using StatsPlots: plot, plot!, hline!, boxplot

# ╔═╡ d0fd59e4-d83d-4b18-8fd4-9781e171c3da
cm"""
---

<div align="center">

Національний університет біоресурсів і природокористування України

Факультет інформаційних технологій

Кафедра комп'ютерних наук

<br/><br/>

Лабораторна робота 5

Обчислення KPI

</div>

<br/><br/>

<div align="right">

Виконав

Студент групи ІУСТ-22001м

Харченко Юрій

</div>

<br/><br/>
<br/><br/>

<div align="center">

Київ – 2022

</div>

""" 

# ╔═╡ 829d12ee-d4cb-4555-b847-d0fa84b4f103
cm"""
#### В роботі використано мову Julia  [[1](https://julialang.org/)] та її пакети
"""

# ╔═╡ b13070b5-9875-45b6-a74e-1ed0f0c4a5fd
TableOfContents()

# ╔═╡ d29ea611-2224-40b1-9619-21d5a25bac8a
md"""
# Елементи магістерської роботи
"""

# ╔═╡ 53f00c22-7243-448f-bea5-d6e4cf165b90
md"""
## Заповнення сховища даних семантичної мережі
"""

# ╔═╡ ce44520a-ad21-4aa6-86f1-e46ffeed4b31
md"""
#### Створюємо базу даних
"""

# ╔═╡ 54b57fcf-6f4d-4e9f-ac1d-a075a9f74507
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

# ╔═╡ 7910d7c5-0741-4fc2-ab71-a37a4f63e366
file = ":memory:"

# ╔═╡ d052f8bf-fd34-48dc-a19c-d634e74aa2bf
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

# ╔═╡ ae939911-0f8b-429b-9ccb-90828431f5bd
function drop_kb(db)
	ts = ["ARCO","RCO","ACO","CO","O","ARC","AR","AC","RC","V","A","R","C"]
	for t in ts
		DuckDB.execute(db, "DROP TABLE IF EXISTS $t;")
	end
	for t in ts
		DuckDB.execute(db, "DROP SEQUENCE IF EXISTS SEQ_$t;")
	end
end

# ╔═╡ 02e59024-01bd-470a-ae1e-caeeef8c001e
function create_seq(db)
	ts = ["ARCO","RCO","ACO","CO","O","ARC","AR","AC","RC","V","A","R","C"]
	for t in ts
		DuckDB.execute(db, "CREATE SEQUENCE IF NOT EXISTS SEQ_$t;")
	end
end

# ╔═╡ c1409952-da5f-4b80-a28e-a717d3e99fdd
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

# ╔═╡ 11664dc4-89d1-42bd-8640-0ca7e80ca7e5
md"""
#### Завантажуємо документ та робимо попередню обробку тексту
"""

# ╔═╡ 66a41d0b-0734-4699-8a08-287019928cc7
function proc_document(file)
	l = StringDocument(text(FileDocument(file)))
	TextAnalysis.remove_whitespace!(l)
	sents = TextAnalysis.sentence_tokenize(Languages.Ukrainian(), TextAnalysis.text(l))
	crps = Corpus([StringDocument(String(s)) for s in sents])
	languages!(crps, Languages.Ukrainian())
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

# ╔═╡ 25d21a3a-6e90-4561-8eb3-65d606c8ae60
l1_sent_lcase, l1_crps = proc_document("Лекція 1.txt");

# ╔═╡ ac223604-4179-4087-bfd3-dd88e099a115
md"""
#### Словники запитів до бази даних
"""

# ╔═╡ 92f08f94-ab7d-46b6-ab80-e432ee159625
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
	:RCO => "INSERT INTO RCO (id, rc, of, ot) VALUES(nextval('SEQ_RCO'), ?, ?, ?) RETURNING id",
	:ARCO => "INSERT INTO ARCO (id, rco, a, v) VALUES(nextval('SEQ_ARCO'), ?, ?, ?) RETURNING id",
)

# ╔═╡ 6fc3d8d1-5ecb-4522-bbee-e83b5a1a0f4c
sql_selects = Dict(
	:A => "SELECT id, v, (SELECT V.value FROM V WHERE V.id = A.v) as name FROM A",
	:C => "SELECT id, v, (SELECT V.value FROM V WHERE V.id = C.v) as name FROM C",
	:V => "SELECT * FROM V",
	:AC => """SELECT AC.id, AC.c, AC.a, AC.v,
	(SELECT V.value FROM C, V WHERE C.id = AC.c AND V.id = C.v) as c_name,
	(SELECT V.value FROM A, V WHERE A.id = AC.a AND V.id = A.v) as a_name,
	(SELECT value FROM V WHERE V.id = AC.v) as value
	FROM AC
	""",
	:R => "SELECT id, v, (SELECT V.value FROM V WHERE V.id = R.v) as name FROM R",
	:AR => """SELECT AR.id, AR.r, AR.a, AR.v,
	(SELECT V.value FROM R, V WHERE R.id = AR.r AND V.id = R.v) as r_name,
	(SELECT V.value FROM A, V WHERE A.id = AR.a AND V.id = A.v) as a_name,
	(SELECT value FROM V WHERE V.id = AR.v) as value
	FROM AR
	""",
	:RC => """SELECT RC.id, RC.r as r, RC.cf as cf, RC.ct as ct,
	(SELECT V.value FROM C, V WHERE C.id = RC.cf AND V.id = C.v) as cf_name,
	(SELECT V.value FROM R, V WHERE R.id = RC.r AND V.id = R.v) as r_name,
	(SELECT V.value FROM C, V WHERE C.id = RC.ct AND V.id = C.v) as ct_name
	FROM RC
	""",
	:ARC => """SELECT ARC.id, ARC.rc as rc, ARC.a as a, ARC.v as v,
	(SELECT V.value FROM R, RC, V WHERE RC.id = ARC.rc AND R.id = RC.r AND V.id = R.v) as r_name,
	(SELECT V.value FROM C, RC, V WHERE RC.id = ARC.rc AND C.id = RC.cf AND V.id = C.v) as cf_name,
	(SELECT V.value FROM C, RC, V WHERE RC.id = ARC.rc AND C.id = RC.ct AND V.id = C.v) as ct_name,
	(SELECT V.value FROM A, V WHERE A.id = ARC.a AND V.id = A.v) as a_name,
	(SELECT value FROM V WHERE V.id = ARC.v) as value
	FROM ARC
	""",
	:O => "SELECT id, flag, v, (SELECT V.value FROM V WHERE V.id = O.v) as name FROM O",
	:CO => """SELECT CO.id, CO.c as c, CO.o as o,
	(SELECT V.value FROM C, V WHERE C.id = CO.c AND V.id = C.v) as c_name,
	(SELECT V.value FROM O, V WHERE O.id = CO.o AND V.id = O.v) as o_name
	FROM CO
	""",
	:ACO => """SELECT ACO.id, ACO.co, ACO.a, ACO.v,
	(SELECT V.value FROM C, CO, V WHERE C.id = CO.c AND CO.id = ACO.co AND V.id = C.v) as c_name,
	(SELECT V.value FROM O, CO, V WHERE O.id = CO.o AND CO.id = ACO.co AND V.id = O.v) as o_name,
	(SELECT V.value FROM A, V WHERE A.id = ACO.a AND V.id = A.v) as a_name,
	(SELECT value FROM V WHERE V.id = ACO.v) as value
	FROM ACO
	""",
	:RCO => """SELECT RCO.id, RCO.rc as rc, RCO.of as of, RCO.ot as ot,
	(SELECT V.value FROM R, V WHERE R.id = RC.r AND V.id = R.v) as r_name,
	(SELECT V.value FROM O, V WHERE O.id = RCO.of AND V.id = O.v) as of_name,
	(SELECT V.value FROM O, V WHERE O.id = RCO.ot AND V.id = O.v) as ot_name
	FROM RCO, RC
	WHERE RC.id = RCO.rc 
	""",
	:ARCO => """SELECT ARCO.id, ARCO.rco, ARCO.a, ARCO.v,
	(SELECT V.value FROM R, V WHERE R.id = RC.r AND V.id = R.v) as r_name,
	(SELECT V.value FROM O, V WHERE O.id = RCO.of AND V.id = O.v) as of_name,
	(SELECT V.value FROM O, V WHERE O.id = RCO.ot AND V.id = O.v) as ot_name,
	(SELECT V.value FROM A, V WHERE A.id = ARCO.a AND V.id = A.v) as a_name,
	(SELECT value FROM V WHERE V.id = ARCO.v) as value
	FROM ARCO, RCO, RC
	WHERE RC.id = RCO.rc AND RCO.id = ARCO.rco
	""",
)

# ╔═╡ 95c3a544-28fe-49b7-9970-639ebd543948
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

# ╔═╡ e18a6232-4787-4beb-9ea3-7f4d825068c7
md"""
#### Допоміжні функції для роботи з базою даних
"""

# ╔═╡ c1b74429-f394-476c-b179-726d1028d023
function select_all(db, table)
	#db = DuckDB.DB(file)
	ret = DataFrame(DuckDB.execute(db, sql_selects[table]))
	#DBInterface.close!(db)
	ret
end

# ╔═╡ 3f0efebd-8f18-454a-b210-fec9d5d0c528
function id(kb, table, params)
	sql_id = sql_select_ids[table]
	
	df_id = DataFrame(DuckDB.execute(kb, sql_id, 
		table in [:AC, :AR, :ARC, :ACO, :ARCO] ? params[1:end-1] : params))
	
	ret = nrow(df_id) == 0 ? -1 : df_id[1, :id]
end

# ╔═╡ 9c7605b5-021b-4f68-94e6-199c7fe7f52f
function value(kb, id)
	sql = "SELECT value FROM V WHERE id = ?"
	df = DataFrame(DuckDB.execute(kb, sql, [id]))
	v = nrow(df) == 0 ? "not found" : df[1, :value]
end

# ╔═╡ 36963005-f7de-434d-8351-397dca896b4a
function value_count!(db, param)
	sql_upd = "UPDATE V SET count = count + 1 WHERE id = ?"
	df = DataFrame(DuckDB.execute(db, sql_upd, [param]))
	param
end

# ╔═╡ 519534f3-7d93-401c-85a9-e24fd1bd9556
function id(df, s)
	df[only(findall(==(s), df.name)), :][:id]
end

# ╔═╡ f5f2fa38-8d37-4a64-a7c1-c7f55e4a20be
function insert(db, table, params)
	
	sql_id = sql_select_ids[table]
	ret = id(db, table, params) 
	if ret == -1
		sql_ins = sql_inserts[table]
		df = DataFrame(DuckDB.execute(db, sql_ins, params))
		if table in [:A, :C, :R, :O, :AC, :AR, :ARC, :ACO, :ARCO]
			value_count!(db, params[end])
		end
		ret = nrow(df) == 0 ? -1 : df[1, :id]
	end
		
	ret
end

# ╔═╡ 9c0a2496-4af7-4ecc-9e4f-7de4c4aa239d
md"""
#### Завантаження даних в семантичну мережу із встановленням атрибутів та їх значень
"""

# ╔═╡ de78718a-eeed-4901-a780-04b634095c97
kb = let 
	kb, out = create_kb(tables, file)
	
	v_nothing = insert(kb, :V, ["nothing"])
	v_author1 = insert(kb, :V, ["Голуб Б.Л."])
	v_doc1 = insert(kb, :V, ["Лекція 1"])

	v_c_doc = insert(kb, :V, ["Документ"])
	v_c_author = insert(kb, :V, ["Автор"])
	v_c_sentence = insert(kb, :V, ["Речення"])
	v_c_word = insert(kb, :V, ["Слово"])

	v_a_title = insert(kb, :V, ["Назва"])
	v_a_name = insert(kb, :V, ["Ім'я"])
	v_a_number = insert(kb, :V, ["Номер"])

	v_r_is_author = insert(kb, :V, ["є автором"])
	v_r_has_parts = insert(kb, :V, ["складається з"])

	# select_all(kb, :V)
	
	insert(kb, :C, [v_c_doc])
	insert(kb, :C, [v_c_author])
	insert(kb, :C, [v_c_sentence])
	insert(kb, :C, [v_c_word])
	
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
		
	# select_all(kb, :R)

	insert(kb, :AR, [id(kb, :R, [v_r_has_parts]), id(kb, :A, [v_a_number]), v_nothing])
	
	# select_all(kb, :AR)

	insert(kb, :RC, [id(kb, :C, [v_c_author]), id(kb, :R, [v_r_is_author]), id(kb, :C, [v_c_doc])])
	rc1 = insert(kb, :RC, [id(kb, :C, [v_c_doc]), id(kb, :R, [v_r_has_parts]), id(kb, :C, [v_c_sentence])])
	rc2 = insert(kb, :RC, [id(kb, :C, [v_c_sentence]), id(kb, :R, [v_r_has_parts]), id(kb, :C, [v_c_word])])

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
	
	for s in l1_sent_lcase
		o = insert(kb, :O, [insert(kb, :V, [s])])
		if o > 0
			insert(kb, :CO, [c, o])	
		end
	end
		
	# filter(r -> r.c == c, select_all(kb, :CO))

	c = id(kb, :C, [v_c_word])
	
	for s in keys(lexicon(l1_crps))
		o = insert(kb, :O, [insert(kb, :V, [s])])
		if o > 0
			insert(kb, :CO, [c, o])	
		end
	end
		
	# filter(r -> r.c == c, select_all(kb, :CO))

	r = id(kb, :R, [v_r_has_parts])

	cf = id(kb, :C, [v_c_doc])
	ct = id(kb, :C, [v_c_sentence])

	rc = id(kb, :RC, [cf, r, ct])
	
	of = id(kb, :O, [v_doc1])

	a = id(kb, :A, [v_a_number])
		
	for i in eachindex(l1_sent_lcase)
		ot = id(kb, :O, [insert(kb, :V, [l1_sent_lcase[i]])])
		rco = insert(kb, :RCO, [rc, of, ot])
		insert(kb, :ARCO, [rco, a, insert(kb, :V, ["$i"])])
	end
		
	# filter(r -> r.rc == rc, select_all(kb, :RCO))
	# select_all(kb, :ARCO)
	kb
end

# ╔═╡ 6ec1ee46-23cb-4424-b502-b31bce494df5
DataFrame(DuckDB.execute(kb, "SELECT * FROM information_schema.tables"))

# ╔═╡ 70801f02-1399-4b2b-8767-3702cd72a618
md"""
#### Відобразимо встановлені атрибути та їхні значення
"""

# ╔═╡ 4f85a776-5d82-4475-9beb-4464b0cee4a6
select_all(kb, :V)

# ╔═╡ 7459bb7d-eaf2-4837-8136-bb7360e6d40c
select_all(kb, :C)

# ╔═╡ e17952d1-5c42-4322-9bff-6ba4d421c76e
select_all(kb, :A)

# ╔═╡ 09a3046b-787a-499f-85e1-6f6dab844564
select_all(kb, :R)

# ╔═╡ 883c57a7-a3d1-4a6d-bfc9-16fd725552ba
select_all(kb, :AC)

# ╔═╡ cc60c9e2-1cb3-4f90-ab7b-61e4c8c62546
select_all(kb, :AR)

# ╔═╡ b1d8e9c2-7468-448f-8870-0b1f26ed6c9f
select_all(kb, :RC)

# ╔═╡ ae36bfe0-53a2-4568-93c2-6026c4975cff
select_all(kb, :O)

# ╔═╡ a1709dd9-f830-4851-a1fd-d9d4c45f6bbe
select_all(kb, :CO)

# ╔═╡ f26f2ffb-c5ca-4fc7-8692-8dc065917938
select_all(kb, :ACO)

# ╔═╡ e2c89a2d-62d7-463e-8abe-dfa9e230fa60
select_all(kb, :RCO)

# ╔═╡ ed6b367a-8e2f-4643-a1cb-cc5bd05c4a52
select_all(kb, :ARC)

# ╔═╡ 89304cb2-e925-44c4-96c7-8e8ae65c1304
select_all(kb, :ARCO)

# ╔═╡ 22622a1e-2624-4804-a5b8-104fdde84c37
md"""
## Висновки

* В якості сховища даних використано DuckDB (in-process SQL OLAP database)

* В цій роботі продовжено узагальнення результатів попередніх робіт

* Всі константи пренесено в таблицю значень (V), інші сутності тепер використовують їх через посилання

* Реалізовано лічільник посилань на екземпляр значення

В наступній роботі передбачається дослідити методи витягу даних зі сховища семантичної мережі

"""

# ╔═╡ 3265a9cc-7369-460f-a346-894ad78e9ffc
md"""
# Обов'язкова програма для атестації
"""

# ╔═╡ bd07605a-bd90-4e8b-b6f3-015926b2cbab
password = "work";

# ╔═╡ b9b59833-e208-4b65-ada1-7fafaff30a69
conn = LibPQ.Connection("host=localhost dbname=work user=work password=$password")

# ╔═╡ 65df63f8-2f6e-40fb-a5b4-6004daa910f3
md"""
### Визначення, розрахунок та представлення КПЕ
"""

# ╔═╡ f00de244-5f94-4ad0-807d-cfbab4326ccb
md"""

- Мета: контролювати денний об'єм грошового потоку на ПТКС на рівні, встановленому параметром "target"

- КПЕ: стандартизоване відхилення від встановленого рівня: від -1 - дуже погано до 1 - дуже добре

"""

# ╔═╡ ca51b472-f406-4fc6-a513-9eba54ed1bf6
target = 70000

# ╔═╡ d8d7a277-e006-4ea7-a8f7-3908a7607d5e
md"""
#### Завантажимо дані "вітрини" в DataFrame
"""

# ╔═╡ eb6a6518-744d-4939-9d09-d584c27fd783
data = DataFrame(execute(conn, 
"""
SELECT dt.year as year, dt.year*100+dt.month as month, dt.year*10000+dt.month*100+ dt.day as day, p.name as partner, trm.name as terminal, tp.name as type, trx.amount as amount
FROM FactTransactions trx, DimTypeTrx tp, DimDate dt, DimTerminals trm, DimPartners p
WHERE trx.id_term = trm.id AND trx.id_type = tp.id AND trx.id_date = dt.id AND trm.id_partner = p.id;
"""
))

# ╔═╡ ee639081-787b-4abc-9ce0-a47b0e261377
md"""
#### Створимо columnar database в пам'яті та зареєструємо в ній наш DataFrame
"""

# ╔═╡ 3d50750d-e8c2-443e-a463-6204bbe06113
aserv = DuckDB.open(":memory:")

# ╔═╡ 0a2102e5-e596-4cd6-b311-ff65b3e3b9e9
DuckDB.register_data_frame(aserv, data, "data")

# ╔═╡ 79327798-fc80-48c2-b701-8da779ffe054
md"""
### Щоденний грошовий потік на ПТКС
"""

# ╔═╡ 98e4e010-2a99-46a5-a569-8c0c609aea31
md"""
#### ПТКС - "Term01"
"""

# ╔═╡ 0c622919-bac1-4a8b-9721-b0dc53af5964
df_t1 = DataFrame(DuckDB.execute(aserv,
"""
SELECT day, SUM(amount)/100 as amount
FROM data
GROUP BY CUBE (year, month, day, partner, terminal, type)
HAVING year IS NULL AND month IS NULL AND day IS NOT NULL AND partner IS NULL AND terminal = 'Term01' AND type IS NULL
ORDER BY day;
"""
))

# ╔═╡ 70548f75-c8ea-4396-8c58-94f89b15aeed
describe(df_t1)

# ╔═╡ 37d00220-7430-44f5-a1e9-fc6727fee595
md"""
#### ПТКС - "Term02"
"""

# ╔═╡ bc1d139d-e004-49ef-85f2-9fcb6a43df53
df_t2 = DataFrame(DuckDB.execute(aserv,
"""
SELECT day, SUM(amount)/100 as amount
FROM data
GROUP BY CUBE (year, month, day, partner, terminal, type)
HAVING year IS NULL AND month IS NULL AND day IS NOT NULL AND partner IS NULL AND terminal = 'Term02' AND type IS NULL
ORDER BY day;
"""
))

# ╔═╡ 2e4bc14f-0abe-4f72-afa6-d939ac70d379
describe(df_t2)

# ╔═╡ a875ce7b-a37a-454a-b7e9-c2ecffb1dceb


# ╔═╡ 6435d7e2-3f58-44ba-9b18-e652d6ad0d19
md"""
#### ПТКС - "Term03"
"""

# ╔═╡ a1825053-5db0-4ab2-a849-6e1b8f90ce79
df_t3 = DataFrame(DuckDB.execute(aserv,
"""
SELECT day, SUM(amount)/100 as amount
FROM data
GROUP BY CUBE (year, month, day, partner, terminal, type)
HAVING year IS NULL AND month IS NULL AND day IS NOT NULL AND partner IS NULL AND terminal = 'Term03' AND type IS NULL
ORDER BY day;
"""
))

# ╔═╡ 74f4be69-f06d-408d-9f90-26f974baf74b
describe(df_t3)

# ╔═╡ 35427b75-509f-4fdf-826e-089bdf2849f1
md"""
#### Графік денного рівня грошового потоку на ПТКС, грн
"""

# ╔═╡ aa77355d-8f83-405f-afd9-8dafc201b273
begin
	x = 2:nrow(df_t1)-1
	xlim = [1, nrow(df_t1)]
	
	y1 = df_t1[!, :amount][2:end-1]
	y2 = df_t2[!, :amount][2:end-1]
	y3 = df_t3[!, :amount][2:end-1]
	ymin = min(minimum(y1), minimum(y2), minimum(y3))
	ymax = max(maximum(y1), maximum(y2), maximum(y3))
	ylim = [ymin, ymax]
	
	
	plot(x, y1, xlim=xlim, ylim=ylim,  linewidth=3, label="Term01")
	plot!(x, y2, linewidth=3, label="Term02")
	plot!(x, y3, linewidth=3, label="Term03")
	hline!([target], label="Target")
end

# ╔═╡ 108b7d18-550d-4685-acff-555a64d042fb
md"""
#### Графік стандартизованих відхилень від цільового рівня
"""

# ╔═╡ 0c5c6a61-5546-45e9-bfd6-3c604cc85d06
begin
	Δy = (ymax - ymin)
	
	Δy1 = (y1 .- target) ./ Δy
	Δy2 = (y2 .- target) ./ Δy
	Δy3 = (y3 .- target) ./ Δy

	plot(x, Δy1, xlim=xlim, ylim=[-1, 1],  linewidth=3, label="Term01")
	plot!(x, Δy2, linewidth=3, label="Term02")
	plot!(x, Δy3, linewidth=3, label="Term03")
	hline!([0], label="Target")
end

# ╔═╡ c84c34d6-3ea1-4b7f-ab1b-ab41ea984931
md"""
#### ПТКС - "Term01"

- В середньому трохи вище цільового рівня, результати щільні, є аномальні викиди

"""

# ╔═╡ aec13cf8-b795-422d-973a-abf8e7bbcc0b
begin
	boxplot(Δy1, label="Term01")
	hline!([0], label="Target")
end

# ╔═╡ 34302021-85a6-4af4-9752-b887193f852f
md"""
#### ПТКС - "Term02"

- В середньому нижче цільового рівня, результати не щільні

"""

# ╔═╡ 843deb02-264b-4fbc-83f5-1f2a91189075
begin
	boxplot(Δy2, label="Term02")
	hline!([0], label="Target")
end

# ╔═╡ c8ee2238-af53-4dd4-a638-02e812f20a92
md"""
#### ПТКС - "Term03"

- В середньому вище цільового рівня, результати не щільні

"""

# ╔═╡ fcd5dc1a-9f72-4715-ac84-83c84a949e69
begin
	boxplot(Δy3, label="Term03")
	hline!([0], label="Target")
end

# ╔═╡ 9868a5e7-7ac7-462e-9977-733764cde5b4
md"""
# Використані джерела

1. The Julia Programming Language - [https://julialang.org/](https://julialang.org/)
1. The Rise and Fall of the OLAP Cube - [https://www.holistics.io/blog/the-rise-and-fall-of-the-olap-cube/](https://www.holistics.io/blog/the-rise-and-fall-of-the-olap-cube/)
1. OLAP != OLAP Cube - [https://www.holistics.io/blog/olap-is-not-olap-cube/](https://www.holistics.io/blog/olap-is-not-olap-cube/)
1. Column-oriented DBMS - [https://en.wikipedia.org/wiki/Column-oriented_DBMS](https://en.wikipedia.org/wiki/Column-oriented_DBMS)
1. DuckDB is an in-process SQL OLAP database management system - [https://duckdb.org/](https://duckdb.org/)

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
DuckDB = "d2f5444f-75bc-4fdf-ac35-56f514c445e1"
Languages = "8ef0a80b-9436-5d2c-a485-80b904378c43"
LibPQ = "194296ae-ab2e-5f79-8cd4-7183a0a5a0d1"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"
TextAnalysis = "a2db99b7-8b79-58f8-94bf-bbc811eef33d"

[compat]
CommonMark = "~0.8.7"
DataFrames = "~1.4.4"
DuckDB = "~0.6.0"
Languages = "~0.4.3"
LibPQ = "~1.14.1"
PlutoUI = "~0.7.49"
StatsPlots = "~0.15.4"
TextAnalysis = "~0.7.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "06eb5fccc1d74d074da26c0b50c582f69b5f23ca"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra", "Logging"]
git-tree-sha1 = "9b9b347613394885fd1c8c7729bfc60528faa436"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.5.4"

[[deps.Arpack_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "5ba6c757e8feccf03a1554dfaf3e26b3cfc7fd5e"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.1+1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

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

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "Random", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "64df3da1d2a26f4de23871cd1b6482bb68092bd5"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.3"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "86cce6fd164c26bad346cc51ca736e692c9f553c"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.7"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DBInterface]]
git-tree-sha1 = "9b0dc525a052b9269ccc5f7f04d5b3639c65bca5"
uuid = "a10d1c49-ce27-4219-8d33-6db1a4562965"
version = "2.5.0"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

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

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Decimals]]
git-tree-sha1 = "e98abef36d02a0ec385d68cd7dadbce9b28cbd88"
uuid = "abce61dc-4473-55a0-ba07-351d65e31d42"
version = "0.4.1"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "a7756d098cbabec6b3ac44f369f74915e8cfd70a"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.79"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

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

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "9a0472ec2f5409db243160a8b030f94c380167a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.6"

[[deps.FixedPointDecimals]]
git-tree-sha1 = "9056462184023d22fdfc40f8b70b274f3a42c898"
uuid = "fb4d412d-6eee-574d-9565-ede6634db7b0"
version = "0.4.1"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "051072ff2accc6e0e87b708ddee39b18aa04a0bc"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.1"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "501a4bf76fd679e7fcd678725d5072177392e756"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.1+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTML_Entities]]
deps = ["StrTables"]
git-tree-sha1 = "c4144ed3bc5f67f595622ad03c0e39fa6c70ccc7"
uuid = "7693890a-d069-55fe-a829-b4a6d304f0ee"
version = "1.0.1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "822a2b8d53fd5fb8d2f454d521d51dd88bcfc8a6"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.6.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

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

[[deps.Infinity]]
deps = ["Dates", "Random", "Requires"]
git-tree-sha1 = "cf8234411cbeb98676c173f930951ea29dca3b23"
uuid = "a303e19e-6eb4-11e9-3b09-cd9505f79100"
version = "0.2.4"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "0cf92ec945125946352f3d46c96976ab972bde6f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.3.2"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "721ec2cf720536ad005cb38f50dbba7b02419a15"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.7"

[[deps.Intervals]]
deps = ["Dates", "Printf", "RecipesBase", "Serialization", "TimeZones"]
git-tree-sha1 = "f3c7f871d642d244e7a27e3fb81e8441e13230d8"
uuid = "d8418881-c3e1-53bb-8760-2df7ec849ed5"
version = "1.8.0"

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

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

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

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.Kerberos_krb5_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "60274b4ab38e8d1248216fe6b6ace75ae09b0502"
uuid = "b39eb1a6-c29a-53d7-8c32-632cd16f18da"
version = "1.19.3+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Languages]]
deps = ["InteractiveUtils", "JSON"]
git-tree-sha1 = "b1a564061268ccc3f3397ac0982983a657d4dcb8"
uuid = "8ef0a80b-9436-5d2c-a485-80b904378c43"
version = "0.4.3"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

[[deps.LayerDicts]]
git-tree-sha1 = "6087ad3521d6278ebe5c27ae55e7bbb15ca312cb"
uuid = "6f188dcb-512c-564b-bc01-e0f76e72f166"
version = "1.0.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[deps.LibPQ]]
deps = ["CEnum", "Dates", "Decimals", "DocStringExtensions", "FileWatching", "Infinity", "Intervals", "IterTools", "LayerDicts", "LibPQ_jll", "Libdl", "Memento", "OffsetArrays", "SQLStrings", "Tables", "TimeZones"]
git-tree-sha1 = "98f4d4dcfd5fca71b8acf0a90772badfdbac5660"
uuid = "194296ae-ab2e-5f79-8cd4-7183a0a5a0d1"
version = "1.14.1"

[[deps.LibPQ_jll]]
deps = ["Artifacts", "JLLWrappers", "Kerberos_krb5_jll", "Libdl", "OpenSSL_jll", "Pkg"]
git-tree-sha1 = "a299629703a93d8efcefccfc16b18ad9a073d131"
uuid = "08be9ffa-1c94-5ee5-a977-46a84ec9b350"
version = "14.3.0+1"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

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

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "2ce8695e1e699b68702c03402672a69f54b8aca9"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.2.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

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

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Memento]]
deps = ["Dates", "Distributed", "Requires", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "bb2e8f4d9f400f6e90d57b34860f6abdc51398e5"
uuid = "f28f55f0-a522-5efc-85c2-fe41dfb9b2d9"
version = "1.4.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.Mocking]]
deps = ["Compat", "ExprTools"]
git-tree-sha1 = "c272302b22479a24d1cf48c114ad702933414f80"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.5"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI", "StatsBase"]
git-tree-sha1 = "efe9c8ecab7a6311d4b91568bd6c88897822fabe"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.10.0"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "440165bf08bc500b8fe4a7be2dc83271a00c0716"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "6862738f9796b3edc1c09d0890afce4eca9e7e93"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.4"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "f71d8950b724e9ff6110fc948dff5a329f901d64"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.8"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

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

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "5b7690dd212e026bbab1860016a6601cb077ab66"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.2"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "dadd6e31706ec493192a70a7090d369771a9a22a"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.37.2"

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

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "97aa253e65b784fd13e83774cadc95b38011d734"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.6.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "18c35ed630d7229c5584b945641a73ca83fb5213"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.2"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "e974477be88cb5e3040009f3767611bc6357846f"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.11"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SQLStrings]]
git-tree-sha1 = "55de0530689832b1d3d43491ee6b67bd54d3323c"
uuid = "af517c2e-c243-48fa-aab8-efac3db270f5"
version = "0.1.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "efd23b378ea5f2db53a55ae53d3133de4e080aa9"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.16"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

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

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "ffc098086f35909741f71ce21d03dadf0d2bfa76"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.11"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

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

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "ab6083f09b3e617e34a956b43e9d51b824206932"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.1.1"

[[deps.StatsPlots]]
deps = ["AbstractFFTs", "Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "NaNMath", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "e0d5bc26226ab1b7648278169858adcfbd861780"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.15.4"

[[deps.StrTables]]
deps = ["Dates"]
git-tree-sha1 = "5998faae8c6308acc25c25896562a1e66a3bb038"
uuid = "9700d1a9-a7c8-5760-9816-a99fda30bb8f"
version = "1.0.1"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "e383c87cf2a1dc41fa30c093b2a19877c83e1bc1"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.2.0"

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

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TextAnalysis]]
deps = ["DataStructures", "DelimitedFiles", "JSON", "Languages", "LinearAlgebra", "Printf", "ProgressMeter", "Random", "Serialization", "Snowball", "SparseArrays", "Statistics", "StatsBase", "Tables", "WordTokenizers"]
git-tree-sha1 = "bc85e54209c30e69e1925460ec0257a916683f59"
uuid = "a2db99b7-8b79-58f8-94bf-bbc811eef33d"
version = "0.7.3"

[[deps.TimeZones]]
deps = ["Dates", "Downloads", "InlineStrings", "LazyArtifacts", "Mocking", "Printf", "RecipesBase", "Scratch", "Unicode"]
git-tree-sha1 = "a92ec4466fc6e3dd704e2668b5e7f24add36d242"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.9.1"

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

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "fcdae142c1cfc7d89de2d11e08721d0f2f86c98a"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.6"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.WordTokenizers]]
deps = ["DataDeps", "HTML_Entities", "StrTables", "Unicode"]
git-tree-sha1 = "01dd4068c638da2431269f49a5964bf42ff6c9d2"
uuid = "796a5d58-b03d-544a-977e-18100b691f6e"
version = "0.5.6"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─d0fd59e4-d83d-4b18-8fd4-9781e171c3da
# ╟─829d12ee-d4cb-4555-b847-d0fa84b4f103
# ╠═ebdf79fe-70bb-11ed-1238-eb60f38082ec
# ╟─b13070b5-9875-45b6-a74e-1ed0f0c4a5fd
# ╟─d29ea611-2224-40b1-9619-21d5a25bac8a
# ╟─53f00c22-7243-448f-bea5-d6e4cf165b90
# ╟─ce44520a-ad21-4aa6-86f1-e46ffeed4b31
# ╠═54b57fcf-6f4d-4e9f-ac1d-a075a9f74507
# ╟─7910d7c5-0741-4fc2-ab71-a37a4f63e366
# ╟─c1409952-da5f-4b80-a28e-a717d3e99fdd
# ╟─d052f8bf-fd34-48dc-a19c-d634e74aa2bf
# ╟─ae939911-0f8b-429b-9ccb-90828431f5bd
# ╟─02e59024-01bd-470a-ae1e-caeeef8c001e
# ╠═6ec1ee46-23cb-4424-b502-b31bce494df5
# ╟─11664dc4-89d1-42bd-8640-0ca7e80ca7e5
# ╠═66a41d0b-0734-4699-8a08-287019928cc7
# ╠═25d21a3a-6e90-4561-8eb3-65d606c8ae60
# ╟─ac223604-4179-4087-bfd3-dd88e099a115
# ╠═92f08f94-ab7d-46b6-ab80-e432ee159625
# ╠═6fc3d8d1-5ecb-4522-bbee-e83b5a1a0f4c
# ╠═95c3a544-28fe-49b7-9970-639ebd543948
# ╟─e18a6232-4787-4beb-9ea3-7f4d825068c7
# ╠═f5f2fa38-8d37-4a64-a7c1-c7f55e4a20be
# ╟─c1b74429-f394-476c-b179-726d1028d023
# ╠═3f0efebd-8f18-454a-b210-fec9d5d0c528
# ╠═9c7605b5-021b-4f68-94e6-199c7fe7f52f
# ╠═36963005-f7de-434d-8351-397dca896b4a
# ╟─519534f3-7d93-401c-85a9-e24fd1bd9556
# ╟─9c0a2496-4af7-4ecc-9e4f-7de4c4aa239d
# ╠═de78718a-eeed-4901-a780-04b634095c97
# ╟─70801f02-1399-4b2b-8767-3702cd72a618
# ╠═4f85a776-5d82-4475-9beb-4464b0cee4a6
# ╠═7459bb7d-eaf2-4837-8136-bb7360e6d40c
# ╠═e17952d1-5c42-4322-9bff-6ba4d421c76e
# ╠═09a3046b-787a-499f-85e1-6f6dab844564
# ╠═883c57a7-a3d1-4a6d-bfc9-16fd725552ba
# ╠═cc60c9e2-1cb3-4f90-ab7b-61e4c8c62546
# ╠═b1d8e9c2-7468-448f-8870-0b1f26ed6c9f
# ╠═ae36bfe0-53a2-4568-93c2-6026c4975cff
# ╠═a1709dd9-f830-4851-a1fd-d9d4c45f6bbe
# ╠═f26f2ffb-c5ca-4fc7-8692-8dc065917938
# ╠═e2c89a2d-62d7-463e-8abe-dfa9e230fa60
# ╠═ed6b367a-8e2f-4643-a1cb-cc5bd05c4a52
# ╠═89304cb2-e925-44c4-96c7-8e8ae65c1304
# ╟─22622a1e-2624-4804-a5b8-104fdde84c37
# ╟─3265a9cc-7369-460f-a346-894ad78e9ffc
# ╠═f622df43-b3f5-45f2-99e8-e6c35066fb00
# ╟─bd07605a-bd90-4e8b-b6f3-015926b2cbab
# ╠═b9b59833-e208-4b65-ada1-7fafaff30a69
# ╟─65df63f8-2f6e-40fb-a5b4-6004daa910f3
# ╟─f00de244-5f94-4ad0-807d-cfbab4326ccb
# ╠═ca51b472-f406-4fc6-a513-9eba54ed1bf6
# ╟─d8d7a277-e006-4ea7-a8f7-3908a7607d5e
# ╠═eb6a6518-744d-4939-9d09-d584c27fd783
# ╟─ee639081-787b-4abc-9ce0-a47b0e261377
# ╠═3d50750d-e8c2-443e-a463-6204bbe06113
# ╠═0a2102e5-e596-4cd6-b311-ff65b3e3b9e9
# ╟─79327798-fc80-48c2-b701-8da779ffe054
# ╟─98e4e010-2a99-46a5-a569-8c0c609aea31
# ╠═0c622919-bac1-4a8b-9721-b0dc53af5964
# ╠═70548f75-c8ea-4396-8c58-94f89b15aeed
# ╟─37d00220-7430-44f5-a1e9-fc6727fee595
# ╠═bc1d139d-e004-49ef-85f2-9fcb6a43df53
# ╠═2e4bc14f-0abe-4f72-afa6-d939ac70d379
# ╠═a875ce7b-a37a-454a-b7e9-c2ecffb1dceb
# ╠═6435d7e2-3f58-44ba-9b18-e652d6ad0d19
# ╠═a1825053-5db0-4ab2-a849-6e1b8f90ce79
# ╠═74f4be69-f06d-408d-9f90-26f974baf74b
# ╟─35427b75-509f-4fdf-826e-089bdf2849f1
# ╠═d20e2f26-3cac-4af9-af0b-639cd39479a6
# ╠═aa77355d-8f83-405f-afd9-8dafc201b273
# ╟─108b7d18-550d-4685-acff-555a64d042fb
# ╠═0c5c6a61-5546-45e9-bfd6-3c604cc85d06
# ╟─c84c34d6-3ea1-4b7f-ab1b-ab41ea984931
# ╠═aec13cf8-b795-422d-973a-abf8e7bbcc0b
# ╟─34302021-85a6-4af4-9752-b887193f852f
# ╠═843deb02-264b-4fbc-83f5-1f2a91189075
# ╟─c8ee2238-af53-4dd4-a638-02e812f20a92
# ╠═fcd5dc1a-9f72-4715-ac84-83c84a949e69
# ╟─9868a5e7-7ac7-462e-9977-733764cde5b4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
