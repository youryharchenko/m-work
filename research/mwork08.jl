### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ d124b18a-97e7-11ed-09fe-5b5a75f90040
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	Pkg.instantiate()
	Pkg.add("Revise")
	Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ 6e765c0d-0155-4a76-9d49-fcb7051b7ea8
using Revise, KBs

# ╔═╡ 0a2319d1-77cf-4bda-aaca-55f937a217ee
let
	init_script = quote
    	a = 11
    	b = 22

    	"OK"
	end
	
	kb = init(init_script)
	save(kb, "mwork08/save")
end

# ╔═╡ 018cd9a9-f4e0-487b-a8cb-6405ed9eb16f
kb = load("mwork08/save")

# ╔═╡ 29e598ed-a09d-48dd-b819-5b40a1d35094
@c! kb :test_cat

# ╔═╡ 40363c39-3e86-4bcb-84f2-ac516fcc2ee9
@c! kb :test_cat (
	ac=[(test_attr_1, true), (test_attr_2, false)],
	rct=[(test_rel, test_cat_to)],
	rcf=[(test_rel, test_cat_from)],
)

# ╔═╡ fd74ec9b-af25-4025-b417-8be5cdfaf40e
select(KBs.C, kb)

# ╔═╡ 700eb6e9-6a84-4601-8490-b7e0210699c2
select(KBs.A, kb)

# ╔═╡ 0d74dc79-3228-4db6-b39e-7b7941be1f28
select(KBs.AC, kb)

# ╔═╡ f834746e-9934-4b82-bbad-5a4d69c8f51e
@r! kb :test_rel

# ╔═╡ aac04ff7-2ddf-4014-b7cb-4d6a83519e63
@r! kb :test_rel (
	ar=[(test_attr_3, nothing)],
	rc=[(test_cat, test_cat_to)],
	arc=[(test_cat, test_cat_to, test_attr_3, 1)],
)


# ╔═╡ 2bcd188e-06e9-40b9-b808-eabef665226f
select(KBs.R, kb)

# ╔═╡ 04ecc61d-0fed-4cb2-b88e-3eab335ab547
select(KBs.AR, kb)

# ╔═╡ 1c73068d-685f-443e-a8d5-4880cb8c66b5
select(KBs.RC, kb)

# ╔═╡ 1604708b-ef81-4046-95ff-d6867d4c875e
select(KBs.ARC, kb)

# ╔═╡ Cell order:
# ╠═d124b18a-97e7-11ed-09fe-5b5a75f90040
# ╠═6e765c0d-0155-4a76-9d49-fcb7051b7ea8
# ╠═0a2319d1-77cf-4bda-aaca-55f937a217ee
# ╠═018cd9a9-f4e0-487b-a8cb-6405ed9eb16f
# ╠═29e598ed-a09d-48dd-b819-5b40a1d35094
# ╠═40363c39-3e86-4bcb-84f2-ac516fcc2ee9
# ╠═fd74ec9b-af25-4025-b417-8be5cdfaf40e
# ╠═700eb6e9-6a84-4601-8490-b7e0210699c2
# ╠═0d74dc79-3228-4db6-b39e-7b7941be1f28
# ╠═f834746e-9934-4b82-bbad-5a4d69c8f51e
# ╠═aac04ff7-2ddf-4014-b7cb-4d6a83519e63
# ╠═2bcd188e-06e9-40b9-b808-eabef665226f
# ╠═04ecc61d-0fed-4cb2-b88e-3eab335ab547
# ╠═1c73068d-685f-443e-a8d5-4880cb8c66b5
# ╠═1604708b-ef81-4046-95ff-d6867d4c875e
