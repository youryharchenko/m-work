### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ ebdf79fe-70bb-11ed-1238-eb60f38082ec
using DuckDB, PlutoUI, CommonMark,  DataFrames, LibPQ, Julog

# ╔═╡ f622df43-b3f5-45f2-99e8-e6c35066fb00
using Dates, Random, Statistics

# ╔═╡ d0fd59e4-d83d-4b18-8fd4-9781e171c3da
cm"""
---

<div align="center">

Національний університет біоресурсів і природокористування України

Факультет інформаційних технологій

Кафедра комп'ютерних наук

<br/><br/>

Лабораторна робота 6

Побудова звітів

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
## Запити до бази знань логічного програмуваня
"""

# ╔═╡ e18a6232-4787-4beb-9ea3-7f4d825068c7
md"""
#### Допоміжні функції
"""

# ╔═╡ 4d69bf7f-d176-4bd2-a672-ceac797fc437
function select(db, table)
	DataFrame(DuckDB.execute(db, "SELECT * FROM $table"))
end

# ╔═╡ 92a446a0-dfbe-40b2-bb2b-bffebaa3dfc7
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

# ╔═╡ 784e2951-fb3f-4b58-93a3-e9c89c5c578f
md"""
#### Відкриваємо базу даних, створену в попередній роботі
"""

# ╔═╡ de9cfca4-d2aa-4295-a6b1-445eb1cb7535
begin
	db = DuckDB.open("semantic.duckdb")
end

# ╔═╡ eb7f8617-0501-422b-a3da-28fda0e95fc9
tables = [:V, :A, :C, :R, :RC, :O, :CO, :RCO, :AC, :AR, :ARC, :ACO, :ARCO]

# ╔═╡ db281e66-b141-4a4a-bdd8-b2bff3d433b8
md"""
#### Перетвороюємо базу даних в базу знань логічного програмування
"""

# ╔═╡ 66a2073f-713b-49ad-90c6-27ccf92a7e4c
clauses = let 
	cl = Clause[]
	for t in tables
		cl = vcat(cl, table2clauses(db, t))
	end
	cl
end 

# ╔═╡ 7f2c38e7-ee11-4876-8f3d-357547e7aee4
md"""
#### Створюємо логічні правила для запитів до бази знань
"""

# ╔═╡ f0d774e3-a5bc-4f71-99ad-00255c10bc5d
rules = @julog [
	Attr(ID, Name) <<= A(ID, V) & V(V, Name, _),
	Cat(ID, Name) <<= C(ID, V) & V(V, Name, _),
	Rel(ID, Name) <<= R(ID, V) & V(V, Name, _),
	Obj(ID, Name) <<= O(ID, _, V) & V(V, Name, _),
	
	CatObj(ID, CatID, ObjID, CatName, ObjName) <<= 
		CO(ID, CatID, ObjID,) & Cat(CatID, CatName) & Obj(ObjID, ObjName),
	
	RelCat(ID, RelID, CatFromID, CatToID, RelName, CatFromName, CatToName) <<= 
		RC(ID, RelID, CatFromID, CatToID) & Rel(RelID, RelName) & Cat(CatFromID, CatFromName) & Cat(CatToID, CatToName),
	
	RelCatObj(ID, RelCatID, CatFromID, ObjFromID, CatToID, ObjToID, RelName, 	CatFromName, ObjFromName, CatToName, ObjToName) <<= 
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
		ARCO(ID, RelCatObjID, AttrID, ValueID) & RelCatObj(RelCatObjID, RelCatID, CatFromID, ObjFromID, CatToID, ObjToID, RelName, CatFromName, ObjFromName, CatToName, ObjToName)  & Attr(AttrID, AttrName) & V(ValueID, Value, _)
	
]

# ╔═╡ 0d5f5091-972f-4b27-ab01-da4fa02cc3e8
md"""
#### Об'єднуємо факти і правила в єдину базу знань
"""

# ╔═╡ bac14b50-7698-4f35-8c5f-322f20e5b7f7
kb = vcat(clauses, rules)

# ╔═╡ 5bb383f3-59b4-40dc-91d4-e58155f52e60
md"""
#### Виконуємо тестові запити до бази знань, використовуючи створені правила
"""

# ╔═╡ 8a700216-0ceb-4bba-8264-3adf35f61532
resolve(@julog([Attr(ID, Name)]), kb)

# ╔═╡ 2992cbab-844b-453f-bacd-9ba68cbbba68
resolve(@julog([Cat(ID, Name)]), kb)

# ╔═╡ 619956bc-e09f-4b5c-a90e-536098007bed
resolve(@julog([Rel(ID, Name)]), kb)

# ╔═╡ 9cbcf713-4591-4b6a-8b0a-96e48bc7efb1
resolve(@julog([Obj(ID, Name)]), kb)

# ╔═╡ e2d9bcbb-bd94-4582-98cf-aadbabf957ef
resolve(@julog([CatObj(ID, CatID, ObjID, CatName, ObjName)]), kb)

# ╔═╡ 8ecca0e3-bb7c-49cd-85ef-13e4e674de7f
resolve(@julog([RelCat(ID, RelID, CatFromID, CatToID, RelName, CatFromName, CatToName)]), kb)

# ╔═╡ cc657154-7544-4b75-b36c-50a6682eb4f9
resolve(@julog([RelCatObj(ID, RelCatID, CatFromID, ObjFromID, CatToID, ObjToID, RelName, CatFromName, ObjFromName, CatToName, ObjToName)]), kb)

# ╔═╡ 7df6e48a-9337-45c1-9d11-22144800d42b
resolve(@julog([AttrCat(ID, CatID, AttrID, ValueID, CatName, AttrName, Value)]), kb)

# ╔═╡ 15c3fdeb-62b2-4a84-bac5-ff8a85fb3c6a
resolve(@julog([AttrCatObj(ID, CatObjID, CatID, ObjID, AttrID, ValueID, CatName, ObjName, AttrName, Value)]), kb)

# ╔═╡ e86469e9-7a28-4480-9172-8c98ac26e8b4
resolve(@julog([AttrRel(ID, RelID, AttrID, ValueID, RelName, AttrName, Value)]), kb)

# ╔═╡ 5e6f9a3b-fd55-482f-8e67-af2ca83e12c0
resolve(@julog([AttrRelCat(ID, RelCatID, RelID, CatFromID, CatToID, AttrID, ValueID, RelName, CatFromName, CatToName, AttrName, Value)]), kb)

# ╔═╡ c083ebac-3eba-4518-aab6-d148582bd2d1
resolve(@julog([AttrRelCatObj(ID, RelCatObjID, RelID, CatFromID, ObjFromID, CatToID, ObjToID, AttrID, ValueID, RelName, CatFromName, ObjFromName, CatToName, ObjToName, AttrName, Value)]), kb)

# ╔═╡ 22622a1e-2624-4804-a5b8-104fdde84c37
md"""
## Висновки

* Створено базу знань, як систему фактів та правил  

* Система дозволяє повноцінний доступ до бази знань методами логічного програмування 

Цією роботою завершено перший етап побудови інтелектуального програмного агента заснованого на знаннях

Далі буде

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
### Аналіз багатовимірних даних
"""

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
aserv = let
	db = DuckDB.open(":memory:")
	DuckDB.register_data_frame(db, data, "data")
	
	db
end

# ╔═╡ b1473cc5-251f-40fb-8e4f-d6ff41a40609
md"""
#### Експортуємо створену таблицю в Parquet файл [[7]](https://parquet.apache.org/)
"""

# ╔═╡ aebe6888-b4e7-4db0-b1b7-9e94d5042102
DataFrame(DuckDB.execute(aserv, "COPY (SELECT * FROM data) TO 'data.parquet' (FORMAT 'parquet')"))

# ╔═╡ 79327798-fc80-48c2-b701-8da779ffe054
md"""
### Приклад аналізу багатовимірних даних [[6]](https://www.tadviewer.com/)
"""

# ╔═╡ 4ea95d3f-9aec-4288-9fc5-a93702312d0c
LocalResource("tad01.png")

# ╔═╡ a80fc710-d1db-4dba-ab25-cab50279f75c
LocalResource("tad02.png")

# ╔═╡ 9868a5e7-7ac7-462e-9977-733764cde5b4
md"""
# Використані джерела

1. The Julia Programming Language - [https://julialang.org/](https://julialang.org/)
1. The Rise and Fall of the OLAP Cube - [https://www.holistics.io/blog/the-rise-and-fall-of-the-olap-cube/](https://www.holistics.io/blog/the-rise-and-fall-of-the-olap-cube/)
1. OLAP != OLAP Cube - [https://www.holistics.io/blog/olap-is-not-olap-cube/](https://www.holistics.io/blog/olap-is-not-olap-cube/)
1. Column-oriented DBMS - [https://en.wikipedia.org/wiki/Column-oriented_DBMS](https://en.wikipedia.org/wiki/Column-oriented_DBMS)
1. DuckDB is an in-process SQL OLAP database management system - [https://duckdb.org/](https://duckdb.org/)
1. Tad - A Tabular Data Viewer - [https://www.tadviewer.com/](https://www.tadviewer.com/)
1. Apache Parquet is a column-oriented data file format - [https://parquet.apache.org/](https://parquet.apache.org/)

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
DuckDB = "d2f5444f-75bc-4fdf-ac35-56f514c445e1"
Julog = "5d8bcb5e-2b2c-4a96-a2b1-d40b3d3c344f"
LibPQ = "194296ae-ab2e-5f79-8cd4-7183a0a5a0d1"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
CommonMark = "~0.8.7"
DataFrames = "~1.4.4"
DuckDB = "~0.6.0"
Julog = "~0.1.15"
LibPQ = "~1.14.1"
PlutoUI = "~0.7.49"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "e20dd1a7daf4dc9f7d228a43a5058fa3dfbe2dc7"

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

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

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

[[deps.Decimals]]
git-tree-sha1 = "e98abef36d02a0ec385d68cd7dadbce9b28cbd88"
uuid = "abce61dc-4473-55a0-ba07-351d65e31d42"
version = "0.4.1"

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

[[deps.InvertedIndices]]
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

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

[[deps.Julog]]
git-tree-sha1 = "191e4f6de2ddf2dc60d5d90c412d066814f1655b"
uuid = "5d8bcb5e-2b2c-4a96-a2b1-d40b3d3c344f"
version = "0.1.15"

[[deps.Kerberos_krb5_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "60274b4ab38e8d1248216fe6b6ace75ae09b0502"
uuid = "b39eb1a6-c29a-53d7-8c32-632cd16f18da"
version = "1.19.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

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

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

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
git-tree-sha1 = "96f6db03ab535bdb901300f88335257b0018689d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

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

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

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

[[deps.TimeZones]]
deps = ["Dates", "Downloads", "InlineStrings", "LazyArtifacts", "Mocking", "Printf", "RecipesBase", "Scratch", "Unicode"]
git-tree-sha1 = "a92ec4466fc6e3dd704e2668b5e7f24add36d242"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.9.1"

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
# ╟─e18a6232-4787-4beb-9ea3-7f4d825068c7
# ╠═4d69bf7f-d176-4bd2-a672-ceac797fc437
# ╠═92a446a0-dfbe-40b2-bb2b-bffebaa3dfc7
# ╟─784e2951-fb3f-4b58-93a3-e9c89c5c578f
# ╠═de9cfca4-d2aa-4295-a6b1-445eb1cb7535
# ╠═eb7f8617-0501-422b-a3da-28fda0e95fc9
# ╟─db281e66-b141-4a4a-bdd8-b2bff3d433b8
# ╠═66a2073f-713b-49ad-90c6-27ccf92a7e4c
# ╟─7f2c38e7-ee11-4876-8f3d-357547e7aee4
# ╠═f0d774e3-a5bc-4f71-99ad-00255c10bc5d
# ╟─0d5f5091-972f-4b27-ab01-da4fa02cc3e8
# ╠═bac14b50-7698-4f35-8c5f-322f20e5b7f7
# ╟─5bb383f3-59b4-40dc-91d4-e58155f52e60
# ╠═8a700216-0ceb-4bba-8264-3adf35f61532
# ╠═2992cbab-844b-453f-bacd-9ba68cbbba68
# ╠═619956bc-e09f-4b5c-a90e-536098007bed
# ╠═9cbcf713-4591-4b6a-8b0a-96e48bc7efb1
# ╠═e2d9bcbb-bd94-4582-98cf-aadbabf957ef
# ╠═8ecca0e3-bb7c-49cd-85ef-13e4e674de7f
# ╠═cc657154-7544-4b75-b36c-50a6682eb4f9
# ╠═7df6e48a-9337-45c1-9d11-22144800d42b
# ╠═15c3fdeb-62b2-4a84-bac5-ff8a85fb3c6a
# ╠═e86469e9-7a28-4480-9172-8c98ac26e8b4
# ╠═5e6f9a3b-fd55-482f-8e67-af2ca83e12c0
# ╠═c083ebac-3eba-4518-aab6-d148582bd2d1
# ╟─22622a1e-2624-4804-a5b8-104fdde84c37
# ╟─3265a9cc-7369-460f-a346-894ad78e9ffc
# ╠═f622df43-b3f5-45f2-99e8-e6c35066fb00
# ╟─bd07605a-bd90-4e8b-b6f3-015926b2cbab
# ╠═b9b59833-e208-4b65-ada1-7fafaff30a69
# ╟─65df63f8-2f6e-40fb-a5b4-6004daa910f3
# ╟─d8d7a277-e006-4ea7-a8f7-3908a7607d5e
# ╠═eb6a6518-744d-4939-9d09-d584c27fd783
# ╟─ee639081-787b-4abc-9ce0-a47b0e261377
# ╠═3d50750d-e8c2-443e-a463-6204bbe06113
# ╟─b1473cc5-251f-40fb-8e4f-d6ff41a40609
# ╠═aebe6888-b4e7-4db0-b1b7-9e94d5042102
# ╟─79327798-fc80-48c2-b701-8da779ffe054
# ╠═4ea95d3f-9aec-4288-9fc5-a93702312d0c
# ╠═a80fc710-d1db-4dba-ab25-cab50279f75c
# ╟─9868a5e7-7ac7-462e-9977-733764cde5b4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
