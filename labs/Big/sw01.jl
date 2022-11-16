### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 03780044-60cd-11ed-3aa6-91cc7a824ebb
using CommonMark

# ╔═╡ a92e6922-aefb-458e-b9e2-e38bc5561cee
using PlutoUI, GZip, CSV, DataFrames, Dates, Distances, Clustering

# ╔═╡ 4593682c-68f2-43ed-a329-207c857cddff
using JSON

# ╔═╡ a38e49fd-e35d-408a-ab8f-adcca1dd932d
cm"""
---
<div align="center">

Національний університет біоресурсів і природокористування України

Факультет інформаційних технологій

Кафедра комп'ютерних наук

<br/><br/>

Курс: Big Datа

Самостійна робота 1


</div>

<br/><br/>

<div align="right">

Виконав

Студент групи ІУСТ-22001м

Харченко Юрій

</div>

<br/><br/>

<div align="center">

Київ – 2022

</div>

---
"""

# ╔═╡ 71a14f0b-2a8b-460d-8f2e-558857d1bacf
cm"""
#### В роботі використано мову Julia та її пакети
"""

# ╔═╡ 3492d0b8-14cd-4732-81a7-e1ae13c3edf6
TableOfContents()

# ╔═╡ 81418794-ee22-4791-8f7e-6f3eb5eb6c71
cm"""

## Курс: Big Datа, Самостійна робота 1

"""

# ╔═╡ 2a5dca40-e639-4d31-9716-609278cb72fa
cm"""

## Чому Julia

Сучасний мовний дизайн і методи компіляції дозволяють усунути компроміс продуктивності та забезпечити єдине середовище, достатньо продуктивне для створення прототипів і достатньо ефективне для розгортання високопродуктивних програм.

Мова програмування Julia виконує цю роль: це гнучка динамічна мова, яка підходить для наукових і чисельних обчислень, з продуктивністю, порівнянною з традиційними мовами зі статичними типами.

Julia має опціональну типізацію, множинну диспетчеризацію та продуктивність, досягнуту за допомогою виведення типу та JIT-компіляції, реалізованої за допомогою LLVM. 

Julia мультипарадигмальна, поєднує в собі риси імперативного, функціонального та об'єктно-орієнтованого програмування. Julia забезпечує легкість і виразність для чисельних обчислень високого рівня, як і такі мови, як R, MATLAB і Python, але також підтримує загальне програмування. Щоб досягти цього, Julia спирається на родовід мов математичного програмування, але також запозичує багато з популярних динамічних мов, зокрема Lisp, Perl, Python, Lua та Ruby.

### Що отримуємо

* Безкоштовний і відкритий код (ліцензія MIT)

* Визначені користувачем типи такі ж швидкі та компактні, як і вбудовані

* Немає необхідності векторизувати код для продуктивності; девекторизований код швидкий

* Призначений для паралелізму та розподілених обчислень

* Полегшене «зелене» потокування (coroutines)

* Ненав'язлива, але потужна система типів

* Елегантні та розширювані перетворення та просування для числових та інших типів

* Ефективна підтримка Unicode, включаючи, але не обмежуючись, UTF-8

* Безпосередній виклик функцій C (не потрібні обгортки чи спеціальні API)

* Потужні можливості, подібні до оболонки, для керування іншими процесами

* Lisp-подібні макроси та інші засоби метапрограмування

### Pluto notebook

Pluto — це не просто написання остаточного документа, він дає змогу експериментувати та досліджувати.

* реактивний - при зміні функції або змінної Pluto автоматично оновлює всі залежні комірки

* легкий -  написаний чистою Julia і простий в установці (тільки Julia і browser).

* простий - немає прихованого стану робочої області, дружній інтерфейс користувача

"""

# ╔═╡ dd3c25f2-bf6f-40e2-ab60-7156d993981c
cm"""

# Дослідження великих даних в галузі кібербезпеки

Об’єкт: системні журнали операційних систем, баз даних, фаєрволів тощо.

Предмет: обробка та аналіз великих даних системних журналів на предмет виявлення аномальних явищ.

Завдання: 
- дослідити сучасні методи обробки та аналізу великих масивів слабоструктурованої швидкозростаючої текстової інформації;
- зробити порівняння та визначити межі застосування сучасних інструментальних засобів;
- на основі обраних засобів розробити архітектуру та діючий прототип системи обробки та аналізу великих динамічних текстових даних;
- зформулювати висновки та пропозиції.
"""

# ╔═╡ 26a11a48-171c-491e-a999-985419d3592f
cm"""
### Створення інфраструктури
"""

# ╔═╡ 59412039-b416-4ab2-b62e-ca1469aa068c
cm"""

[Run Elastic stack (ELK) on Docker Containers with Docker Compose](https://computingforgeeks.com/run-elastic-stack-elk-on-docker/)

[https://github.com/deviantony/docker-elk](https://github.com/deviantony/docker-elk)

```bash
docker volume create --driver local \
     --opt type=none \
     --opt device=$HOME/Projects/elk/data/elasticsearch \
     --opt o=bind elasticsearch
```

```bash
docker volume create --driver local \
     --opt type=none \
     --opt device=$HOME/Projects/elk/data/setup \
     --opt o=bind setup
```

```bash
docker volume list
docker volume inspect elasticsearch
docker volume inspect setup
```

```bash
docker-compose up -d
```

```bash
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user elastic

docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user logstash_internal

docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user kibana_system
```
"""

# ╔═╡ 2315c9af-e26a-4b40-96a2-e8e8dc98b252
begin
	elastic_pwd = "MKZZ37E6QlFVisv0-u9S"
end;

# ╔═╡ db76199c-c256-4be6-88d3-f4160261b2d2
begin
	test_cmd = `curl http://localhost:9200 -u elastic:$elastic_pwd`
end;

# ╔═╡ 4cba6021-b3b5-4cd7-a5b9-0e9b7474f89a
#run(test_cmd);

# ╔═╡ 6b0a0f4f-98d9-4094-ad94-ffef7d86f345
cm"""
#### Kibana
[http://localhost:5601](http://localhost:5601)
"""

# ╔═╡ 79fd8aa5-456b-4eca-a069-ccca4686fbef
cm"""
# Аналіз даних журналу доступу до web-сервера
"""

# ╔═╡ a4c02814-4f91-40e9-92e9-28db74fc4c08
header=["ip","f1","f2","ts","met","ret","nb","f4","br"]

# ╔═╡ 3ea6e214-b36e-46a2-bff0-6c13d8009749
cm"""
### Завантаження групи файлів журналу в DataFrame
"""

# ╔═╡ 1b7a082b-eb24-44b7-9976-4bcf91734c1c
log = let
	logs_dir = joinpath("logs", "nginx")
	files = []
	records = String[]
	log = []
	for file in filter(x -> occursin("access", x) && occursin("gz", x), readdir(logs_dir, join=true))
		push!(files, file)
		fh = GZip.open(file)
		append!(records, readlines(fh))
	end
	
	for file in filter(x -> occursin("access", x) && !occursin("gz", x), readdir(logs_dir, join=true))
		push!(files, file)
		fh = open(file)
		append!(records, readlines(fh))
	end
	
	types=[String,String,String,DateTime,String,Int,Int,String,String]
	CSV.File(IOBuffer.(records); header=header, delim=' ',types=types, silencewarnings=true, dateformat="[d/u/yyyy:H:M:S +0000]") |> DataFrame
	
end

# ╔═╡ f785ad21-4a37-44b0-b2cc-8e6cfc70b41f
cm"""
### Групування та розрахунок статистичних показників за номінальними факторми

* count - кількість записів в групі

* part - відносна частка групи

* gridx - ідентифікатор групи

"""

# ╔═╡ 55fa32f1-96ca-4dc3-a5e9-67853a29503b
work_set = ["ip","met","ret","br"]

# ╔═╡ 815cd289-53c4-4c1f-b911-7747624985a9
D = let
	d = Dict()
	for i in eachindex(work_set)
		f = work_set[i]
		fd = Dict()
		wdf = combine(groupby(log, [Symbol(f)]),nrow=>:count,proprow=>:part, groupindices=>:gridx)
		fd["wdf"] = wdf
		d[f] = fd
		for j in (i+1):length(work_set)
			f2 = work_set[j]
			fd2 = Dict()
			wdf2 = combine(groupby(log, [Symbol(f), Symbol(f2)]),nrow=>:count,proprow=>:part, groupindices=>:gridx)
			fd2["wdf"] = wdf2
			d[f*"-"*f2] = fd2
		end
	end
	d
end;

# ╔═╡ 92a22022-993d-4bc5-a22a-95eaeaa7fea8
sort(D["ip"]["wdf"], [order(:count, rev=true)])

# ╔═╡ 62687dc4-326d-4c0e-8019-ce642ca607a2
sort(D["met"]["wdf"], [order(:count, rev=true)])

# ╔═╡ 833ff012-7ca1-4e47-9267-06791c4cacfc
sort(D["ret"]["wdf"], [order(:count, rev=true)])

# ╔═╡ 8e18e78c-80cc-4c6c-8d9f-0b7fdfd17bfe
sort(D["br"]["wdf"], [order(:count, rev=true)])

# ╔═╡ 734973ce-f051-4aff-b584-ed81c1ca654b
cm"""
### Аналіз зв'язку між номінальними факторами

d - оцінка зв'язку (додатнє значення - зв'язок позитивний, від'ємне - негативний)

"""

# ╔═╡ f4551c81-91c8-4793-8a58-3d16a1d69178
function get_mat_p(d, name_a, name_b)
	a = d[name_a]["wdf"]
	b = d[name_b]["wdf"]
	ab = d[name_a*"-"*name_b]["wdf"]
	
	dict_a = Dict(zip(a[!, name_a], a[!, "gridx"]))
	dict_b = Dict(zip(b[!, name_b], b[!, "gridx"]))
	
	pa = Vector{Float64}(undef, nrow(ab))
	pb = Vector{Float64}(undef, nrow(ab))
	papb = Vector{Float64}(undef, nrow(ab))
	d = Vector{Float64}(undef, nrow(ab))
	for i in 1:nrow(ab)
		pab = ab[i, "part"]
		pa[i] = a[dict_a[ab[i, name_a]], "part"]
		pb[i] = b[dict_b[ab[i, name_b]], "part"]
		papb[i] = pa[i]*pb[i]
		d[i] = pab-papb[i]
				
	end
	DataFrame(d=d, pab=ab[!, "part"], papb=papb, pa=pa, pb=pb, a=ab[!, name_a], b=ab[!, name_b])

end

# ╔═╡ e02308fa-7968-4361-9202-224d7130057e
sort(get_mat_p(D, "ret", "br"), [order(:d, rev=true)])

# ╔═╡ a39fbe0d-647b-41d3-a67d-dd6bd72f1d50
sort(get_mat_p(D, "ret", "br"), [order(:d)])

# ╔═╡ 62da3b5d-a001-4e96-a8fc-afd2e827f5b3
sort(get_mat_p(D, "ip", "met"), [order(:d, rev=true)])

# ╔═╡ 77858391-38cd-41ad-afde-8592ef5edbc4
sort(get_mat_p(D, "ip", "met"), [order(:d)])

# ╔═╡ fd9c3ac2-5f39-4ce1-8845-2e1090b6ad75
sort(get_mat_p(D, "ip", "ret"), [order(:d, rev=true)])

# ╔═╡ dd779ab5-a48f-4291-b154-d1e43c6bfd71
sort(get_mat_p(D, "ip", "ret"), [order(:d)])

# ╔═╡ b126ee3c-53a2-4f08-8e48-549ac26fbc31
sort(get_mat_p(D, "ip", "br"), [order(:d, rev=true)])

# ╔═╡ 94a0e9fe-30bf-47ec-ab76-31b11b20d642
sort(get_mat_p(D, "ip", "br"), [order(:d)])

# ╔═╡ 164fb9fb-3494-4a06-87cc-23da2cae10f4
sort(get_mat_p(D, "met", "ret"), [order(:d, rev=true)])

# ╔═╡ c2cee242-80f2-4248-918e-b889e6d52551
sort(get_mat_p(D, "met", "ret"))

# ╔═╡ 4b369eb9-8020-4406-934a-f09e279b399a
sort(get_mat_p(D, "met", "br"), [order(:d, rev=true)])

# ╔═╡ 6859b78d-62c3-439e-bb10-0da6c6902bc8
sort(get_mat_p(D, "met", "br"), [order(:d)])

# ╔═╡ 9c106d60-ee95-447a-a5c6-727c1e65277e
cm"""
### Побудова дерева процесу доступу до сервера у вигляді json-файлу
"""

# ╔═╡ ae5aab68-466d-4e58-872e-35152d7e5d10
function make_tree(list, pos, path=[])
	
	if pos > length(list)
		return nothing
	end
	
	tree = Dict()
	if pos == 1
		if length(path) == 0
			l = combine(groupby(log, list[1:pos]),nrow=>:count)
		else
			l = filter(x -> x[list[pos]] == path, combine(groupby(log, list[1:pos]),nrow=>:count))
		end
		for i in 1:nrow(l)
			tree[l[i, list[pos]]] = 
				make_tree(list, pos+1, push!(copy(path), l[i, list[pos]]))
		end
	else
		l = filter(x -> all([x[i] for i in list[1:pos-1]] .== path), 
			combine(groupby(log, list[1:pos]),nrow=>:count))
		for i in 1:nrow(l)
			tree[l[i,  list[pos]]] = 
					make_tree(list, pos+1, push!(copy(path), l[i,  list[pos]]))
		end
	end
	tree
end

# ╔═╡ 5e792cfd-ec34-4a6a-82b3-f3437766d8cd
let
	tree = make_tree(["ip", "br", "met", "ret"], 1)
	open("tree.json","w") do f
  		JSON.print(f, tree)
	end
end

# ╔═╡ ed829a74-d3ec-47f0-b1fe-f986026fa0bc
cm"""
### Побудова матриці відстаней між записами журналу за метрикою Хемінга 
"""

# ╔═╡ bc5d1bd1-ebbc-4b9e-ae81-0eb586ade364
Dist = let 
	pairwise(Hamming(), Matrix(select(log, [work_set]...)), dims=1)
end

# ╔═╡ a18c9319-32ee-4739-85e0-4b6ee91abfa0
cm"""
### Ієрархічна кластеризація записів журналу
[https://en.wikipedia.org/wiki/Hierarchical_clustering](https://en.wikipedia.org/wiki/Hierarchical_clustering)
"""

# ╔═╡ 832a6f15-d14e-4009-b33d-a7db9895b0d5
clus = cutree(hclust(Dist); k = 20 )

# ╔═╡ 45443e51-1e94-4068-a5ce-aac31cf09403
combine(groupby(DataFrame(c = clus), [:c]),nrow=>:count)

# ╔═╡ 6dd2f255-52da-4786-9b04-9e8b37da205d
cm"""
### Кластеризація записів журналу методом K-medoids
[https://en.wikipedia.org/wiki/K-medoids](https://en.wikipedia.org/wiki/K-medoids)
"""

# ╔═╡ fd4e30f6-6cc7-45ab-a9c1-1a6eed3eec25
kmedoids(Dist, 20).counts

# ╔═╡ a31ccb7f-885d-4b98-bf05-ea78195d9fb0
cm"""
## Висновки

Використовуючі мову Julia та її пакети було визначено можливість їх застосування до первинного аналізу великих даних

Було розраховано частоти номінальних факторів, зв'язок між номінальними факторами, відстані між записами за метрикою Хемінга, зроблена спроба ієрархічної кластеризації та кластеризації за методом K-medoids

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
Clustering = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Distances = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
GZip = "92fee26a-97fe-5a0c-ad85-20a5f3185b63"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CSV = "~0.10.7"
Clustering = "~0.14.3"
CommonMark = "~0.8.6"
DataFrames = "~1.4.2"
Distances = "~0.10.7"
GZip = "~0.5.1"
JSON = "~0.21.3"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "c5fd7cd27ac4aed0acf4b73948f0110ff2a854b2"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.7"

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

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "4cd7063c9bdebdbd55ede1af70f3c2f48fab4215"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.6"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "5b93f1b47eec9b7194814e40542752418546679f"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.2"

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

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

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

[[deps.GZip]]
deps = ["Libdl"]
git-tree-sha1 = "039be665faf0b8ae36e089cd694233f5dee3f7d6"
uuid = "92fee26a-97fe-5a0c-ad85-20a5f3185b63"
version = "0.5.1"

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

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "b5081bd8a53eeb6a2ef956751343ab44543023fb"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.3.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

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

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "440165bf08bc500b8fe4a7be2dc83271a00c0716"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "cceb0257b662528ecdf0b4b4302eb00e767b38e7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "98ac42c9127667c2731072464fcfef9b819ce2fa"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

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

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "efd23b378ea5f2db53a55ae53d3133de4e080aa9"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.16"

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
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "f86b3a049e5d05227b10e15dbb315c5b90f14988"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.9"

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

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

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

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

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

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─03780044-60cd-11ed-3aa6-91cc7a824ebb
# ╟─a38e49fd-e35d-408a-ab8f-adcca1dd932d
# ╟─71a14f0b-2a8b-460d-8f2e-558857d1bacf
# ╠═a92e6922-aefb-458e-b9e2-e38bc5561cee
# ╟─3492d0b8-14cd-4732-81a7-e1ae13c3edf6
# ╟─81418794-ee22-4791-8f7e-6f3eb5eb6c71
# ╟─2a5dca40-e639-4d31-9716-609278cb72fa
# ╟─dd3c25f2-bf6f-40e2-ab60-7156d993981c
# ╟─26a11a48-171c-491e-a999-985419d3592f
# ╟─59412039-b416-4ab2-b62e-ca1469aa068c
# ╟─2315c9af-e26a-4b40-96a2-e8e8dc98b252
# ╠═db76199c-c256-4be6-88d3-f4160261b2d2
# ╠═4cba6021-b3b5-4cd7-a5b9-0e9b7474f89a
# ╟─6b0a0f4f-98d9-4094-ad94-ffef7d86f345
# ╟─79fd8aa5-456b-4eca-a069-ccca4686fbef
# ╠═a4c02814-4f91-40e9-92e9-28db74fc4c08
# ╠═3ea6e214-b36e-46a2-bff0-6c13d8009749
# ╠═1b7a082b-eb24-44b7-9976-4bcf91734c1c
# ╟─f785ad21-4a37-44b0-b2cc-8e6cfc70b41f
# ╠═55fa32f1-96ca-4dc3-a5e9-67853a29503b
# ╠═815cd289-53c4-4c1f-b911-7747624985a9
# ╠═92a22022-993d-4bc5-a22a-95eaeaa7fea8
# ╠═62687dc4-326d-4c0e-8019-ce642ca607a2
# ╠═833ff012-7ca1-4e47-9267-06791c4cacfc
# ╠═8e18e78c-80cc-4c6c-8d9f-0b7fdfd17bfe
# ╟─734973ce-f051-4aff-b584-ed81c1ca654b
# ╠═f4551c81-91c8-4793-8a58-3d16a1d69178
# ╠═e02308fa-7968-4361-9202-224d7130057e
# ╠═a39fbe0d-647b-41d3-a67d-dd6bd72f1d50
# ╠═62da3b5d-a001-4e96-a8fc-afd2e827f5b3
# ╠═77858391-38cd-41ad-afde-8592ef5edbc4
# ╠═fd9c3ac2-5f39-4ce1-8845-2e1090b6ad75
# ╠═dd779ab5-a48f-4291-b154-d1e43c6bfd71
# ╠═b126ee3c-53a2-4f08-8e48-549ac26fbc31
# ╠═94a0e9fe-30bf-47ec-ab76-31b11b20d642
# ╠═164fb9fb-3494-4a06-87cc-23da2cae10f4
# ╠═c2cee242-80f2-4248-918e-b889e6d52551
# ╠═4b369eb9-8020-4406-934a-f09e279b399a
# ╠═6859b78d-62c3-439e-bb10-0da6c6902bc8
# ╟─9c106d60-ee95-447a-a5c6-727c1e65277e
# ╠═ae5aab68-466d-4e58-872e-35152d7e5d10
# ╠═4593682c-68f2-43ed-a329-207c857cddff
# ╠═5e792cfd-ec34-4a6a-82b3-f3437766d8cd
# ╟─ed829a74-d3ec-47f0-b1fe-f986026fa0bc
# ╠═bc5d1bd1-ebbc-4b9e-ae81-0eb586ade364
# ╟─a18c9319-32ee-4739-85e0-4b6ee91abfa0
# ╠═832a6f15-d14e-4009-b33d-a7db9895b0d5
# ╠═45443e51-1e94-4068-a5ce-aac31cf09403
# ╟─6dd2f255-52da-4786-9b04-9e8b37da205d
# ╠═fd4e30f6-6cc7-45ab-a9c1-1a6eed3eec25
# ╟─a31ccb7f-885d-4b98-bf05-ea78195d9fb0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
