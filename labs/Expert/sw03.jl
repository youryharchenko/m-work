### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 2dce4d60-65a7-11ed-1850-d3bb07c04acc
using Julog, CSV, DataFrames, CommonMark

# ╔═╡ 977bab3e-0466-4095-b73c-8d57359ff512
cm"""
---

<style>
@media print {
    .pagebreak { page-break-before: always; } /* page-break-after works, as well */
}
</style>

<div align="center">

Національний університет біоресурсів і природокористування України

Факультет інформаційних технологій

Кафедра комп'ютерних наук

<br/><br/>

Самостійна робота

Інтелектуальний аналіз журналу веб-сервера


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








---

"""

# ╔═╡ 78bbd3d0-d422-42a6-889f-a1ca7a342075
cm"""
## Інтелектуальний аналіз журналу веб-сервера
"""

# ╔═╡ 693977a6-d0a6-43dc-9e9f-5c85a1473487
cm"""
<div class="pagebreak"> </div>

#### В роботі використано мову Julia та її пакети

"""

# ╔═╡ b37a6980-58c7-4463-ac06-0d2d6dc94e8d
cm"""
### Завантажуємо журнал
"""

# ╔═╡ 3ea4e5fc-7121-4b77-9001-d2a26f83175b
df = CSV.read("logs.csv", DataFrame);

# ╔═╡ e64c65c6-6248-45c3-8ca7-407023b9821e
logs = df[completecases(df), :]

# ╔═╡ 29a0cd9d-acdd-437b-883b-01eac947cdb8
cm"""
### Перетворюємо журнал у факти бази знань
"""

# ╔═╡ b241b572-5e2b-431c-b3de-e35710b34de5
facts = let
	clauses = Vector{Julog.Clause}(undef, nrow(logs))
	i = 0
	for r in eachrow(logs)
		i+=1
		clauses[i] = Clause(
			Compound(:record, [
				Const(r.ip), 
				Const(r.met),
				Const(r.ret),
				Const(r.br),
				Const(r.count),
			]), []
		)
	end
	clauses
end

# ╔═╡ e38c5ac3-92d3-453b-b882-b3f0c20e33bb
cm"""
### Створюємо правила для аналізу даних
"""

# ╔═╡ 08f8624d-9cb6-4ee4-9d69-705008eb8f18
rules = @julog [
	good(Ret) <<= Ret < 400,
	bad(Ret) <<= Ret >= 400,
	python(Br) <<= or(occursin("python", Br), occursin("Python", Br)),
	golang(Br) <<= or(occursin("Go-http-client", Br), occursin("go-http-client", Br)),
	tiny(Count) <<= Count == 1,
	small(Count) <<= and(Count > 1, Count <=10),
	middle(Count) <<= and(Count > 10, Count <=50),
	large(Count) <<= and(Count > 50, Count <=100),
	huge(Count) <<= and(Count > 100),
]


# ╔═╡ 0d201233-29c3-4d74-aa95-d9a8b8c30bc5
cm"""
### Створюємо допоміжні функції
"""

# ╔═╡ 56c15cd4-e3f8-4bb7-96c9-7ab5a3805b8e
funcs = Dict(
	:occursin => (sub, str) -> occursin(sub, str)
)

# ╔═╡ 611573ac-dac4-43d4-8a59-7cdded4434f5
cm"""
### Зливаємо факти та правила в єдину базу знань
"""

# ╔═╡ e312ca9d-434d-47e4-86c7-2bdaf0a95919
kb = vcat(facts, rules)

# ╔═╡ 3bc6a721-e8d2-487c-bbac-184094afd6ac
cm"""
### Перевіряємо нашу створену систему
"""

# ╔═╡ 11e55b09-5b32-4972-a611-6f1663825eca
cm"""
#### Вибираємо всі вдалі запити  
"""

# ╔═╡ 204b6b9f-2646-475b-b699-13420a3bdce1
resolve(@julog([record(I, M, R,	B, C), good(R)]), kb)

# ╔═╡ c9d54d4b-6a8d-4189-83fb-f965f8e33446
cm"""
#### Вибираємо всі невдалі запити  
"""

# ╔═╡ ca6cf536-5801-4d83-938b-c1fcd97e904b
resolve(@julog([record(I, M, R,	B, C), bad(R)]), kb)

# ╔═╡ 4a26a8a7-d4c0-4216-8544-956c4b362bdd
cm"""
#### Вибираємо вдалі запити, зроблені з клієнта Python
"""

# ╔═╡ 40bf3688-e9ff-4f81-9149-1f6f3ec77915
resolve(@julog([record(I, M, R,	B, C), python(B), good(R)]), kb, funcs = funcs)

# ╔═╡ d2d97bc0-77af-43de-8733-b1e276ea8b53
cm"""
#### Вибираємо невдалі запити, яких зареєстровано найбільше 
"""

# ╔═╡ 86cb3e03-c262-4535-a078-2d530c06d1d8
resolve(@julog([record(I, M, R,	B, C), bad(R), huge(C)]), kb, funcs = funcs)

# ╔═╡ 7fe98e4d-7954-459b-9071-035c35ced559
cm"""
#### Вибираємо вдалі запити, зроблені з клієнта Golang, які зустрічаються мало  
"""

# ╔═╡ 7cac2cd3-046e-434e-a756-64343ae7da27
resolve(@julog([record(I, M, R,	B, C), golang(B), small(C), good(R)]), kb, funcs = funcs)

# ╔═╡ b1c70af8-78ab-4e9b-9a3a-26dc61e4db4f
cm"""
### Висновки. За допомогою пакету логічного програмування Julog мови Julia створено прототип системи інтелектуального аналізу текстового журналу веб-сервера
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Julog = "5d8bcb5e-2b2c-4a96-a2b1-d40b3d3c344f"

[compat]
CSV = "~0.10.7"
CommonMark = "~0.8.7"
DataFrames = "~1.4.3"
Julog = "~0.1.15"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "aba58a63ae0a0fc3b69034dd5c9183113415a77d"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "c5fd7cd27ac4aed0acf4b73948f0110ff2a854b2"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.7"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "86cce6fd164c26bad346cc51ca736e692c9f553c"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.7"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

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

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

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
git-tree-sha1 = "b5081bd8a53eeb6a2ef956751343ab44543023fb"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.3.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

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

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "d8ed354439950b34ab04ff8f3dfd49e11bc6c94b"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.1"

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
version = "0.7.0"

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

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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
"""

# ╔═╡ Cell order:
# ╟─977bab3e-0466-4095-b73c-8d57359ff512
# ╟─78bbd3d0-d422-42a6-889f-a1ca7a342075
# ╟─693977a6-d0a6-43dc-9e9f-5c85a1473487
# ╠═2dce4d60-65a7-11ed-1850-d3bb07c04acc
# ╟─b37a6980-58c7-4463-ac06-0d2d6dc94e8d
# ╠═3ea4e5fc-7121-4b77-9001-d2a26f83175b
# ╠═e64c65c6-6248-45c3-8ca7-407023b9821e
# ╟─29a0cd9d-acdd-437b-883b-01eac947cdb8
# ╠═b241b572-5e2b-431c-b3de-e35710b34de5
# ╟─e38c5ac3-92d3-453b-b882-b3f0c20e33bb
# ╠═08f8624d-9cb6-4ee4-9d69-705008eb8f18
# ╟─0d201233-29c3-4d74-aa95-d9a8b8c30bc5
# ╠═56c15cd4-e3f8-4bb7-96c9-7ab5a3805b8e
# ╟─611573ac-dac4-43d4-8a59-7cdded4434f5
# ╠═e312ca9d-434d-47e4-86c7-2bdaf0a95919
# ╟─3bc6a721-e8d2-487c-bbac-184094afd6ac
# ╟─11e55b09-5b32-4972-a611-6f1663825eca
# ╠═204b6b9f-2646-475b-b699-13420a3bdce1
# ╟─c9d54d4b-6a8d-4189-83fb-f965f8e33446
# ╠═ca6cf536-5801-4d83-938b-c1fcd97e904b
# ╟─4a26a8a7-d4c0-4216-8544-956c4b362bdd
# ╠═40bf3688-e9ff-4f81-9149-1f6f3ec77915
# ╟─d2d97bc0-77af-43de-8733-b1e276ea8b53
# ╠═86cb3e03-c262-4535-a078-2d530c06d1d8
# ╟─7fe98e4d-7954-459b-9071-035c35ced559
# ╠═7cac2cd3-046e-434e-a756-64343ae7da27
# ╟─b1c70af8-78ab-4e9b-9a3a-26dc61e4db4f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
