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

# ╔═╡ de4a474b-1c6d-4c9a-a489-7dde43dd3003


# ╔═╡ 40363c39-3e86-4bcb-84f2-ac516fcc2ee9
@c! kb :test_cat (
	ac=[(a=:test_attr_1, v=true), (a=:test_attr_2, v=false)],
	rct=[(r=:test_rel, ct=:test_cat_to)],
	rcf=[(r=:test_rel, cf=:test_cat_from)],
	arct=[(r=:test_rel, ct=:test_cat_to, a=:test_attr_3, v=0)],
	arcf=[(r=:test_rel, cf=:test_cat_from, a=:test_attr_3, v=0)],
)

# ╔═╡ fd74ec9b-af25-4025-b417-8be5cdfaf40e
select(C, kb)

# ╔═╡ 700eb6e9-6a84-4601-8490-b7e0210699c2
select(A, kb)

# ╔═╡ 0d74dc79-3228-4db6-b39e-7b7941be1f28
select(AC, kb)

# ╔═╡ f834746e-9934-4b82-bbad-5a4d69c8f51e
@r! kb :test_rel

# ╔═╡ aac04ff7-2ddf-4014-b7cb-4d6a83519e63
@r! kb :test_rel (
	ar=[(a=:test_attr_3, v=nothing)],
	rc=[(cf=:test_cat, ct=:test_cat_to)],
	arc=[(cf=:test_cat, ct=:test_cat_to, a=:test_attr_3, v=1)],
)


# ╔═╡ 2bcd188e-06e9-40b9-b808-eabef665226f
select(R, kb)

# ╔═╡ 04ecc61d-0fed-4cb2-b88e-3eab335ab547
select(AR, kb)

# ╔═╡ 1c73068d-685f-443e-a8d5-4880cb8c66b5
select(RC, kb)

# ╔═╡ 1604708b-ef81-4046-95ff-d6867d4c875e
select(ARC, kb)

# ╔═╡ a4f4c1f5-9563-4d3e-8f1e-14338705b107
@o! kb :test_obj_1 (
	co=[(c=:test_cat,)],
	aco=[(c=:test_cat, a=:test_attr_1, v=2)],
	rcof=[(c=:test_cat, r=:test_rel, cf=:test_cat_from, of=:test_obj_2)],
	arcof=[(c=:test_cat, r=:test_rel, cf=:test_cat_from, of=:test_obj_2, a=:test_attr_3, v=3)],
)

# ╔═╡ d9548779-34ea-4d44-a4c6-f55df30f2d95
@o! kb :test_obj_2 (
	co=[(c=:test_cat,)],
	aco=[(c=:test_cat, a=:test_attr_3, v=5)],
	rcot=[(c=:test_cat, r=:test_rel, ct=:test_cat_to, ot=:test_obj_3)],
	arcot=[(c=:test_cat, r=:test_rel, ct=:test_cat_to, ot=:test_obj_3, a=:test_attr_3, v=5)],
)

# ╔═╡ 8853c32a-c8eb-49a3-ac83-ee0ea18257aa
select(O, kb; cs=[:oid, :vid, :v])

# ╔═╡ ef85cb6f-1631-4815-bb1f-62ef5f6eb72b
select(CO, kb)

# ╔═╡ 38bf46ef-1724-4cde-a95d-137fd23fcb9e
select(ACO, kb)

# ╔═╡ 5e82b26d-a75b-4a4b-88b0-b45dff2f35d6
select(AR, kb)

# ╔═╡ 58bb0639-a6c7-4adb-9cc8-564f269ad1b1
select(RCO, kb)

# ╔═╡ 7ded8b87-acf3-4bb3-8b6b-e6398328f4aa
select(ARCO, kb)

# ╔═╡ 5fce67b4-8a5a-4836-8db7-b5199cb934e8
(; zip((Symbol(k) for k in 1:5), (v for v in 6:10))...)

# ╔═╡ c3015ddb-ab22-415f-99c1-02227f6439e7
@macroexpand @c kb :test_cat

# ╔═╡ 3e9184de-363b-41c0-b240-a8e3a8bb8964
@c kb :test_cat

# ╔═╡ 7e951a1c-5cce-43ef-a078-5ffb5faeb6da
co1 = @co kb :test_cat

# ╔═╡ e5a527a6-5aba-46a1-b640-ec9e9c635bdf
co1[:co][2][:aco][:test_attr_3]

# ╔═╡ fbbdc53e-3a23-4d49-b748-530486b55366
@c kb :test_cat_to

# ╔═╡ e8479679-9720-4075-8599-14ac6bc6fca3
@co kb :test_cat_to

# ╔═╡ a7fd58b0-87f1-4a5b-8459-cbf6c43d0ebe
@c kb :test_cat_from

# ╔═╡ f8a14309-1a02-43f3-8427-50651da29f6f
@co kb :test_cat_from

# ╔═╡ e92bc0fa-2966-4d0f-ba78-185f8282b30c
@r kb :test_rel

# ╔═╡ Cell order:
# ╠═d124b18a-97e7-11ed-09fe-5b5a75f90040
# ╠═6e765c0d-0155-4a76-9d49-fcb7051b7ea8
# ╠═0a2319d1-77cf-4bda-aaca-55f937a217ee
# ╠═018cd9a9-f4e0-487b-a8cb-6405ed9eb16f
# ╠═29e598ed-a09d-48dd-b819-5b40a1d35094
# ╠═de4a474b-1c6d-4c9a-a489-7dde43dd3003
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
# ╠═a4f4c1f5-9563-4d3e-8f1e-14338705b107
# ╠═d9548779-34ea-4d44-a4c6-f55df30f2d95
# ╠═8853c32a-c8eb-49a3-ac83-ee0ea18257aa
# ╠═ef85cb6f-1631-4815-bb1f-62ef5f6eb72b
# ╠═38bf46ef-1724-4cde-a95d-137fd23fcb9e
# ╠═5e82b26d-a75b-4a4b-88b0-b45dff2f35d6
# ╠═58bb0639-a6c7-4adb-9cc8-564f269ad1b1
# ╠═7ded8b87-acf3-4bb3-8b6b-e6398328f4aa
# ╠═5fce67b4-8a5a-4836-8db7-b5199cb934e8
# ╠═c3015ddb-ab22-415f-99c1-02227f6439e7
# ╠═3e9184de-363b-41c0-b240-a8e3a8bb8964
# ╠═7e951a1c-5cce-43ef-a078-5ffb5faeb6da
# ╠═e5a527a6-5aba-46a1-b640-ec9e9c635bdf
# ╠═fbbdc53e-3a23-4d49-b748-530486b55366
# ╠═e8479679-9720-4075-8599-14ac6bc6fca3
# ╠═a7fd58b0-87f1-4a5b-8459-cbf6c43d0ebe
# ╠═f8a14309-1a02-43f3-8427-50651da29f6f
# ╠═e92bc0fa-2966-4d0f-ba78-185f8282b30c
