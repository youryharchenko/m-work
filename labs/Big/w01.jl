### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 5532c8ae-56af-11ed-0aa8-77b63a70d31f
using CommonMark

# ╔═╡ 6920de4c-2bf1-452f-ba22-63496ce0fc7d
using JuliaDB, Distributions, Dates, OnlineStats, StatsPlots, GLM, DataFrames

# ╔═╡ 913ad607-557c-4395-98e9-82b4f547034b
cm"""
---
<div align="center">

Національний університет біоресурсів і природокористування України

Факультет інформаційних технологій

Кафедра комп'ютерних наук

<br/><br/>

Курс: Big Datа

Лабораторна робота 1


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

# ╔═╡ 172dac67-58b1-48c9-98fe-cf0a3f88c9e0
cm"""

#### В роботі використано мову Julia та її пакети

"""

# ╔═╡ b4658d90-7d03-4105-ae1c-77b4a7c2d714
cm"""
#### Створюємо фіктивні щосекундні дані про серцебиття за рік
"""

# ╔═╡ 4b8c9bc4-0684-4e59-8f76-0f77578078d3
start_dt = Dates.DateTime(Dates.now())

# ╔═╡ 648a7e2c-540c-43fb-9ef6-e5cda79db22c
end_dt = Dates.DateTime(Dates.now() + Dates.Year(1))

# ╔═╡ b3e980a1-214e-447a-826e-5bf8e2c63bd6
dates = collect(start_dt:Dates.Second(1):end_dt)

# ╔═╡ 272bda1f-de7a-43ca-9cb1-33459d1c6e87
hr = round.(Int64, rand(Normal(90,10),length(dates)))

# ╔═╡ 586f4ef6-c475-4cbc-a0cf-0dec79a87853
hr_tracker = table(dates, hr, names=[:date, :hr], pkey=:date)

# ╔═╡ 845100f7-3478-4625-81d6-dfd05794fdf4
td_all = @timed hr_tracker[1:end]

# ╔═╡ 66dfb7c7-d354-4754-b6ce-b9411bee7d91
cm"""
#### Всього вийшло $(length(hr_tracker)) ($(round(length(hr_tracker)/10^6, digits=4)) млн) записів
"""

# ╔═╡ 95529864-501b-467f-9ab8-012964e5e43b
cm"""
#### Сформуємо вектор розмірів вибірок 
"""

# ╔═╡ 75d8ee41-c08f-4199-a8f0-cc46a382b042
size = collect(1000:1000:5001)

# ╔═╡ 06d906c3-cded-45e3-a3c9-a250c2cdd406
cm"""
#### Зробимо вибірки та отримаємо вектор значень часу процессора на кожний варіант вибірки
"""

# ╔═╡ 42ac0b0f-6fa4-4660-9da4-529fcb593e79
td_select = Vector{Any}(undef, length(size))

# ╔═╡ 58085635-fd4d-4fab-89f1-bc4de7dc7b79
for i in eachindex(size)
	s = size[i]
	td_select[i] = @timed hr_tracker[s+1:s*s+s]
end

# ╔═╡ acfb96bd-b4db-45a2-9521-30f9eda430cf
times_select = [x.time for x in td_select]

# ╔═╡ 5876cd06-485c-45bf-9ade-29b5237c2ca9
cm"""
#### Зобразимо отримані результати на графіку
"""

# ╔═╡ cfdc736f-65b9-4204-affc-4b487b5bc289
scatter(size.^2/10^6, times_select, xlabel="Records, mil", ylabel="Time, s", label="Select")

# ╔═╡ 64fc48bc-eb1c-481c-bff2-8c474b415b75
cm"""
#### Розрахуємр для отриманих вибірок статистичні показники (середнє, варіацію, мінімум, максимум) та отримаємо вектор значень часу процессора на кожний варіант розрахунку
"""

# ╔═╡ b9a0061c-3865-4836-a110-7a026ab312fa
td_proc = Vector{Any}(undef, length(size))

# ╔═╡ 00a9a72b-d456-469f-b33f-2e24246227e0
o = Series(Mean(), Variance(), Extrema())

# ╔═╡ 14361b4a-5de1-4e7c-bb57-6a340564697b
for i in eachindex(size)
	td_proc[i] = @timed reduce(o, td_select[i].value; select = 2)
end

# ╔═╡ 50a2ecdb-0a58-4774-a6a3-848ec048ab04
times_proc = [x.time for x in td_proc]

# ╔═╡ a3cc9600-64a2-4857-bd6c-7a40af715ae4
cm"""
#### Зобразимо отримані результати на графіку
"""

# ╔═╡ 979b5b8c-f3b6-4936-8e29-ae123fe33a1e
scatter(size.^2/10^6, times_proc, xlabel="Records, mil", ylabel="Time, s", label="Process")

# ╔═╡ 42b925fe-06f0-40e1-8fad-2115ffc8b1a3
cm"""
#### Зобразимо на графіку суму значень часу на вибірку і розрахунок
"""

# ╔═╡ 5a4a181b-3f48-4355-849b-913519a1dac0
scatter(size.^2/10^6, times_select.+times_proc, xlabel="Records, mil", ylabel="Time, s", label="Select+Process")

# ╔═╡ 1f8c96fc-07be-42d7-a3ac-7372113d66f2
cm"""
#### Побудуємо ріняння лінійної регресії для отриманих результатів: залежна змінна сумарний час в секундах, незалежна - розмір вибірки в млн.
"""

# ╔═╡ 2ae328d3-a8fa-4167-a1ab-fa0e11e43e0f
model = lm(@formula(time ~ 1 + records), DataFrame(time = times_select.+times_proc, records = size.^2/10^6))

# ╔═╡ 90fb875c-d034-4d46-bfb7-779ea7b079d7
cs = coef(model)

# ╔═╡ 96f67604-5f92-4cc0-b6fe-df16ddf5bfff
pred = cs[1] + 6^2 * cs[2]

# ╔═╡ 934f813c-e235-465b-967a-8cd5fc1b5318
cm"""
#### За отриманим рівнянням розрахуємо прогноз часу для вибірки розміром 36 млн записів: $(round(pred, digits=2)) сек
"""

# ╔═╡ cd1e54b1-075d-4bd4-81d4-b734d5d733ea
cm"""
#### Висновок. Дослідження показало, що на заданому діпазоні значень між розміром вибірки та процесорним часом розрахунку показників існує зв'язок близький до лінійного, а між розміром вибірки та процесорним часом витраченим на вибір та копіювання даних зв'язок нелінійний (при більших вибірках витрати процесорного часу зростають швидше)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
GLM = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
JuliaDB = "a93385a2-3734-596a-9a66-3cfbb77141e6"
OnlineStats = "a15396b6-48d5-5d58-9928-6d29437db91e"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"

[compat]
CommonMark = "~0.8.6"
DataFrames = "~0.21.8"
Distributions = "~0.23.12"
GLM = "~1.4.2"
JuliaDB = "~0.13.0"
OnlineStats = "~1.5.14"
StatsPlots = "~0.14.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractTrees]]
git-tree-sha1 = "52b3b436f8f73133d7bc3a6c71ee7ed6ab2ab754"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.3"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra"]
git-tree-sha1 = "2ff92b71ba1747c5fdd541f8fc87736d82f40ec9"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.4.0"

[[deps.Arpack_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "5ba6c757e8feccf03a1554dfaf3e26b3cfc7fd5e"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.1+1"

[[deps.ArrayInterfaceCore]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "e6cba4aadba7e8a7574ab2ba2fcfb307b4c4b02a"
uuid = "30b0a656-2188-435a-8636-2ec0e6a096e2"
version = "0.1.23"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

[[deps.Calculus]]
deps = ["Compat"]
git-tree-sha1 = "f60954495a7afcee4136f78d1d60350abd37a409"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.4.1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "JSON", "Missings", "Printf", "Statistics", "StructTypes", "Unicode"]
git-tree-sha1 = "2ac27f59196a68070e132b25713f9a5bbc5fa0d2"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.8.3"

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
deps = ["BinaryProvider", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "05916673a2627dd91b4969ff8ba6941bc85a960e"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.6.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b9de8dc6106e09c79f3f776c27c62360d30e5eb8"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.9.1"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "InteractiveUtils", "Printf", "Reexport"]
git-tree-sha1 = "177d8b959d3c103a6d57574c38ee79c81059c31b"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.11.2"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "4cd7063c9bdebdbd55ede1af70f3c2f48fab4215"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.6"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "b0b7e8a0d054fada22b64095b46469627a138943"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "2.2.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "fb21ddd70a051d882a1686a5a550990bbe371a95"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.4.1"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.Dagger]]
deps = ["Distributed", "LinearAlgebra", "MemPool", "Profile", "Random", "Serialization", "SharedArrays", "SparseArrays", "Statistics", "StatsBase", "Test"]
git-tree-sha1 = "39dd9351c6637a71d1925e26e49adcd8a25ebf0b"
uuid = "d58978e5-989f-55fb-8d15-ea34adc7bf54"
version = "0.8.0"

[[deps.DataAPI]]
git-tree-sha1 = "46d2680e618f8abd007bce0c3026cb0c4a8f2032"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.12.0"

[[deps.DataFrames]]
deps = ["CategoricalArrays", "Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "Missings", "PooledArrays", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "ecd850f3d2b815431104252575e7307256121548"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "0.21.8"

[[deps.DataStructures]]
deps = ["InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "88d48e133e6d3dd68183309877eac74393daa7eb"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.17.20"

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

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DiffEqDiffTools]]
deps = ["LinearAlgebra", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "2d4f49c1839c1f30e4820400d8c109c6b16e869a"
uuid = "01453d9d-ee7c-5054-8395-0335cb756afa"
version = "0.13.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "8b7a4d23e22f5d44883671da70865ca98f2ebf9d"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.12.0"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "StaticArrays", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "501c11d708917ca09ce357bed163dbaf0f30229f"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.23.12"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.DoubleFloats]]
deps = ["GenericLinearAlgebra", "LinearAlgebra", "Polynomials", "Printf", "Quadmath", "Random", "Requires", "SpecialFunctions"]
git-tree-sha1 = "964a1a3737ef63eeacdac7f32c27d5cdaa383cbd"
uuid = "497a8b3b-efae-58df-a0af-a86822472b78"
version = "1.2.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FFMPEG]]
deps = ["BinaryProvider", "Libdl"]
git-tree-sha1 = "9143266ba77d3313a4cf61d8333a1970e8c5d8b6"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.2.4"

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
deps = ["LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "502b3de6039d5b78c76118423858d981349f3823"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.9.7"

[[deps.FiniteDiff]]
deps = ["ArrayInterfaceCore", "LinearAlgebra", "Requires", "Setfield", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "5a2cff9b6b77b33b89f3d97a4d367747adce647e"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.15.0"

[[deps.FixedPointNumbers]]
git-tree-sha1 = "d14a6fa5890ea3a7e5dcab6811114f132fec2b4b"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.6.1"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "187198a4ed8ccd7b5d99c41b69c679269ea2b2d4"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.32"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Random", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "dc577ad8b146183c064b30e747e3afc6d6dfd62b"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.4.2"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "LinearAlgebra", "Printf", "Random", "Serialization", "Sockets", "Test"]
git-tree-sha1 = "c690c2ab22ac9ee323d9966deae61a089362b25c"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.44.0"

[[deps.GenericLinearAlgebra]]
deps = ["LinearAlgebra", "Printf", "Random", "libblastrampoline_jll"]
git-tree-sha1 = "d2827f7a249bd6dd1a67d35e2fab2e6b5da27e62"
uuid = "14197337-ba66-59df-a3e3-ca00e7dcff7a"
version = "0.3.3"

[[deps.GeometryTypes]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "78f0ce9d01993b637a8f28d84537d75dc0ce8eef"
uuid = "4d00f742-c7ba-57c2-abde-4428a4b178cb"
version = "0.7.10"

[[deps.Glob]]
git-tree-sha1 = "4df9f7e06108728ebf00a0a11edee4b29a482bb2"
uuid = "c27321d9-0574-5035-807b-f59d2c89b15c"
version = "1.3.0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.IndexedTables]]
deps = ["DataAPI", "DataValues", "Distributed", "IteratorInterfaceExtensions", "OnlineStatsBase", "PooledArrays", "SparseArrays", "Statistics", "StructArrays", "TableTraits", "TableTraitsUtils", "Tables", "WeakRefStrings"]
git-tree-sha1 = "e41ee5688e404b49795a85dcb1da2dafb4409645"
uuid = "6deec6e2-d858-57c5-ab9b-e6ca5bd20e43"
version = "0.12.6"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["AxisAlgorithms", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "2b7d4e9be8b74f03115e64cf36ed2f48ae83d946"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.12.10"

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

[[deps.JuliaDB]]
deps = ["Dagger", "DataValues", "Distributed", "Glob", "IndexedTables", "MemPool", "Nullables", "OnlineStats", "OnlineStatsBase", "PooledArrays", "Printf", "Random", "RecipesBase", "Serialization", "Statistics", "StatsBase", "TextParse", "WeakRefStrings"]
git-tree-sha1 = "a19da3e8b971e65d4859ee13bfae8a06df5681f4"
uuid = "a93385a2-3734-596a-9a66-3cfbb77141e6"
version = "0.13.0"

[[deps.KernelDensity]]
deps = ["Distributions", "FFTW", "Interpolations", "Optim", "StatsBase", "Test"]
git-tree-sha1 = "c1048817fe5711f699abc8fabd47b1ac6ba4db04"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.5.1"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "f27132e551e959b3667d8c93eae90973225032dd"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.1.1"

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

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.MemPool]]
deps = ["DataStructures", "Distributed", "Mmap", "Random", "Serialization", "Sockets", "Test"]
git-tree-sha1 = "d52799152697059353a8eac1000d32ba8d92aa25"
uuid = "f9f48841-c794-520a-933b-121f7ba6ed94"
version = "0.2.0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f8c673ccc215eb50fcadb285f522420e29e69e1c"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "0.4.5"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "352fae519b447bf52e6de627b89f448bcd469e4e"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.7.0"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "50310f934e55e5ca3912fb941dec199b49ca9b68"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.2"

[[deps.NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "440165bf08bc500b8fe4a7be2dc83271a00c0716"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Nullables]]
deps = ["Compat"]
git-tree-sha1 = "ae1a63457e14554df2159b0b028f48536125092d"
uuid = "4d1e1d77-625e-5b40-9113-a560ec7a8ecd"
version = "0.0.8"

[[deps.Observables]]
git-tree-sha1 = "3469ef96607a6b9a1e89e54e6f23401073ed3126"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.3.3"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "f71d8950b724e9ff6110fc948dff5a329f901d64"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.8"

[[deps.OnlineStats]]
deps = ["AbstractTrees", "Dates", "LinearAlgebra", "OnlineStatsBase", "OrderedCollections", "Random", "RecipesBase", "Statistics", "StatsBase"]
git-tree-sha1 = "e81f7f4179becdb6c365fb5a44042cfe7d50b77a"
uuid = "a15396b6-48d5-5d58-9928-6d29437db91e"
version = "1.5.14"

[[deps.OnlineStatsBase]]
deps = ["AbstractTrees", "Dates", "LinearAlgebra", "OrderedCollections", "Statistics", "StatsBase"]
git-tree-sha1 = "60e587c99ea261d1c452d2acb1f3a481e772660c"
uuid = "925886fa-5bf2-5e8e-b522-a9147a512338"
version = "1.5.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Optim]]
deps = ["Calculus", "DiffEqDiffTools", "ForwardDiff", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "Random", "SparseArrays", "StatsBase", "Test"]
git-tree-sha1 = "a626e09c1f7f019b8f3a30a8172c7b82d2f4810b"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "0.18.1"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse", "Test"]
git-tree-sha1 = "95a4038d1011dfdbde7cecd2ad0ac411e53ab1bc"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.10.1"

[[deps.Parameters]]
deps = ["Markdown", "OrderedCollections", "REPL", "Test"]
git-tree-sha1 = "70bdbfb2bceabb15345c0b54be4544813b3444e4"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.10.3"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "87a4ea7f8c350d87d3a8ca9052663b633c0b2722"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "1.0.3"

[[deps.PlotUtils]]
deps = ["Colors", "Dates", "Printf", "Random", "Reexport"]
git-tree-sha1 = "51e742162c97d35f714f9611619db6975e19384b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "0.6.5"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "FFMPEG", "FixedPointNumbers", "GR", "GeometryTypes", "JSON", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "Reexport", "Requires", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "efbe466a790d7e8a5c4b5ee1601c0c8edc99780b"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "0.28.4"

[[deps.Polynomials]]
deps = ["LinearAlgebra", "RecipesBase"]
git-tree-sha1 = "3010a6dd6ad4c7384d2f38c58fa8172797d879c1"
uuid = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
version = "3.2.0"

[[deps.PooledArrays]]
deps = ["DataAPI"]
git-tree-sha1 = "b1333d4eced1826e15adbdf01a4ecaccca9d353c"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "0.5.3"

[[deps.PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "97aa253e65b784fd13e83774cadc95b38011d734"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.6.0"

[[deps.Quadmath]]
deps = ["Printf", "Random", "Requires"]
git-tree-sha1 = "c415bfc154c185a31e753d28e8778860995894c7"
uuid = "be4d8f0f-7fa4-5f49-b795-2f01399ab2dd"
version = "0.5.6"

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
git-tree-sha1 = "7bdce29bc9b2f5660a6e5e64d64d91ec941f6aa2"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "0.7.0"

[[deps.Reexport]]
deps = ["Pkg"]
git-tree-sha1 = "7b1d07f411bc8ddb7977ec7f377b97b158514fe0"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "0.2.0"

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

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.ShiftedArrays]]
git-tree-sha1 = "22395afdcf37d6709a5a0766cc4a5ca52cb85ea0"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "1.0.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "ee010d8f103468309b8afac4abb9be2e18ff1182"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "0.3.2"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures", "Random", "Test"]
git-tree-sha1 = "03f5898c9959f8115e30bc7226ada7d0df554ddd"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "0.3.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["OpenSpecFun_jll"]
git-tree-sha1 = "d8d8b8a9f4119829410ecd706da4cc8594a1e020"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "0.10.3"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "da4cf579416c81994afd6322365d00916c79b8ae"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "0.12.5"

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
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics"]
git-tree-sha1 = "19bfcb46245f69ff4013b3df3b977a289852c3a1"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.32.2"

[[deps.StatsFuns]]
deps = ["Rmath", "SpecialFunctions"]
git-tree-sha1 = "ced55fd4bae008a8ea12508314e725df61f0ba45"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.7"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "ShiftedArrays", "SparseArrays", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "3db41a7e4ae7106a6bcff8aa41833a4567c04655"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.6.21"

[[deps.StatsPlots]]
deps = ["Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "MultivariateStats", "Observables", "Plots", "RecipesBase", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "388e6588a1e09e763b0f38c498aeb350b5f76828"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.14.5"

[[deps.StructArrays]]
deps = ["DataAPI", "Tables"]
git-tree-sha1 = "ad1f5fd155426dcc879ec6ede9f74eb3a2d582df"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.4.2"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableOperations]]
deps = ["Tables", "Test"]
git-tree-sha1 = "208630a14884abd110a8f8008b0882f0d0f5632c"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "0.2.1"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

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

[[deps.TextParse]]
deps = ["CodecZlib", "DataStructures", "Dates", "DoubleFloats", "Mmap", "Nullables", "PooledArrays", "WeakRefStrings"]
git-tree-sha1 = "26b43d6746b52cca13c4cdef90f89652273b413e"
uuid = "e0df1984-e451-5cb5-8b61-797a481e67e3"
version = "0.9.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

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
deps = ["DataAPI", "Random", "Test"]
git-tree-sha1 = "28807f85197eaad3cbd2330386fac1dcb9e7e11d"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "0.6.2"

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
# ╟─5532c8ae-56af-11ed-0aa8-77b63a70d31f
# ╟─913ad607-557c-4395-98e9-82b4f547034b
# ╟─172dac67-58b1-48c9-98fe-cf0a3f88c9e0
# ╠═6920de4c-2bf1-452f-ba22-63496ce0fc7d
# ╟─b4658d90-7d03-4105-ae1c-77b4a7c2d714
# ╠═4b8c9bc4-0684-4e59-8f76-0f77578078d3
# ╠═648a7e2c-540c-43fb-9ef6-e5cda79db22c
# ╠═b3e980a1-214e-447a-826e-5bf8e2c63bd6
# ╠═272bda1f-de7a-43ca-9cb1-33459d1c6e87
# ╠═586f4ef6-c475-4cbc-a0cf-0dec79a87853
# ╠═845100f7-3478-4625-81d6-dfd05794fdf4
# ╟─66dfb7c7-d354-4754-b6ce-b9411bee7d91
# ╟─95529864-501b-467f-9ab8-012964e5e43b
# ╠═75d8ee41-c08f-4199-a8f0-cc46a382b042
# ╟─06d906c3-cded-45e3-a3c9-a250c2cdd406
# ╠═42ac0b0f-6fa4-4660-9da4-529fcb593e79
# ╠═58085635-fd4d-4fab-89f1-bc4de7dc7b79
# ╠═acfb96bd-b4db-45a2-9521-30f9eda430cf
# ╟─5876cd06-485c-45bf-9ade-29b5237c2ca9
# ╠═cfdc736f-65b9-4204-affc-4b487b5bc289
# ╟─64fc48bc-eb1c-481c-bff2-8c474b415b75
# ╠═b9a0061c-3865-4836-a110-7a026ab312fa
# ╠═00a9a72b-d456-469f-b33f-2e24246227e0
# ╠═14361b4a-5de1-4e7c-bb57-6a340564697b
# ╠═50a2ecdb-0a58-4774-a6a3-848ec048ab04
# ╟─a3cc9600-64a2-4857-bd6c-7a40af715ae4
# ╠═979b5b8c-f3b6-4936-8e29-ae123fe33a1e
# ╟─42b925fe-06f0-40e1-8fad-2115ffc8b1a3
# ╠═5a4a181b-3f48-4355-849b-913519a1dac0
# ╟─1f8c96fc-07be-42d7-a3ac-7372113d66f2
# ╠═2ae328d3-a8fa-4167-a1ab-fa0e11e43e0f
# ╟─934f813c-e235-465b-967a-8cd5fc1b5318
# ╠═90fb875c-d034-4d46-bfb7-779ea7b079d7
# ╠═96f67604-5f92-4cc0-b6fe-df16ddf5bfff
# ╟─cd1e54b1-075d-4bd4-81d4-b734d5d733ea
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
