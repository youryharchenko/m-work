### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 6a23cc63-4244-4265-9dde-948ef024f4fd
using Pkg

# ╔═╡ 55c36547-0995-4f0b-8616-2876b1b90715
Pkg.add("CommonMark");

# ╔═╡ 12a2c7f0-1e9e-4ffa-a80f-dc6da15535aa
Pkg.add(path="/home/youry/Projects/julia/HerbSWIPL.jl");

# ╔═╡ 687acfd4-5782-11ed-0922-792872b5578a
using CommonMark

# ╔═╡ 7907e8bf-14b0-4702-a3cc-5dd3e9be368b
using HerbSWIPL

# ╔═╡ c1de69a1-0b2b-4d2b-95cf-f325e100c85f
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

Лабораторна робота 1

Продукційне представлення знань

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

# ╔═╡ 2762d0ba-10e0-4a9e-9f32-2f1937b98db6
cm"""
<div class="pagebreak"> </div>

#### В роботі використано мову Julia та її пакети, а також SWI-Prolog

"""

# ╔═╡ c20d6e5d-9761-4c3a-aee9-b18deeab9b8b
begin
	const Clause = HerbSWIPL.Clause
	const Comp = HerbSWIPL.Compound
	const Const = HerbSWIPL.Const
	const Var = HerbSWIPL.Var
end;

# ╔═╡ cf40f46b-7fcb-49b9-a34e-db9343a8b0c7
cm"""
#### Ініціалізуємо Prolog
"""

# ╔═╡ bc066c58-b6bf-4352-ad90-2c56998fe7e8
begin
	prolog = Swipl()
	start(prolog)
end

# ╔═╡ a73222a5-7821-4dfb-aa09-2fc714ce3428
cm"""
#### Правила класифікації птахів
"""

# ╔═╡ a92e6436-8c6d-4bce-9d1a-9ed97d48881a
rules = HerbSWIPL.@julog [
	bird(лайсанський_альбатрос) <<= 
		family(альбатрос) & 
		color(білий) &
		voice(не_має_значення),
	bird(чорноногий_альбатрос) <<= 
		family(альбатрос) & 
		color(темний) &
		voice(не_має_значення),
	bird(мандрівний_альбатрос) <<= 
		family(альбатрос) & 
		color(світлий) &
		voice(не_має_значення),
	bird(королівський_альбатрос) <<= 
		family(альбатрос) & 
		color(світлий) &
		voice(не_має_значення),
	bird(лебідь_свистун) <<= 
		family(лебідь) &
		color(білий) &
		voice(глухий_музичний_свист),
	bird(лебідь_трубач) <<= 
		family(лебідь) &
		color(білий) &
		voice(голосно_трубить),
	family(альбатрос) <<=
		bill(довгий) &
		live(море) &
		size(дуже_великий),
	family(лебідь) <<=
		bill(середній) &
		live(прісна_водойма) &
		size(великий),
]

# ╔═╡ 1f35da91-6bd7-4532-9792-cfc1099e65ec
cm"""
#### Функція запиту до Prolog
"""

# ╔═╡ 52b80213-322c-4fa8-b7ee-dff32994e562
function ask(prolog, goal, cond, rules)
	cl = append!(deepcopy(rules), cond)
	resolve(prolog, goal, cl)
end

# ╔═╡ 0f79a5cc-ff03-422f-9cb3-686b1d41e146
cm"""
#### Запити до системи Prolog для визначення виду птаха за ознаками
"""

# ╔═╡ cc0c8697-2ff4-4866-9a4f-519eb427a39a
cm"""
##### Вдало: чорноногий_альбатрос
"""

# ╔═╡ 1dd0d4dd-224e-4055-8792-bae7db7743b2
ask(prolog, 
	HerbSWIPL.@julog(bird(X)),
	HerbSWIPL.@julog(
		[
			color(темний) <<= true,
			bill(довгий) <<= true,
			size(дуже_великий) <<= true,
			live(море) <<= true,
			voice(не_має_значення) <<= true,
		]), 
	rules
)

# ╔═╡ f695368a-b174-40cc-87e0-68f6d34613a9
cm"""
##### Вдало: лайсанський_альбатрос
"""

# ╔═╡ 31a94755-70fd-4362-899a-92acd5b81542
ask(prolog, 
	HerbSWIPL.@julog(bird(X)),
	HerbSWIPL.@julog(
		[
			color(білий) <<= true,
			bill(довгий) <<= true,
			size(дуже_великий) <<= true,
			live(море) <<= true,
			voice(не_має_значення) <<= true,
		]),
	rules
)

# ╔═╡ 65a4cf8f-49b7-4202-b2de-5887dd0c2021
cm"""
##### Вдало: мандрівний_альбатрос або королівський_альбатрос
"""

# ╔═╡ efc6a5f1-5d0f-42de-9119-7d63ca33cd7e
ask(prolog, 
	HerbSWIPL.@julog(bird(X)),
	HerbSWIPL.@julog(
		[
			color(світлий) <<= true,
			bill(довгий) <<= true,
			size(дуже_великий) <<= true,
			live(море) <<= true,
			voice(не_має_значення) <<= true,
		]),
	rules
)

# ╔═╡ bd83ba30-82ee-4643-97d5-bc40feaeceb3
cm"""
##### Невдало: за цими ознаками нема в базі
"""

# ╔═╡ d996f719-57c5-465f-bac9-fc25df56e8df
ask(prolog, 
	HerbSWIPL.@julog(bird(X)),
	HerbSWIPL.@julog(
		[
			color(білий) <<= true,
			bill(середній) <<= true,
			size(великий) <<= true,
			live(прісна_водойма) <<= true,
			voice(не_має_значення) <<= true,
		]),
	rules
)

# ╔═╡ 9b9211c2-92b2-4c57-bede-d44628497eaf
cm"""
##### Вдало: лебідь_трубач
"""

# ╔═╡ 37072af2-0fc7-477b-a6ce-f21e92df4a27
ask(prolog, 
	HerbSWIPL.@julog(bird(X)),
	HerbSWIPL.@julog(
		[
			color(білий) <<= true,
			bill(середній) <<= true,
			size(великий) <<= true,
			live(прісна_водойма) <<= true,
			voice(голосно_трубить) <<= true,
		]),
	rules
)

# ╔═╡ ca9181fb-e5b1-4405-8d2e-ae79054b11da
cm"""
#### Висновок. За допомогою мови Julia та системи логічного програмування SWI-Prolog можливо розробити просту експертну систему
"""

# ╔═╡ Cell order:
# ╟─687acfd4-5782-11ed-0922-792872b5578a
# ╟─c1de69a1-0b2b-4d2b-95cf-f325e100c85f
# ╟─2762d0ba-10e0-4a9e-9f32-2f1937b98db6
# ╠═6a23cc63-4244-4265-9dde-948ef024f4fd
# ╠═55c36547-0995-4f0b-8616-2876b1b90715
# ╠═12a2c7f0-1e9e-4ffa-a80f-dc6da15535aa
# ╠═7907e8bf-14b0-4702-a3cc-5dd3e9be368b
# ╠═c20d6e5d-9761-4c3a-aee9-b18deeab9b8b
# ╟─cf40f46b-7fcb-49b9-a34e-db9343a8b0c7
# ╠═bc066c58-b6bf-4352-ad90-2c56998fe7e8
# ╟─a73222a5-7821-4dfb-aa09-2fc714ce3428
# ╠═a92e6436-8c6d-4bce-9d1a-9ed97d48881a
# ╟─1f35da91-6bd7-4532-9792-cfc1099e65ec
# ╠═52b80213-322c-4fa8-b7ee-dff32994e562
# ╟─0f79a5cc-ff03-422f-9cb3-686b1d41e146
# ╟─cc0c8697-2ff4-4866-9a4f-519eb427a39a
# ╠═1dd0d4dd-224e-4055-8792-bae7db7743b2
# ╟─f695368a-b174-40cc-87e0-68f6d34613a9
# ╠═31a94755-70fd-4362-899a-92acd5b81542
# ╟─65a4cf8f-49b7-4202-b2de-5887dd0c2021
# ╠═efc6a5f1-5d0f-42de-9119-7d63ca33cd7e
# ╟─bd83ba30-82ee-4643-97d5-bc40feaeceb3
# ╠═d996f719-57c5-465f-bac9-fc25df56e8df
# ╟─9b9211c2-92b2-4c57-bede-d44628497eaf
# ╠═37072af2-0fc7-477b-a6ce-f21e92df4a27
# ╠═ca9181fb-e5b1-4405-8d2e-ae79054b11da
