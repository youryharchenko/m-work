### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ fab17a3a-40c9-4b38-945d-fbbbf60fde02
using CommonMark, PlutoUI

# ╔═╡ 326569c4-6e1e-11ed-3cf8-131f3b957d0f
cm"""
---

<div align="center">

Національний університет біоресурсів і природокористування України

Факультет інформаційних технологій

Кафедра комп'ютерних наук

<br/><br/>

Лабораторна робота 1

Збір вимог щодо сховища даних

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

# ╔═╡ f06b12cf-47c9-4fdd-b4b4-d180d43e4c9d
cm"""
#### В роботі використано мову Julia  [[1](https://julialang.org/)] та її пакети, а також PlantUML [[2](https://plantuml.com/)]
"""

# ╔═╡ b19b0a7e-415c-45d7-b96a-3dfe2fbcac5e
TableOfContents()

# ╔═╡ d870c7d1-c82c-4127-a397-613042870b08
md"""

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

# ╔═╡ e51f23c3-5df7-4b9b-9f85-7b6bc3f340b7
md"""
## Мета проекту
"""

# ╔═╡ 8aba5cb2-38a6-416a-82d3-3be31c26cacb
md"""

Мета проєкту: створити сховище даних у вигляді бази знань предметної області, яка міститиме дані отримані з текстових джерел та розміщені у семантичній мережі.

"""

# ╔═╡ aa7bc3fa-194a-4591-8201-b20459f3888b
md"""
## Прецеденти
"""

# ╔═╡ 4e3d15f4-6ec6-4e80-a244-3cbf3215a5ae
let
usecase = """
@startuml

actor "Викладач" <<User>> as Teacher

rectangle E-Learn {
  usecase (Лекційні та методичні матеріали) as Lecture
  usecase (Виконані роботи) as Works
}

cloud Бібліотека {
  usecase (Оцифровані книги та статті) as Books
}


cloud Інтернет {
  usecase (Додаткові джерела) as Additions
}

rectangle "Інтелектуальний Агент" {
  component "Текстовий аналізатор" <<Application>> as TextProcessing
  component "Семантичний аналізатор" <<Application>> as SemanticProcessing
  database "База Знань" as KB
  component "Прцесор запитів" <<Application>> as QueryProcessing
  component "Конфігуратор" <<Application>> as Config
}

actor "Студент" <<User>> as Student

usecase (Діалог з агентом) as Dialog
usecase (Конфігурація предметної області) as Design

Teacher -down-> Lecture
Lecture -down-> TextProcessing
Books -down-> TextProcessing
Additions -down-> TextProcessing
TextProcessing -down-> SemanticProcessing
SemanticProcessing -down-> KB
QueryProcessing -up-> KB
Dialog -right-> QueryProcessing
Student -right-> Dialog
Student -left-> Design
Design -right-> Config
Student -up-> Works
Works -up-> Teacher

@enduml
"""
file = "usecase"
open("$file.txt", "w") do io
	write(io, usecase)
end
run(`plantuml "$file.txt"`)
LocalResource("$file.png")
end

# ╔═╡ 143ec45b-652c-4e54-9db5-d064c659bf8a
md"""
## Топологія
"""

# ╔═╡ 2afca4a1-01ae-4546-8fb3-0f5e9ec15a1e
let
topology = """
@startuml

package "Input" {
  [Text Processing]
  [Semantic Processing]
}

package "Configurator" {
  [Input Config]
  [KB Config]
  [Dialog Config]
}

package "Dialog" {
  [Query Processing]
}

database "Knowledge base" {
	[Meta Data]
  frame "Semantic Network" {
    [Frames]
	[Rules]
  }
}


[Text Processing] <--> [Semantic Processing]
[Semantic Processing] <--> [Frames]
[Semantic Processing] <--> [Rules]
[Meta Data] --> [Text Processing]
[Meta Data] --> [Semantic Processing]
[Meta Data] --> [Frames]
[Meta Data] --> [Rules]
[Meta Data] --> [Query Processing]
[Frames] <--> [Rules]
[Input Config] --> [Text Processing]
[Input Config] --> [Semantic Processing]
[Dialog Config] --> [Query Processing]
[KB Config] --> [Meta Data]
[Query Processing] <--> [Rules]
[Query Processing] <--> [Frames]


@enduml
"""
file = "topology"
open("$file.txt", "w") do io
	write(io, topology)
end
run(`plantuml "$file.txt"`)
LocalResource("$file.png")
end

# ╔═╡ 183a0d6b-c1be-4b33-b615-1975474b35f5
md"""
## Структура бази знань
"""

# ╔═╡ 50263eb1-fbc4-46d6-ae5f-cb4dcf8c6bd7
let
structure_kb = """
@startuml

Class Categories
Class Relations
Class Attributes

Class Values

Class Instances
Class CatInstances
Class AttrCatInstances

Class RelCategories
Class RelCatInstances

Class AttrCategories
Class AttrRelations
Class AttrRelCategories
Class AttrRelCatInstances


Categories"1" -- "M"RelCategories : ref >
Relations"1" -- "M"RelCategories : ref >

Categories"1" -- "M"CatInstances : ref >
Instances"1" -- "M"CatInstances : ref >

CatInstances"1" -- "M"RelCatInstances : ref >
RelCategories"1" -- "M"RelCatInstances : ref >

Attributes"1" -- "M"AttrCategories : ref >
Categories"1" -- "M"AttrCategories : ref >
Values"1" -- "M"AttrCategories : ref >

Attributes"1" -- "M"AttrRelations : ref >
Relations"1" -- "M"AttrRelations : ref >
Values"1" -- "M"AttrRelations : ref >

AttrRelations"1" -- "M"AttrRelCategories : ref >
RelCategories"1" -- "M"AttrRelCategories : ref >
Values"1" -- "M"AttrRelCategories : ref >

AttrCategories"1" -- "M"AttrCatInstances : ref >
CatInstances"1" -- "M"AttrCatInstances : ref >
Values"1" -- "M"AttrCatInstances : ref >

RelCatInstances"1" -- "M"AttrRelCatInstances : ref >
AttrRelCategories"1" -- "M"AttrRelCatInstances : ref >
Values"1" -- "M"AttrRelCatInstances : ref >

@enduml
"""
file = "structure_kb"
open("$file.txt", "w") do io
	write(io, structure_kb)
end
run(`plantuml "$file.txt"`)
LocalResource("$file.png")
end

# ╔═╡ e98cc7a7-7a82-4695-b9c1-97f9a1ae1f30
md"""

#### Мета-дані

* Categories - множина категорій в системі, C
* Relations - множина відношень, які можуть бути між категоріями, R
* Attributes - множина атрибутів, які можуть бути в системі, A

#### Значення атрибутів

* Values - множина всіх зареєстроаваних значень атрибутів, V.

#### Правила

* RelCategories - множина трійок <r, cᵢ, cⱼ>, які вказують, що між категоріями cᵢ і cⱼ може бути відношення r, RC. 
* AttrCategories - множина трійок <c, a, v>, які вказують, що категорія c має атрибут a із значенням v, AC.
* AttrRelations - множина трійок <r, a, v>, які вказують, що відношення r має атрибут a із значенням v, AR.
* AttrRelCategories - множина трійок <rc, a, v>, які вказують, що правило відношення rc має атрибут a із значенням v, що додає або перекриває значення наслідуване з відповідного відношення ar, ARС.

#### Екземпляри сутностей (об'єкти)

* Instances - множина всіх зареєстроаваних об'єктів, O.

#### Факти

* CatInstances - множина пар <c, o>, як вказує, що об'єкт o додано до категорії c і він наслідує її атрибути ac, CO
* AttrCatInstances - множина трійок <co, a, v>, які вказують, що факт належності об'єкта до категорії co має атрибут a із значенням v, що додає або перекриває значення наслідуване з відповідної  категорії r, AСO.
* RelCatInstances - множина трійок <rc, oᵢ, oⱼ>, які вказують, що між об'єктами oᵢ і oⱼ  встановлено відношення згідно правила rc і він наслідує його атрибути, RCO. 
* AttrRelCatInstances - множина трійок <rco, a, v>, які вказують, що факт відношення між об'єктами rco має атрибут a із значенням v, що додає або перекриває значення наслідуване з відповідного правила arс, ARСO.

"""

# ╔═╡ 64309269-3c42-49b1-b000-8f74b5551f60
md"""
## Запити до бази знань
"""

# ╔═╡ 321918b6-7278-445a-b4cc-1a93f682bc2f
md"""

* Створення нових мета-даних, нові елементи множин С, R, A, RC.
* Створення атрибутів з автоматичною реєстрацією значень, нові елементи множини AC, AR, ARC, V.
* Створення нових об'єктів з додаванням їх до категорій, нові елементи множин O, CO.
* Створення нових відношень між об'єктами, нові елементи множини RCO.
* Створення нових атрибутів об'єктів з автоматичною реєстрацією значень, нові елементи множини ARCO, V.

* Вибірка елементів множин, використовуючи зв'язки, логічні операції та операції над множинами.

"""

# ╔═╡ 449e823b-7eb7-4d24-abab-4d60dd156c6b
md"""
## Використані джерела

1. The Julia Programming Language - [https://julialang.org/](https://julialang.org/)

1. PlantUML - [https://plantuml.com/](https://plantuml.com/)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CommonMark = "~0.8.7"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "1a8288d50ca492934993d8f073bb6a607971d1d1"

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
git-tree-sha1 = "86cce6fd164c26bad346cc51ca736e692c9f553c"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.7"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

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
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

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

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

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
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

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
# ╟─326569c4-6e1e-11ed-3cf8-131f3b957d0f
# ╟─f06b12cf-47c9-4fdd-b4b4-d180d43e4c9d
# ╠═fab17a3a-40c9-4b38-945d-fbbbf60fde02
# ╟─b19b0a7e-415c-45d7-b96a-3dfe2fbcac5e
# ╟─d870c7d1-c82c-4127-a397-613042870b08
# ╟─e51f23c3-5df7-4b9b-9f85-7b6bc3f340b7
# ╟─8aba5cb2-38a6-416a-82d3-3be31c26cacb
# ╟─aa7bc3fa-194a-4591-8201-b20459f3888b
# ╠═4e3d15f4-6ec6-4e80-a244-3cbf3215a5ae
# ╟─143ec45b-652c-4e54-9db5-d064c659bf8a
# ╠═2afca4a1-01ae-4546-8fb3-0f5e9ec15a1e
# ╟─183a0d6b-c1be-4b33-b615-1975474b35f5
# ╠═50263eb1-fbc4-46d6-ae5f-cb4dcf8c6bd7
# ╟─e98cc7a7-7a82-4695-b9c1-97f9a1ae1f30
# ╟─64309269-3c42-49b1-b000-8f74b5551f60
# ╟─321918b6-7278-445a-b4cc-1a93f682bc2f
# ╟─449e823b-7eb7-4d24-abab-4d60dd156c6b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
