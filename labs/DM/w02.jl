### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 299cfe1e-ce23-11ed-3c20-f55e4ee5485c
using CommonMark

# ╔═╡ 491118ba-4b19-43ed-a30c-2d34b2a2c63b
using ARFFFiles, DataFrames, DecisionTree, Clustering

# ╔═╡ 28256a42-8c6e-47ee-b896-23003deaa1d0
cm"""
---
<div align="center">

Національний університет біоресурсів і природокористування України

Факультет інформаційних технологій

Кафедра комп'ютерних наук

<br/><br/>

Технології Data Mining

Лабораторна робота 2


</div>

<br/><br/>

<div align="right">

Виконав

Студент групи ІУСТ-22001м

Харченко Юрій

</div>

<br/><br/>

<div align="center">

Київ – 2023

</div>

---
"""

# ╔═╡ c8b11a41-ab89-4947-adcb-de921cbb231a
md"""

#### В роботі використано мову Julia та її пакети

"""

# ╔═╡ 403b34c1-f7ad-4f19-8b77-80e32fae6baf
md"""
#### Спочатку виконаємо тестовий приклад по DecisionTree
"""

# ╔═╡ ccd36018-89fa-4659-b022-28c84011919d
f1, l1 = load_data("iris")

# ╔═╡ cf06269f-7777-4534-a278-21b4d82685c1
features1 = float.(f1)

# ╔═╡ abf8b21b-5fcf-4e58-8027-40e0136e7acc
labels1   = string.(l1)

# ╔═╡ 0eca1435-dafb-425d-8bce-41e1a5aae09d
model1 = build_tree(labels1, features1)

# ╔═╡ 95f018ed-f3e1-4f55-8987-c296b2044d03
print_tree(model1, 5)

# ╔═╡ 392e7ff6-6a6a-421f-9554-b62c09f3cda6
apply_tree(model1, [5.9,3.0,5.1,1.9])

# ╔═╡ 62f8dac7-cd4c-457b-94c5-8997b3b2c838
preds1 = apply_tree(model1, features1)

# ╔═╡ 2bd7b403-d203-4f39-be87-7692d4f5f54b
DecisionTree.confusion_matrix(labels1, preds1)

# ╔═╡ 7240312a-e493-4402-a9e7-a533a3ac7dfa
apply_tree_proba(model1, [5.9,3.0,5.1,1.9], ["Iris-setosa", "Iris-versicolor", "Iris-virginica"])

# ╔═╡ cc85d5ea-3bba-4447-807b-d55105e028cb
nfoldCV_tree(labels1, features1, 2)

# ╔═╡ 2e136692-ede0-48c6-b5f2-e6d734eb3b4c
md"""
#### Тепер завантажемо дані bmw-training.arff та виконаємо аналіз DecisionTree
"""

# ╔═╡ b948fdff-1946-42eb-8b44-905a1c5631f4
df_train = ARFFFiles.load(DataFrame, "bmw-training.arff")

# ╔═╡ 6594e400-7940-45e6-9878-b612a21376cb
parse_int = (x)->parse(Int, x)

# ╔═╡ 67142319-c160-4827-a702-21a802087527
f2 = select(df_train, :IncomeBracket=>(x->parse_int.((String.(x))))=>:IncomeBracket, :FirstPurchase, :LastPurchase)

# ╔═╡ 676f0f83-d36a-4280-a0a9-ac1dd8587a1c
l2 = select(df_train, :responded)

# ╔═╡ 351e294e-cc1d-4c4f-bc56-1bce2637aa20
features2 = Matrix(f2)

# ╔═╡ 81c392af-4412-4e93-b0cc-867996561ac5
labels2 = String.(l2[!, 1])

# ╔═╡ 2db3ccf7-2aca-4a7e-a9ab-3c7a3ce90494
model2 = build_tree(labels2, features2)

# ╔═╡ c2e2d0f1-ea63-492d-924c-4db5b844470d
print_tree(model2, 10)

# ╔═╡ 92761162-62d0-4337-89fd-9209470062a6
preds2 = apply_tree(model2, features2)

# ╔═╡ 62c2f097-2863-4cc1-8b45-87f8aa86b71c
DecisionTree.confusion_matrix(labels2, preds2)

# ╔═╡ 514a9713-d417-41e1-a36b-a0073f51490d
md"""
#### Завантажемо дані bmw-browsers.arff та зробимо кластерний аналіз 
"""

# ╔═╡ 5e636dbe-4ae9-4f64-9575-8d9f1d47b787
df_br = ARFFFiles.load(DataFrame, "bmw-browsers.arff")

# ╔═╡ b1529173-e5ac-4213-848b-bbd69c22b050
X = Matrix(df_br)'

# ╔═╡ b6b8e681-00a3-4e9e-8752-d42027dd78c7
kmeans(X, 5, maxiter=500)

# ╔═╡ 742b6fa0-60dd-411b-a21a-31a8a507cb85
md"""
#### Висновки: пакет Julia DecisionTree реалізує алгоритми класифікації, а пакет Clustering - кластерного аналізу. Пакет ARFFFiles дозволяє працювати з данними в форматі arff.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ARFFFiles = "da404889-ca92-49ff-9e8b-0aa6b4d38dc8"
Clustering = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DecisionTree = "7806a523-6efd-50cb-b5f6-3fa6f1930dbb"

[compat]
ARFFFiles = "~1.4.1"
Clustering = "~0.15.1"
CommonMark = "~0.8.10"
DataFrames = "~1.5.0"
DecisionTree = "~0.12.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "f2b00bd28a9d4f8c8026fb87ac86a2d66ada9ab5"

[[deps.ARFFFiles]]
deps = ["CategoricalArrays", "Dates", "Parsers", "Tables"]
git-tree-sha1 = "e8c8e0a2be6eb4f56b1672e46004463033daa409"
uuid = "da404889-ca92-49ff-9e8b-0aa6b4d38dc8"
version = "1.4.1"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "5084cc1a28976dd1642c9f337b28a3cb03e0f7d2"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.7"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "485193efd2176b88e6622a39a246f8c5b600e74e"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.6"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "Random", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "a3213fa9d35edf589d0c6303f95850f7641fe2dc"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.15.1"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "SnoopPrecompile", "URIs"]
git-tree-sha1 = "e2f4627b0d3f2c1876360e0b242a7c23923b469d"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.10"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "aa51303df86f8626a962fccb878430cdb0a97eee"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.5.0"

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

[[deps.DecisionTree]]
deps = ["AbstractTrees", "DelimitedFiles", "LinearAlgebra", "Random", "ScikitLearnBase", "Statistics"]
git-tree-sha1 = "c6475a3ccad06cb1c2ebc0740c1bb4fe5a0731b7"
uuid = "7806a523-6efd-50cb-b5f6-3fa6f1930dbb"
version = "0.12.3"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "49eba9ad9f7ead780bfb7ee319f962c811c6d3b2"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.8"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

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

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "0a1b7c2863e44523180fdb3146534e265a91870b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.23"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "2c3726ceb3388917602169bed973dbc97f1b51a8"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.13"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "d78db6df34313deaca15c5c0b9ff562c704fe1ab"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.5.0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

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
git-tree-sha1 = "548793c7859e28ef026dba514752275ee871169f"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.3"

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

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.ScikitLearnBase]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "7877e55c1523a4b336b433da39c8e8c08d2f221f"
uuid = "6e75b9c4-186b-50bd-896f-2d2496a4843e"
version = "0.5.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "77d3c4726515dca71f6d80fbb5e251088defe305"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.18"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

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

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "b8d897fe7fa688e93aef573711cb207c08c9e11e"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.19"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

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
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"
"""

# ╔═╡ Cell order:
# ╟─299cfe1e-ce23-11ed-3c20-f55e4ee5485c
# ╟─28256a42-8c6e-47ee-b896-23003deaa1d0
# ╟─c8b11a41-ab89-4947-adcb-de921cbb231a
# ╠═491118ba-4b19-43ed-a30c-2d34b2a2c63b
# ╟─403b34c1-f7ad-4f19-8b77-80e32fae6baf
# ╠═ccd36018-89fa-4659-b022-28c84011919d
# ╠═cf06269f-7777-4534-a278-21b4d82685c1
# ╠═abf8b21b-5fcf-4e58-8027-40e0136e7acc
# ╠═0eca1435-dafb-425d-8bce-41e1a5aae09d
# ╠═95f018ed-f3e1-4f55-8987-c296b2044d03
# ╠═392e7ff6-6a6a-421f-9554-b62c09f3cda6
# ╠═62f8dac7-cd4c-457b-94c5-8997b3b2c838
# ╠═2bd7b403-d203-4f39-be87-7692d4f5f54b
# ╠═7240312a-e493-4402-a9e7-a533a3ac7dfa
# ╠═cc85d5ea-3bba-4447-807b-d55105e028cb
# ╟─2e136692-ede0-48c6-b5f2-e6d734eb3b4c
# ╠═b948fdff-1946-42eb-8b44-905a1c5631f4
# ╠═6594e400-7940-45e6-9878-b612a21376cb
# ╠═67142319-c160-4827-a702-21a802087527
# ╠═676f0f83-d36a-4280-a0a9-ac1dd8587a1c
# ╠═351e294e-cc1d-4c4f-bc56-1bce2637aa20
# ╠═81c392af-4412-4e93-b0cc-867996561ac5
# ╠═2db3ccf7-2aca-4a7e-a9ab-3c7a3ce90494
# ╠═c2e2d0f1-ea63-492d-924c-4db5b844470d
# ╠═92761162-62d0-4337-89fd-9209470062a6
# ╠═62c2f097-2863-4cc1-8b45-87f8aa86b71c
# ╟─514a9713-d417-41e1-a36b-a0073f51490d
# ╠═5e636dbe-4ae9-4f64-9575-8d9f1d47b787
# ╠═b1529173-e5ac-4213-848b-bbd69c22b050
# ╠═b6b8e681-00a3-4e9e-8752-d42027dd78c7
# ╟─742b6fa0-60dd-411b-a21a-31a8a507cb85
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
