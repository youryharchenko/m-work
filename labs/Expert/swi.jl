### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ a51a5f11-b175-4311-8d20-798baf0a929e
using Pkg

# ╔═╡ cd3b118a-5613-11ed-36a7-e977074ab6ef
Pkg.add(path="/home/youry/Projects/julia/HerbSWIPL.jl");

# ╔═╡ 2707fbaa-a308-4b58-82a1-4c600cf678f1
using HerbSWIPL

# ╔═╡ 11491363-ccc2-40ea-a801-d88f03226e53
const Clause = HerbSWIPL.Clause

# ╔═╡ dfa6841d-b307-45dc-beb5-b74467ea5b8c
const Comp = HerbSWIPL.Compound

# ╔═╡ 1f7fd272-5fa8-4cf2-9ac6-ec3651a23987
const Const = HerbSWIPL.Const

# ╔═╡ 181d3661-84ba-4889-8f1a-80c112528313
const Var = HerbSWIPL.Var

# ╔═╡ 10d4e9c1-61f0-46b8-8d5a-365fd6353a94
prolog = Swipl()

# ╔═╡ 9d29ec16-7654-4276-8578-dc8f667a3c6f
start(prolog)

# ╔═╡ 7871734c-30e6-403d-8762-a6a247cf2435
clauses = HerbSWIPL.@julog [
  ancestor(sakyamuni, bodhidharma) <<= true,
  teacher(bodhidharma, huike) <<= true,
  teacher(huike, sengcan) <<= true,
  teacher(sengcan, daoxin) <<= true,
  teacher(daoxin, hongren) <<= true,
  teacher(hongren, huineng) <<= true,
  ancestor(A, B) <<= teacher(A, B),
  ancestor(A, C) <<= teacher(B, C) & ancestor(A, B),
  grandteacher(A, C) <<= teacher(A, B) & teacher(B, C)
]

# ╔═╡ 2f65690c-ed95-4635-98c7-36eba1132e63
clause2 = [
	Clause(Comp(:ancestor, [Const(:sakyamuni), Const(:bodhidharma)]), []),
	Clause(Comp(:teacher, [Const(:bodhidharma), Const(:huike)]), []),
  	Clause(Comp(:teacher, [Const(:huike), Const(:sengcan)]), []),
  	Clause(Comp(:teacher, [Const(:sengcan), Const(:daoxin)]), []),
  	Clause(Comp(:teacher, [Const(:daoxin), Const(:hongren)]), []),
  	Clause(Comp(:teacher, [Const(:hongren), Const(:huineng)]), []),
	Clause(Comp(:ancestor, [Var(:X), Var(:Y)]), 
		[Comp(:teacher, [Var(:X), Var(:Y)])]),
	Clause(Comp(:ancestor, [Var(:X), Var(:Z)]), 
		[Comp(:teacher, [Var(:Y), Var(:Z)]), Comp(:ancestor, [Var(:X), Var(:Y)])]),
	Clause(Comp(:grandteacher, [Var(:X), Var(:Z)]), 
		[Comp(:teacher, [Var(:X), Var(:Y)]), Comp(:teacher, [Var(:Y), Var(:Z)])]),
]

# ╔═╡ 8e0ca490-bcc6-4c71-a9c1-23f0cd894d9d
resolve(prolog, 
	Comp(:ancestor, [Const(:sakyamuni), Const(:bodhidharma)]), 
	clause2)

# ╔═╡ 0062e813-2856-4d28-8392-f1876cc45c11
resolve(prolog, 
	Comp(:grandteacher, [Var(:X), Var(:Y)]),
	clause2)

# ╔═╡ 42321b48-bdf0-43b9-9e7f-2c815365a1af
resolve(prolog, 
	Comp(:ancestor, [Const(:bodhidharma), Var(:X)]), 
	clause2)

# ╔═╡ Cell order:
# ╠═a51a5f11-b175-4311-8d20-798baf0a929e
# ╠═cd3b118a-5613-11ed-36a7-e977074ab6ef
# ╠═2707fbaa-a308-4b58-82a1-4c600cf678f1
# ╠═11491363-ccc2-40ea-a801-d88f03226e53
# ╠═dfa6841d-b307-45dc-beb5-b74467ea5b8c
# ╠═1f7fd272-5fa8-4cf2-9ac6-ec3651a23987
# ╠═181d3661-84ba-4889-8f1a-80c112528313
# ╠═10d4e9c1-61f0-46b8-8d5a-365fd6353a94
# ╠═9d29ec16-7654-4276-8578-dc8f667a3c6f
# ╠═7871734c-30e6-403d-8762-a6a247cf2435
# ╠═2f65690c-ed95-4635-98c7-36eba1132e63
# ╠═8e0ca490-bcc6-4c71-a9c1-23f0cd894d9d
# ╠═0062e813-2856-4d28-8392-f1876cc45c11
# ╠═42321b48-bdf0-43b9-9e7f-2c815365a1af
