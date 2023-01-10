### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 382b97cf-a818-4af9-9c9b-9ab83e6a2c3e
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	#Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.instantiate()
	Pkg.add("Revise")
	Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ ab294525-c913-4c0a-b2fd-ee60484826a0
using Revise, KBs

# ╔═╡ 59a569a8-90d8-11ed-3186-39a20377bba6
#using BSON,UUIDs, Parameters, DataFrames, TextAnalysis, Languages

# ╔═╡ 29adc2c8-838d-43c1-8b18-ac3a190623d5
#KB = ingredients("mwork04/kb.jl")

# ╔═╡ 6896c50a-a8c1-4aa4-b3e4-990927131bbd
kb = KBs.load("kb.bson")

# ╔═╡ 67173d68-1efd-46ab-b6ad-09287d487eb8
KBs.select_v(kb)

# ╔═╡ f561b509-e20c-4549-b123-d245d839cada
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ Cell order:
# ╠═59a569a8-90d8-11ed-3186-39a20377bba6
# ╠═29adc2c8-838d-43c1-8b18-ac3a190623d5
# ╠═382b97cf-a818-4af9-9c9b-9ab83e6a2c3e
# ╠═ab294525-c913-4c0a-b2fd-ee60484826a0
# ╠═6896c50a-a8c1-4aa4-b3e4-990927131bbd
# ╠═67173d68-1efd-46ab-b6ad-09287d487eb8
# ╠═f561b509-e20c-4549-b123-d245d839cada
