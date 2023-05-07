### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 0acc38d4-5901-11ed-01bc-91a484a08e9d
using CommonMark, PlutoUI

# ╔═╡ 08f7f315-b800-473c-9017-a782124fd961
using PyCall

# ╔═╡ 59a5ab24-d454-4057-885d-4cf845992d4b
cm"""
---
<div align="center">

Національний університет біоресурсів і природокористування України

Факультет інформаційних технологій

Кафедра комп'ютерних наук

<br/><br/>


Штучний інтелект для оптимальних рішень

Лабораторна робота 7


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

# ╔═╡ 3ae60184-fd76-430c-a8ad-72cafccebbab
cm"""

#### В роботі використано мову Julia та її пакети, а також пакет мови Python

"""

# ╔═╡ 125d5443-8e8c-4ad1-b541-c0c52269b299
sf = pyimport("simpful")

# ╔═╡ fa7b681a-cbbc-41f4-905b-75954c7dbb87
FS = sf.FuzzySystem()

# ╔═╡ 4bb30e80-56be-4710-a570-7dc465b551cd
cm"""
#### Створюємо нечіткі множини та лінгвістичні змінні
"""

# ╔═╡ 63f7c71e-a463-44f7-b8b6-e07de050b56f
begin
	S_1 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=0, b=0, c=25), term="Небезпечно")
	S_2 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=0, b=37, c=75), term="Небажано")
	S_3 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=25, b=63, c=100), term="МалоКорисно")
	S_4 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=75, b=100, c=100), term="Корисно")
	FS.add_linguistic_variable("Корисність", sf.LinguisticVariable([S_1, S_2, S_3, S_4], concept="Корисність іжі", universe_of_discourse=[0,100]))
end

# ╔═╡ c2ff6b3c-f494-4e35-913c-9ea6c34d2469
begin
	F_1 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=0, b=0, c=25), term="Гидка")
	F_2 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=0, b=37, c=75), term="Несмачно")
	F_3 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=25, b=63, c=100), term="ДоситьСмачно")
	F_4 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=75, b=100, c=100), term="ДужеСмачно")
	FS.add_linguistic_variable("Смак", sf.LinguisticVariable([F_1, F_2, F_3, F_4],
		concept="Смакові якості", universe_of_discourse=[0,100]))
end

# ╔═╡ a1548eee-f4b1-451d-a944-937e95380774
begin
	H_1 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=0, b=0, c=50), term="Голодний")
	H_2 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=0, b=50, c=100), term="Нормальний")
	H_3 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=50, b=100, c=100), term="Ситий")
	FS.add_linguistic_variable("Ситість", sf.LinguisticVariable([H_1, H_2, H_3],
		concept="Рівень ситості", universe_of_discourse=[0,100]))
end

# ╔═╡ 3e37e391-5159-47cd-b4de-62f6b2698017
begin
	T_1 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=0, b=0, c=100), term="Ні")
	T_2 = sf.FuzzySet(;:function=>sf.Triangular_MF(a=0, b=100, c=100), term="Так")
	FS.add_linguistic_variable("Їсти", sf.LinguisticVariable([T_1, T_2], 
	universe_of_discourse=[0,100]))
end

# ╔═╡ d7b18a38-a3b3-4fe6-b8cc-cdbc6cb2cf29
cm"""
#### Зобразимо створені множини та змінні
"""

# ╔═╡ b3ab8c90-8b97-4936-a6d6-1dfa5088ffcd
FS.produce_figure(outputfile="fig1.png", max_figures_per_row=2)

# ╔═╡ dd693d88-278e-4451-a2d2-7319730a69dd
LocalResource("fig1.png")

# ╔═╡ 64ac438e-6420-4cc4-8246-5e1a486f883a
cm"""
#### Створюємо правила для виведення рішення
"""

# ╔═╡ 08fb1364-4871-4c0f-806a-98c21fe5afc5
begin
	R = [
	"IF (Ситість IS Ситий) OR (Смак IS Гидка) OR (Корисність IS Небезпечно) THEN (Їсти IS Ні)",
		
	"IF (Ситість IS Нормальний) AND (Смак IS Несмачно) THEN (Їсти IS Ні)",
	"IF (Ситість IS Нормальний) AND (Смак IS ДоситьСмачно) THEN (Їсти IS Ні)",
	"IF (Ситість IS Нормальний) AND (Смак IS ДужеСмачно) THEN (Їсти IS Так)",
		
	"IF (Ситість IS Голодний) AND (Смак IS Несмачно) THEN (Їсти IS Так)",
	"IF (Ситість IS Голодний) AND (Смак IS ДоситьСмачно) THEN (Їсти IS Так)",
	"IF (Ситість IS Голодний) AND (Смак IS ДужеСмачно) THEN (Їсти IS Так)",
		
	"IF (Ситість IS Нормальний) AND (Корисність IS Небажано) THEN (Їсти IS Ні)",
	"IF (Ситість IS Нормальний) AND (Корисність IS МалоКорисно) THEN (Їсти IS Ні)",
	"IF (Ситість IS Нормальний) AND (Корисність IS Корисно) THEN (Їсти IS Так)",
		
	"IF (Ситість IS Голодний) AND (Корисність IS Небажано) THEN (Їсти IS Ні)",
	"IF (Ситість IS Голодний) AND (Корисність IS МалоКорисно) THEN (Їсти IS Так)",
	"IF (Ситість IS Голодний) AND (Корисність IS Корисно) THEN (Їсти IS Так)",
	]
	FS.add_rules(R)
end

# ╔═╡ cb8ed18c-5d95-43c5-aaa5-402e1a670444
cm"""
#### Задаємо значення вихідних змінних
"""

# ╔═╡ d99b3693-cebf-48b1-a1de-6096267f9aef
begin
	FS.set_variable("Ситість", 40)
	FS.set_variable("Смак", 80)
	FS.set_variable("Корисність", 60)
end

# ╔═╡ c9897169-dc20-41ab-98e1-33ad2a5146d8
cm"""
#### Виводимо значення результуючої змінної
"""

# ╔═╡ 2042a351-f5b8-4f87-b0e6-6ecd7deaec92
res = FS.Mamdani_inference(["Їсти"])

# ╔═╡ 70c8f684-a734-4b26-b13a-67ca4d76204e
cm"""
#### Висновок. При заданих умовах та вихідних значеннях - рекомендація не їсти
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"

[compat]
CommonMark = "~0.8.6"
PlutoUI = "~0.7.48"
PyCall = "~1.94.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "b4ab1dfc447d6e619a35aae17cda3e47f2b9c2a3"

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

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "6e47d11ea2776bc5627421d59cdcc1296c058071"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.7.0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

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

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

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
version = "2.28.0+0"

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

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "53b8b07b721b77144a0fbbbc2675222ebf40a02d"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.94.1"

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

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

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
# ╟─0acc38d4-5901-11ed-01bc-91a484a08e9d
# ╟─59a5ab24-d454-4057-885d-4cf845992d4b
# ╟─3ae60184-fd76-430c-a8ad-72cafccebbab
# ╠═08f7f315-b800-473c-9017-a782124fd961
# ╠═125d5443-8e8c-4ad1-b541-c0c52269b299
# ╠═fa7b681a-cbbc-41f4-905b-75954c7dbb87
# ╟─4bb30e80-56be-4710-a570-7dc465b551cd
# ╠═63f7c71e-a463-44f7-b8b6-e07de050b56f
# ╠═c2ff6b3c-f494-4e35-913c-9ea6c34d2469
# ╠═a1548eee-f4b1-451d-a944-937e95380774
# ╠═3e37e391-5159-47cd-b4de-62f6b2698017
# ╟─d7b18a38-a3b3-4fe6-b8cc-cdbc6cb2cf29
# ╠═b3ab8c90-8b97-4936-a6d6-1dfa5088ffcd
# ╠═dd693d88-278e-4451-a2d2-7319730a69dd
# ╟─64ac438e-6420-4cc4-8246-5e1a486f883a
# ╠═08fb1364-4871-4c0f-806a-98c21fe5afc5
# ╟─cb8ed18c-5d95-43c5-aaa5-402e1a670444
# ╠═d99b3693-cebf-48b1-a1de-6096267f9aef
# ╟─c9897169-dc20-41ab-98e1-33ad2a5146d8
# ╠═2042a351-f5b8-4f87-b0e6-6ecd7deaec92
# ╟─70c8f684-a734-4b26-b13a-67ca4d76204e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
