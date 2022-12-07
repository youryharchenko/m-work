### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ ebdf79fe-70bb-11ed-1238-eb60f38082ec
using DuckDB, PlutoUI, CommonMark, TextAnalysis, Languages, DataFrames, LibPQ

# ╔═╡ d0fd59e4-d83d-4b18-8fd4-9781e171c3da
cm"""
---

<div align="center">

Національний університет біоресурсів і природокористування України

Факультет інформаційних технологій

Кафедра комп'ютерних наук

<br/><br/>

Лабораторна робота 3

Заповнення сховища даних семантичної мережі

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
	(drop = true, create = true, file = "sql/create_C.sql", name = "C"),
	(drop = true, create = true, file = "sql/create_R.sql", name = "R"),
	(drop = true, create = true, file = "sql/create_A.sql", name = "A"),
	(drop = true, create = true, file = "sql/create_V.sql", name = "V"),
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
	#DBInterface.close!(db)
	(db, Text(out))
end

# ╔═╡ ac8b2fcc-723a-4e81-99f0-2ac2f2d273a5
kb, out = create_kb(tables, file)

# ╔═╡ 11664dc4-89d1-42bd-8640-0ca7e80ca7e5
md"""
#### Завантажуємо документ та робимо попередню обробку тексту
"""

# ╔═╡ 48a1aed6-13bc-4e89-b4d7-b4f29da8c141
pathname = "Лекція 1.txt"

# ╔═╡ fd276cd8-1ce7-431d-8e88-7e3d0b9e2294
l1 = StringDocument(text(FileDocument(pathname)))

# ╔═╡ ab86f8cf-dde7-452c-b3d5-9ef1fdba6aa7
TextAnalysis.remove_whitespace!(l1)

# ╔═╡ f0ac46c9-3487-41ff-b84b-4bef00a0dd4a
l1_sents = TextAnalysis.sentence_tokenize(Languages.Ukrainian(), text(l1))

# ╔═╡ 191d1d5f-dc33-4613-a2f6-2d4b59532cc4
DataFrame(text = l1_sents)

# ╔═╡ a6321bad-cdcb-4848-b81a-c84ea1a013af
l1_crps = Corpus([StringDocument(String(s)) for s in l1_sents])

# ╔═╡ 166cc9a6-7a6a-4087-82f8-a4d6deb6fdf4
languages!(l1_crps, Languages.Ukrainian())

# ╔═╡ b5978aa3-b3b1-4dd3-8d8b-76ce9ec96ed4
remove_case!(l1_crps)

# ╔═╡ c973a571-aae8-4605-9e10-403aa030aef2
md"""
#### Отримуємо масив речень
"""

# ╔═╡ 38dcffdf-10e8-4ee9-867a-137e9a5b2075
l1_sent_lcase = [text(d) for d in l1_crps]

# ╔═╡ 78ba976e-9a0e-4cbd-8bed-89a7d97d8fa3


# ╔═╡ 3d0d283c-36e2-4e9e-8c7a-c4094def901b
DataFrame(text = l1_sent_lcase)

# ╔═╡ b144d063-5f73-499b-9a57-adfce3f02530
md"""
#### Створюємо лексикон
"""

# ╔═╡ 7b6a1ba7-49df-4b39-b851-1c97260ed3d8
begin
	prepare!(l1_crps, strip_punctuation | strip_numbers)
	#remove_words!(l1_crps, ["на","і","що","в","до","не","для"])
	update_lexicon!(l1_crps)
	l1_lex = lexicon(l1_crps)
end

# ╔═╡ eecd09c7-c3a5-4352-8865-2e71b1892b89
sort(DataFrame(word = collect(keys(l1_lex)), count = collect(values(l1_lex))), [:count], rev=true )

# ╔═╡ 1e545f9f-d313-47de-b1ee-6a6b47ff9fcc
md"""
#### Будуємо інвертований індекс слів
"""

# ╔═╡ 6bcf1726-61fe-42cd-a83a-13b7eea257db
update_inverse_index!(l1_crps)

# ╔═╡ ac146e13-9488-46c1-b549-a3f3ed63a82c
inverse_index(l1_crps)

# ╔═╡ ac223604-4179-4087-bfd3-dd88e099a115
md"""
#### Словники запитів до база даних
"""

# ╔═╡ 92f08f94-ab7d-46b6-ab80-e432ee159625
sql_inserts = Dict(
	:A => "INSERT INTO A (id, name) VALUES(nextval('SEQ_A'), ?) RETURNING id",
	:C => "INSERT INTO C (id, name) VALUES(nextval('SEQ_C'), ?) RETURNING id",
	:R => "INSERT INTO R (id, name) VALUES(nextval('SEQ_R'), ?) RETURNING id",
	:RC => "INSERT INTO RC (id, cf, r, ct) VALUES(nextval('SEQ_RC'), ?, ?, ?) RETURNING id",
	:O => "INSERT INTO O (id, name) VALUES(nextval('SEQ_O'), ?) RETURNING id",
	:CO => "INSERT INTO CO (id, c, o) VALUES(nextval('SEQ_CO'), ?, ?) RETURNING id",
	:RCO => "INSERT INTO RCO (id, rc, of, ot) VALUES(nextval('SEQ_RCO'), ?, ?, ?) RETURNING id",
)

# ╔═╡ 6fc3d8d1-5ecb-4522-bbee-e83b5a1a0f4c
sql_selects = Dict(
	:A => "SELECT * FROM A",
	:C => "SELECT * FROM C",
	:R => "SELECT * FROM R",
	:RC => """SELECT RC.id, RC.r as r, RC.cf as cf, RC.ct as ct,
	(SELECT name FROM C WHERE C.id = RC.cf) as cf_name,
	(SELECT name FROM R WHERE R.id = RC.r) as r_name,
	(SELECT name FROM C WHERE C.id = RC.ct) as ct_name
	FROM RC
	""",
	:O => "SELECT * FROM O",
	:CO => """SELECT CO.id, CO.c as c, CO.o as o,
	(SELECT name FROM C WHERE C.id = CO.c) as c_name,
	(SELECT name FROM O WHERE O.id = CO.o) as o_name
	FROM CO
	""",
	:RCO => """SELECT RCO.id, RCO.rc as rc, RCO.of as of, RCO.ot as ot,
	(SELECT name FROM R WHERE R.id = RC.r) as r_name,
	(SELECT name FROM O WHERE O.id = RCO.of) as of_name,
	(SELECT name FROM O WHERE O.id = RCO.ot) as ot_name
	FROM RCO, RC
	WHERE RC.id = RCO.rc 
	""",
)

# ╔═╡ 95c3a544-28fe-49b7-9970-639ebd543948
sql_select_ids = Dict(
	:A => "SELECT id FROM A WHERE name = ?",
	:C => "SELECT id FROM C WHERE name = ?",
	:R => "SELECT id FROM R WHERE name = ?",
	:RC => "SELECT id FROM RC WHERE cf = ? AND r = ? AND ct = ?",
	:O => "SELECT id FROM O WHERE name = ?",
	:CO => "SELECT id FROM CO WHERE c = ? AND o = ?",
	:RCO => "SELECT id FROM RCO	WHERE of = ? AND rc = ? AND ot = ?",
)

# ╔═╡ e18a6232-4787-4beb-9ea3-7f4d825068c7
md"""
#### Допоміжні функції для роботи з базою даних
"""

# ╔═╡ f5f2fa38-8d37-4a64-a7c1-c7f55e4a20be
function insert(db, table, params)
	id = -1
	sql_id = sql_select_ids[table]
	df_id = DataFrame(DuckDB.execute(db, sql_id, params))
	if nrow(df_id) == 0
		sql_ins = sql_inserts[table]
		ret = DataFrame(DuckDB.execute(db, sql_ins, params))
		id = nrow(ret) == 0 ? -1 : ret[1, :id]
	else
		id = nrow(df_id) == 0 ? -1 : df_id[1, :id]
	end
		
	id
end

# ╔═╡ c1b74429-f394-476c-b179-726d1028d023
function select_all(db, table)
	#db = DuckDB.DB(file)
	ret = DataFrame(DuckDB.execute(db, sql_selects[table]))
	#DBInterface.close!(db)
	ret
end

# ╔═╡ 22e6cf0a-9cf7-4c60-b45d-f3e2802cec2e
md"""
#### Додаємо категорії
"""

# ╔═╡ de78718a-eeed-4901-a780-04b634095c97
begin 
	insert(kb, :C, ["Документ"])
	insert(kb, :C, ["Автор"])
	insert(kb, :C, ["Речення"])
	insert(kb, :C, ["Слово"])
	
	select_all(kb, :C)
end

# ╔═╡ 3cfba17f-8530-4f9a-8e19-33b787de1e08
md"""
#### Додаємо атрибути
"""

# ╔═╡ 82a366c1-a45a-42fe-94c2-9e7125798ad1
begin 
	insert(kb, :A, ["Назва"])
	insert(kb, :A, ["Ім'я"])
	insert(kb, :A, ["Номер"])
	
	select_all(kb, :A)
end

# ╔═╡ 05364475-a0e9-4838-9d2e-9f916d5332de
md"""
#### Додаємо відношення
"""

# ╔═╡ 97e88798-2a9a-43df-8eee-d345dab2dc71
begin 
	insert(kb, :R, ["є автором"])
	insert(kb, :R, ["складається з"])
		
	select_all(kb, :R)
end

# ╔═╡ 589858aa-221b-4628-af75-b73b53003740
function id(kb, table, params)
	sql_id = sql_select_ids[table]
	df_id = DataFrame(DuckDB.execute(kb, sql_id, params))
	id = nrow(df_id) == 0 ? -1 : df_id[1, :id]
end

# ╔═╡ 3ee5b11b-a401-46ab-a69e-dfaf6850a8a7
function id(df, s)
	df[only(findall(==(s), df.name)), :][:id]
end

# ╔═╡ d0ef93a1-9efe-46a8-a6a3-658e95d25a36
md"""
#### Додаємо відношення між категоріями
"""

# ╔═╡ 5e42f457-c4f8-4443-b62c-fd5681fabc2b
let
		
	
	insert(kb, :RC, [id(kb, :C, ["Автор"]), id(kb, :R, ["є автором"]), id(kb, :C, ["Документ"])])
	insert(kb, :RC, [id(kb, :C, ["Документ"]), id(kb, :R, ["складається з"]), id(kb, :C, ["Речення"])])
	insert(kb, :RC, [id(kb, :C, ["Речення"]), id(kb, :R, ["складається з"]), id(kb, :C, ["Слово"])])

	select_all(kb, :RC)
end

# ╔═╡ 7a1d293b-b3a2-4f2f-b037-22b1fee736c7
md"""
#### Додаємо об'єкти верхнього рівня 
"""

# ╔═╡ ae0a009f-707a-4dba-87d4-d7dfcc787664
let 

	insert(kb, :O, ["Голуб Б.Л."])
	insert(kb, :O, ["Лекція 1"])
		
	insert(kb, :CO, [id(kb, :C, ["Автор"]), id(kb, :O, ["Голуб Б.Л."])])
	insert(kb, :CO, [id(kb, :C, ["Документ"]), id(kb, :O, ["Лекція 1"])])
		
	filter(r -> r.c in [id(kb, :C, ["Автор"]), id(kb, :C, ["Документ"])], select_all(kb, :CO))
end

# ╔═╡ 67e7cca7-b8ca-4055-9195-149e6bdc7022
md"""
#### Завантажуємо речення як категорію "Речення"
"""

# ╔═╡ 5409aae1-c193-4aa2-9adc-d3758422aa56
let 
			
	c = id(kb, :C, ["Речення"])
	
	for s in l1_sent_lcase
		o = insert(kb, :O, [s])
		if o > 0
			insert(kb, :CO, [c, o])	
		end
	end
		
	filter(r -> r.c == c, select_all(kb, :CO))
end

# ╔═╡ 79ad3d2a-5596-45d6-9053-abb7bf651cac
md"""
#### Завантажуємо слова як категорію "Слово"
"""

# ╔═╡ 3771852e-2e70-4895-90b6-f62bc7dcfe4f
let 
			
	c = id(kb, :C, ["Слово"])
	
	for s in keys(l1_lex)
		o = insert(kb, :O, [s])
		if o > 0
			insert(kb, :CO, [c, o])	
		end
	end
		
	filter(r -> r.c == c, select_all(kb, :CO))
end

# ╔═╡ 70801f02-1399-4b2b-8767-3702cd72a618
md"""
#### Встановлюємо відношення "складається з" між документом "Лекція 1" та його реченнями
"""

# ╔═╡ be7d2409-486d-4926-9ff2-5c1584a6cf0b
let 
	
	r = id(kb, :R, ["складається з"])

	cf = id(kb, :C, ["Документ"])
	ct = id(kb, :C, ["Речення"])

	rc = id(kb, :RC, [cf, r, ct])
	
	of = id(kb, :O, ["Лекція 1"])
		
	for s in l1_sent_lcase
		ot = id(kb, :O, [s])
		insert(kb, :RCO, [rc, of, ot])
	end
		
	filter(r -> r.rc == rc, select_all(kb, :RCO))
end

# ╔═╡ 22622a1e-2624-4804-a5b8-104fdde84c37
md"""
## Висновки

* В якості сховища даних використано DuckDB (in-process SQL OLAP database)

* В цій роботі узагальнено результати попередньої роботи, створено функції та словники запитів до бази даних

* Досліджено методи обробки текстових документів пакету TextAnalysis та на прикладі тексту лекції здійснено аналіз її тексту

* Завантажено в базу даних об'єкти категорій "Речення" та "Слово"

* Між об'єктом "Лекція 1" та її реченнями встановлено відношення "складається з"

В наступній роботі передбачається дослідити методи роботи з атрибутами

"""

# ╔═╡ 3265a9cc-7369-460f-a346-894ad78e9ffc
md"""
# Обов'язкова програма для атестації
"""

# ╔═╡ bd07605a-bd90-4e8b-b6f3-015926b2cbab
password = "work";

# ╔═╡ b9b59833-e208-4b65-ada1-7fafaff30a69
conn = LibPQ.Connection("host=localhost dbname=work user=work password=$password")

# ╔═╡ d8d7a277-e006-4ea7-a8f7-3908a7607d5e
md"""
#### Завантажемо раніше створені в PostrgreSQL дані "вітрини" в DataFrame
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

# ╔═╡ 20165d95-1bc9-4692-a8e4-8aaf17330bdd
md"""
#### OLAP запит типу CUBE створює агрегацію по всім комбінаціям вимірів
"""

# ╔═╡ d85e1d9e-b1d1-4958-9132-bf3e215dc8dd
DataFrame(DuckDB.execute(aserv,
"""
SELECT year, month, day, partner, terminal, type, SUM(amount)
FROM data
GROUP BY CUBE (year, month, day, partner, terminal, type);
"""
))

# ╔═╡ 79327798-fc80-48c2-b701-8da779ffe054
md"""
#### Сума оплат на ПТКС всього за визначений період
"""

# ╔═╡ 0c622919-bac1-4a8b-9721-b0dc53af5964
DataFrame(DuckDB.execute(aserv,
"""
SELECT month, terminal, SUM(amount)
FROM data
GROUP BY CUBE (year, month, day, partner, terminal, type)
HAVING year=2022 AND month=202212 AND day IS NULL AND partner IS NULL AND terminal IS NOT NULL AND type IS NULL;
"""
))

# ╔═╡ 4fecd641-adc8-418f-9cc8-0ff42c44c34e
md"""
#### Сума оплат на ПТКС за типами (готівка, карта) за визначений період
"""

# ╔═╡ cf6a76b0-d3cd-45a6-91a0-77e5b58b94cd
DataFrame(DuckDB.execute(aserv,
"""
SELECT month, terminal, type, SUM(amount)
FROM data
GROUP BY CUBE (year, month, day, partner, terminal, type)
HAVING year=2022 AND month=202212 AND day IS NULL AND partner IS NULL AND terminal IS NOT NULL AND type IS NOT NULL;
"""
))

# ╔═╡ 0a7ea3bc-69a8-48a9-9a6a-da82dec7c583
md"""
#### Сума оплат по партнеру за визначений період
"""

# ╔═╡ a8c2738c-5700-4484-822a-5eb27c4d9014
DataFrame(DuckDB.execute(aserv,
"""
SELECT month, partner, SUM(amount)
FROM data
GROUP BY CUBE (year, month, day, partner, terminal, type)
HAVING year=2022 AND month=202212 AND day IS NULL AND partner IS NOT NULL AND terminal IS NULL AND type IS NULL;
"""
))

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
DuckDB = "d2f5444f-75bc-4fdf-ac35-56f514c445e1"
Languages = "8ef0a80b-9436-5d2c-a485-80b904378c43"
LibPQ = "194296ae-ab2e-5f79-8cd4-7183a0a5a0d1"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
TextAnalysis = "a2db99b7-8b79-58f8-94bf-bbc811eef33d"

[compat]
CommonMark = "~0.8.7"
DataFrames = "~1.4.3"
DuckDB = "~0.6.0"
Languages = "~0.4.3"
LibPQ = "~1.14.1"
PlutoUI = "~0.7.49"
TextAnalysis = "~0.7.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "c780bf7d6a33d27650767c85ba479f6bbb5dae78"

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

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

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
git-tree-sha1 = "0f44494fe4271cc966ac4fea524111bef63ba86c"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.3"

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

[[deps.Decimals]]
git-tree-sha1 = "e98abef36d02a0ec385d68cd7dadbce9b28cbd88"
uuid = "abce61dc-4473-55a0-ba07-351d65e31d42"
version = "0.4.1"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

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
git-tree-sha1 = "cb5851972fbd3343ef830c07ea4d5d2fee731159"
uuid = "2cbbab25-fc8b-58cf-88d4-687a02676033"
version = "0.6.0+0"

[[deps.ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

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
git-tree-sha1 = "e1acc37ed078d99a714ed8376446f92a5535ca65"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.5.5"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

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

[[deps.Kerberos_krb5_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "60274b4ab38e8d1248216fe6b6ace75ae09b0502"
uuid = "b39eb1a6-c29a-53d7-8c32-632cd16f18da"
version = "1.19.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Languages]]
deps = ["InteractiveUtils", "JSON"]
git-tree-sha1 = "b1a564061268ccc3f3397ac0982983a657d4dcb8"
uuid = "8ef0a80b-9436-5d2c-a485-80b904378c43"
version = "0.4.3"

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

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "f71d8950b724e9ff6110fc948dff5a329f901d64"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.8"

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
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

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
git-tree-sha1 = "d8ed354439950b34ab04ff8f3dfd49e11bc6c94b"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.1"

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

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "18c35ed630d7229c5584b945641a73ca83fb5213"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.2"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

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

[[deps.TimeZones]]
deps = ["Dates", "Downloads", "InlineStrings", "LazyArtifacts", "Mocking", "Printf", "RecipesBase", "Scratch", "Unicode"]
git-tree-sha1 = "a92ec4466fc6e3dd704e2668b5e7f24add36d242"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.9.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

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
# ╟─d0fd59e4-d83d-4b18-8fd4-9781e171c3da
# ╟─829d12ee-d4cb-4555-b847-d0fa84b4f103
# ╠═ebdf79fe-70bb-11ed-1238-eb60f38082ec
# ╟─b13070b5-9875-45b6-a74e-1ed0f0c4a5fd
# ╟─d29ea611-2224-40b1-9619-21d5a25bac8a
# ╟─53f00c22-7243-448f-bea5-d6e4cf165b90
# ╟─ce44520a-ad21-4aa6-86f1-e46ffeed4b31
# ╠═54b57fcf-6f4d-4e9f-ac1d-a075a9f74507
# ╠═7910d7c5-0741-4fc2-ab71-a37a4f63e366
# ╠═c1409952-da5f-4b80-a28e-a717d3e99fdd
# ╠═d052f8bf-fd34-48dc-a19c-d634e74aa2bf
# ╠═ae939911-0f8b-429b-9ccb-90828431f5bd
# ╠═02e59024-01bd-470a-ae1e-caeeef8c001e
# ╠═ac8b2fcc-723a-4e81-99f0-2ac2f2d273a5
# ╟─11664dc4-89d1-42bd-8640-0ca7e80ca7e5
# ╠═48a1aed6-13bc-4e89-b4d7-b4f29da8c141
# ╠═fd276cd8-1ce7-431d-8e88-7e3d0b9e2294
# ╠═ab86f8cf-dde7-452c-b3d5-9ef1fdba6aa7
# ╠═f0ac46c9-3487-41ff-b84b-4bef00a0dd4a
# ╠═191d1d5f-dc33-4613-a2f6-2d4b59532cc4
# ╠═a6321bad-cdcb-4848-b81a-c84ea1a013af
# ╠═166cc9a6-7a6a-4087-82f8-a4d6deb6fdf4
# ╠═b5978aa3-b3b1-4dd3-8d8b-76ce9ec96ed4
# ╟─c973a571-aae8-4605-9e10-403aa030aef2
# ╠═38dcffdf-10e8-4ee9-867a-137e9a5b2075
# ╠═78ba976e-9a0e-4cbd-8bed-89a7d97d8fa3
# ╠═3d0d283c-36e2-4e9e-8c7a-c4094def901b
# ╟─b144d063-5f73-499b-9a57-adfce3f02530
# ╠═7b6a1ba7-49df-4b39-b851-1c97260ed3d8
# ╠═eecd09c7-c3a5-4352-8865-2e71b1892b89
# ╟─1e545f9f-d313-47de-b1ee-6a6b47ff9fcc
# ╠═6bcf1726-61fe-42cd-a83a-13b7eea257db
# ╠═ac146e13-9488-46c1-b549-a3f3ed63a82c
# ╟─ac223604-4179-4087-bfd3-dd88e099a115
# ╠═92f08f94-ab7d-46b6-ab80-e432ee159625
# ╠═6fc3d8d1-5ecb-4522-bbee-e83b5a1a0f4c
# ╠═95c3a544-28fe-49b7-9970-639ebd543948
# ╟─e18a6232-4787-4beb-9ea3-7f4d825068c7
# ╠═f5f2fa38-8d37-4a64-a7c1-c7f55e4a20be
# ╠═c1b74429-f394-476c-b179-726d1028d023
# ╟─22e6cf0a-9cf7-4c60-b45d-f3e2802cec2e
# ╠═de78718a-eeed-4901-a780-04b634095c97
# ╟─3cfba17f-8530-4f9a-8e19-33b787de1e08
# ╠═82a366c1-a45a-42fe-94c2-9e7125798ad1
# ╟─05364475-a0e9-4838-9d2e-9f916d5332de
# ╠═97e88798-2a9a-43df-8eee-d345dab2dc71
# ╠═589858aa-221b-4628-af75-b73b53003740
# ╠═3ee5b11b-a401-46ab-a69e-dfaf6850a8a7
# ╟─d0ef93a1-9efe-46a8-a6a3-658e95d25a36
# ╠═5e42f457-c4f8-4443-b62c-fd5681fabc2b
# ╟─7a1d293b-b3a2-4f2f-b037-22b1fee736c7
# ╠═ae0a009f-707a-4dba-87d4-d7dfcc787664
# ╟─67e7cca7-b8ca-4055-9195-149e6bdc7022
# ╠═5409aae1-c193-4aa2-9adc-d3758422aa56
# ╟─79ad3d2a-5596-45d6-9053-abb7bf651cac
# ╠═3771852e-2e70-4895-90b6-f62bc7dcfe4f
# ╟─70801f02-1399-4b2b-8767-3702cd72a618
# ╠═be7d2409-486d-4926-9ff2-5c1584a6cf0b
# ╟─22622a1e-2624-4804-a5b8-104fdde84c37
# ╟─3265a9cc-7369-460f-a346-894ad78e9ffc
# ╟─bd07605a-bd90-4e8b-b6f3-015926b2cbab
# ╠═b9b59833-e208-4b65-ada1-7fafaff30a69
# ╟─d8d7a277-e006-4ea7-a8f7-3908a7607d5e
# ╠═eb6a6518-744d-4939-9d09-d584c27fd783
# ╟─ee639081-787b-4abc-9ce0-a47b0e261377
# ╠═3d50750d-e8c2-443e-a463-6204bbe06113
# ╠═0a2102e5-e596-4cd6-b311-ff65b3e3b9e9
# ╟─20165d95-1bc9-4692-a8e4-8aaf17330bdd
# ╠═d85e1d9e-b1d1-4958-9132-bf3e215dc8dd
# ╟─79327798-fc80-48c2-b701-8da779ffe054
# ╠═0c622919-bac1-4a8b-9721-b0dc53af5964
# ╟─4fecd641-adc8-418f-9cc8-0ff42c44c34e
# ╠═cf6a76b0-d3cd-45a6-91a0-77e5b58b94cd
# ╟─0a7ea3bc-69a8-48a9-9a6a-da82dec7c583
# ╠═a8c2738c-5700-4484-822a-5eb27c4d9014
# ╟─9868a5e7-7ac7-462e-9977-733764cde5b4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
