### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 36a5bf8a-fb1b-48b6-a528-28b99d6e540b
using Pkg

# ╔═╡ fbbea5a6-17d1-4fd8-8ac5-3f9c6b58e721
Pkg.add(path="/home/youry/Projects/julia/HerbSWIPL.jl")

# ╔═╡ 4490c1a4-59e0-11ed-2db6-e7129cee06c8
using CommonMark

# ╔═╡ f433bd64-7cf4-4381-af03-c7c18107886c
using HerbSWIPL

# ╔═╡ 35958426-1bfe-4ead-b8de-66afd8c72b15
cm"""
---
<div align="center">

Національний університет біоресурсів і природокористування України

Факультет інформаційних технологій

Кафедра комп'ютерних наук

<br/><br/>

Лабораторна робота 4

Фреймова модель представлення знань

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

# ╔═╡ cfd6d5d4-eb95-4876-96a2-66af391ad27f
cm"""
#### В роботі використано мову Julia та її пакети, а також SWI-Prolog
"""

# ╔═╡ 69fb82d0-07dd-468d-a3f3-a80b38d21d3d
begin
	const Clause = HerbSWIPL.Clause
	const Comp = HerbSWIPL.Compound
	const Const = HerbSWIPL.Const
	const Var = HerbSWIPL.Var
end;

# ╔═╡ 4f922c63-650f-4683-be18-744f4f7c6d4d
cm"""
#### Ініціалізуємо Prolog
"""

# ╔═╡ 85ae6f96-414c-4825-b988-e43203eefbd0
begin
	prolog = Swipl()
	start(prolog)
end

# ╔═╡ e454b1ca-6e3e-4058-bd4c-4065890ead78
cm"""
#### Фреймова модель ієрархії тварин
"""

# ╔═╡ a4fc4dfb-d387-4ff1-bc17-fd8dcf0cbbdc
rules = HerbSWIPL.@julog [
	frame(name(bird),
		isa(animal),
		[travel(flies), feathers],
		[ ]) <<= true,
	frame(name(penguin),
		isa(bird),
		[color(brown)],
		[travel(walks)]) <<= true,
	frame(name(canary),
		isa(bird),
		[color(yellow), call(sing)],
		[size(small)]) <<= true,
	frame(name(tweety),
		isa(canary),
		[ ],
		[color(white)]) <<= true,
	get(Prop, Object) <<=
		frame(name(Object), _, List_of_properties, _) &
		member(Prop, List_of_properties),
	get(Prop, Object) <<=
		frame(name(Object), _, _, List_of_defaults) &
		member(Prop, List_of_defaults),
	get(Prop, Object) <<=
		frame(name(Object), isa(Parent), _, _) &
		get(Prop, Parent),
	
]

# ╔═╡ 53a18b1d-43d7-4d63-bd58-9476f624530d
cm"""
#### Функція запиту до Prolog
"""

# ╔═╡ 20fe5f80-8f3f-4c30-9231-e943ba68d891
function ask(prolog, goal, rules)
	resolve(prolog, goal, rules)
end

# ╔═╡ e8de56da-bed6-44cd-a6df-680f2fa8b0a1
cm"""
#### Запити до системи фреймів
"""

# ╔═╡ 73413d37-7975-47c7-9f63-ffe0fa514d39
cm"""
#### Птахи літають?
"""

# ╔═╡ 92bf58f5-e8db-416c-8d7a-7738ebf1347a
ask(prolog, 
	HerbSWIPL.@julog(get(travel(flies), bird)),
	rules
)

# ╔═╡ 0b0236c3-cc54-4e8c-b296-93abed91e6bd
cm"""
#### Канарка літає?
"""

# ╔═╡ 58af9c8b-068a-4c09-9de5-173f1e9a19c7
ask(prolog, 
	HerbSWIPL.@julog(get(travel(flies), canary)),
	rules
)

# ╔═╡ 14eac272-5085-4545-96e7-f6c7ebcc9d35
cm"""
#### Пінгвін ходить?
"""

# ╔═╡ 758ec793-30ab-481b-a7f2-86c179675d13
ask(prolog, 
	HerbSWIPL.@julog(get(travel(walks), penguin)),
	rules
)

# ╔═╡ 7422ee2d-6a7d-4ae3-a09e-0d0ab3d2ec79
cm"""
#### Канарка ходить?
"""

# ╔═╡ 589af0b5-be2e-48d8-9b1f-31a936345054
ask(prolog, 
	HerbSWIPL.@julog(get(travel(walks), canary)),
	rules
)

# ╔═╡ bd5fef63-36ab-44a9-9392-c45f00a3f3c6
cm"""
#### Висновок. За допомогою мови Julia та системи логічного програмування SWI-Prolog можливо представити фреймову модель та робити до неї запити
"""

# ╔═╡ Cell order:
# ╟─4490c1a4-59e0-11ed-2db6-e7129cee06c8
# ╟─35958426-1bfe-4ead-b8de-66afd8c72b15
# ╟─cfd6d5d4-eb95-4876-96a2-66af391ad27f
# ╠═36a5bf8a-fb1b-48b6-a528-28b99d6e540b
# ╠═fbbea5a6-17d1-4fd8-8ac5-3f9c6b58e721
# ╠═f433bd64-7cf4-4381-af03-c7c18107886c
# ╠═69fb82d0-07dd-468d-a3f3-a80b38d21d3d
# ╟─4f922c63-650f-4683-be18-744f4f7c6d4d
# ╠═85ae6f96-414c-4825-b988-e43203eefbd0
# ╟─e454b1ca-6e3e-4058-bd4c-4065890ead78
# ╠═a4fc4dfb-d387-4ff1-bc17-fd8dcf0cbbdc
# ╟─53a18b1d-43d7-4d63-bd58-9476f624530d
# ╠═20fe5f80-8f3f-4c30-9231-e943ba68d891
# ╟─e8de56da-bed6-44cd-a6df-680f2fa8b0a1
# ╟─73413d37-7975-47c7-9f63-ffe0fa514d39
# ╠═92bf58f5-e8db-416c-8d7a-7738ebf1347a
# ╟─0b0236c3-cc54-4e8c-b296-93abed91e6bd
# ╠═58af9c8b-068a-4c09-9de5-173f1e9a19c7
# ╟─14eac272-5085-4545-96e7-f6c7ebcc9d35
# ╠═758ec793-30ab-481b-a7f2-86c179675d13
# ╟─7422ee2d-6a7d-4ae3-a09e-0d0ab3d2ec79
# ╠═589af0b5-be2e-48d8-9b1f-31a936345054
# ╟─bd5fef63-36ab-44a9-9392-c45f00a3f3c6
