### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 0926c818-6587-11ed-0c10-dbf7a3118d95
using Pkg

# ╔═╡ 468a8e6e-65a4-4c0f-9ffe-364c5ba0d489
Pkg.add(path="/home/youry/Projects/julia/HerbSWIPL.jl")

# ╔═╡ b7aee1d1-644b-492b-a151-6bdb990eb5ca
Pkg.add("CSV")

# ╔═╡ 1d56a2f6-a21a-4b4a-a496-869000310e42
Pkg.add("DataFrames")

# ╔═╡ 60c2a661-1d19-4744-955f-9ed43ad82b6f
Pkg.add("CommonMark")

# ╔═╡ 5b5d8fd6-5bc5-485d-894d-e1a484f8fd43
using CommonMark

# ╔═╡ 114fe89b-6173-48c1-be58-dd21b2ab516f
using HerbSWIPL

# ╔═╡ ee4e8b07-2776-4757-8991-e8332b2c27a7
using CSV, DataFrames

# ╔═╡ c59bfc7e-c5b6-4834-876b-864508909134


# ╔═╡ 1797bd68-f474-42f1-9e11-d7db8277e4e9
begin
	const Clause = HerbSWIPL.Clause
	const Comp = HerbSWIPL.Compound
	const Const = HerbSWIPL.Const
	const Var = HerbSWIPL.Var
end;

# ╔═╡ dfb7d4c6-b5ea-436c-b94c-6c858671269f


# ╔═╡ b269e7ed-499b-4afa-a01e-eed473d91690
cm"""
### Завантаження журналу в DataFrame
"""

# ╔═╡ 98e4b0b9-703f-4b82-b906-fe0ce4bbc28f
logs = CSV.read("logs.csv", DataFrame)

# ╔═╡ f8fcc3ba-89c7-4901-b6bb-d6edd18eae3c
facts = let
	clauses = Vector{HerbSWIPL.Julog.Clause}(undef, nrow(logs))
	i = 0
	for r in eachrow(logs)
		i+=1
		clauses[i] = Clause(
			Comp(:record, [
				Const(Symbol(r.ip)), 
				Const(Symbol(r.met)),
				Const(Symbol(r.ret)),
				Const(Symbol(r.br)),
				Const(Symbol(r.count)),
			]), []
		)
	end
	clauses
end

# ╔═╡ de66c6b6-16b7-4d27-946f-f92f299655db
good_rules = HerbSWIPL.@julog [
	good(X) <<= X < 400,
	good_req(_, _, X, _, _) <<= good(X),
]


# ╔═╡ e01fc2a6-66a4-41ed-9f04-24c3be3f83c7
let
	prolog = Swipl()
	start(prolog)

	append!(facts, good_rules)
	
	resolve(prolog, 
		Comp(:record, [
			Const(Symbol("67.227.39.235")), 
			Const(Symbol("GET / HTTP/1.1")),
			Const(Symbol(301)),
			Var(Symbol("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36")),
			Var(:Count),
		]), 
		facts)

	#resolve(prolog,
	#	Comp(:good_rec, [
	#		Const(Symbol("67.227.39.235")), 
	#		Const(Symbol("GET / HTTP/1.1")),
	#		Const(Symbol(301)),
	#		Var(Symbol("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36")),
	#		Var(:Count),
	#	]), 
	#	facts)
end

# ╔═╡ Cell order:
# ╠═0926c818-6587-11ed-0c10-dbf7a3118d95
# ╠═5b5d8fd6-5bc5-485d-894d-e1a484f8fd43
# ╠═468a8e6e-65a4-4c0f-9ffe-364c5ba0d489
# ╠═b7aee1d1-644b-492b-a151-6bdb990eb5ca
# ╠═1d56a2f6-a21a-4b4a-a496-869000310e42
# ╠═60c2a661-1d19-4744-955f-9ed43ad82b6f
# ╠═114fe89b-6173-48c1-be58-dd21b2ab516f
# ╠═c59bfc7e-c5b6-4834-876b-864508909134
# ╠═1797bd68-f474-42f1-9e11-d7db8277e4e9
# ╠═dfb7d4c6-b5ea-436c-b94c-6c858671269f
# ╟─b269e7ed-499b-4afa-a01e-eed473d91690
# ╠═ee4e8b07-2776-4757-8991-e8332b2c27a7
# ╠═98e4b0b9-703f-4b82-b906-fe0ce4bbc28f
# ╠═f8fcc3ba-89c7-4901-b6bb-d6edd18eae3c
# ╠═de66c6b6-16b7-4d27-946f-f92f299655db
# ╠═e01fc2a6-66a4-41ed-9f04-24c3be3f83c7
