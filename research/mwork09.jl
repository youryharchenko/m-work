### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 3575e562-c0a0-4b4e-8946-b3126b9420e0
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	Pkg.instantiate()
	#Pkg.add("Revise")
	#Pkg.add("Julog")
	Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ 9f486d46-9d8a-11ed-1d5b-2db69b21e703
using Revise, Julog, Serialization, KBs, UUIDs

# ╔═╡ 0df734c3-152c-4144-be22-012ac0f6f3fa
dir = "mwork08/save"

# ╔═╡ 787bf1a5-6e1c-4712-936a-3476b6ecb5de
kb = load(dir)

# ╔═╡ 9ac2ed42-47f1-4395-a955-a6f557f56775
@c! kb :test_cat (
	ac=[(a=:test_attr_1, v=true), (a=:test_attr_2, v=false)],
	rct=[(r=:test_rel, ct=:test_cat_to)],
	rcf=[(r=:test_rel, cf=:test_cat_from)],
	arct=[(r=:test_rel, ct=:test_cat_to, a=:test_attr_3, v=0)],
	arcf=[(r=:test_rel, cf=:test_cat_from, a=:test_attr_3, v=0)],
)

# ╔═╡ a4a83ed5-af8e-469e-8d4a-43861240853a
@o! kb :test_obj_1 (
	co=[(c=:test_cat,)],
	aco=[(c=:test_cat, a=:test_attr_1, v=2)],
	rcof=[(c=:test_cat, r=:test_rel, cf=:test_cat_from, of=:test_obj_2)],
	arcof=[(c=:test_cat, r=:test_rel, cf=:test_cat_from, of=:test_obj_2, a=:test_attr_3, v=3)],
)


# ╔═╡ 2787a28b-aeee-406d-8de2-25bca23ede07
@o! kb :test_obj_2 (
	co=[(c=:test_cat,)],
	aco=[(c=:test_cat, a=:test_attr_3, v=5)],
	rcot=[(c=:test_cat, r=:test_rel, ct=:test_cat_to, ot=:test_obj_3)],
	arcot=[(c=:test_cat, r=:test_rel, ct=:test_cat_to, ot=:test_obj_3, a=:test_attr_3, v=5)],
)

# ╔═╡ b0b2c5d3-375c-4710-9acd-aa3a6fbd4504
@r! kb :test_rel (
	ar=[(a=:test_attr_3, v=nothing)],
	rc=[(cf=:test_cat, ct=:test_cat_to)],
	arc=[(cf=:test_cat, ct=:test_cat_to, a=:test_attr_3, v=1)],
)

# ╔═╡ eea0cb04-b1f4-4c1a-a7be-7b50e5f5b931


# ╔═╡ 07874caa-1583-407f-b78b-f56aba8bda5e
rules = @julog [
	cat(ID, Name) <<= c(ID, VID) & v(VID, Name),
	
	obj(ID, Name) <<= o(ID, VID) & v(VID, Name),
	
	cat!obj(ID, CName, OName) <<= co(ID, CID, OID) & cat(CID, CName) & obj(OID, OName),
	
	rel(ID, Name) <<= r(ID, VID) & v(VID, Name),
	
	rel!cat(ID, RName, CFName, CTName) <<= rc(ID, RID, CFID, CTID) & rel(RID, RName) & cat(CFID, CFName) & cat(CTID, CTName),
	
	rel!cat!obj(ID, RName, CFName, OFName, CTName, OTName) <<= rco(ID, RCID, COFID, COTID) & rel!cat(RCID, RName, CFName, CTName) & cat!obj(COFID, CFName, OFName) & cat!obj(COTID, CTName, OTName),
	
	attr(ID, Name) <<= a(ID, VID) & v(VID, Name),
	
	cat!attr(ID, CName, AName, Value) <<= ac(ID, CID, AID, VID) & cat(CID, CName) & attr(AID, AName) & v(VID, Value),
	
	cat!obj!attr(ID, CName, OName, AName, Value, Default) <<= aco(ID, COID, ACID, VID) & cat!obj(COID, CName, OName) & cat!attr(ACID, CName, AName, Default) & v(VID, Value),
	
	rel!attr(ID, RName, AName, Value) <<= ar(ID, RID, AID, VID) & rel(RID, RName) & attr(AID, AName) & v(VID, Value),

	rel!cat!attr(ID, RName, CFName, CTName, AName, Value, Default) <<= arc(ID, RCID, ARID, VID) & rel!cat(RCID, RName, CFName, CTName) & rel!attr(ARID, RName, AName, Default) & v(VID, Value),

	rel!cat!obj!attr(ID, RName, CFName, OFName, CTName, OTName, AName, Value, Default, ADefault) <<= arco(ID, RCOID, ARCID, VID) & rel!cat!obj(RCOID, RName, CFName, OFName, CTName, OTName) & rel!cat!attr(ARCID, RName, CFName, CTName, AName, Default, ADefault) & v(VID, Value),
	
]

# ╔═╡ c72ceffc-cd08-4a18-9b2d-cb58a098d4ed
clauses = vcat(to_clauses(kb), rules)

# ╔═╡ 65dee423-23cf-42a5-a859-c0514634b71a
resolve(@julog([cat(ID, Name)]), clauses)


# ╔═╡ 1e9ebd6f-33fe-46c9-875e-48a51142fc10
resolve(@julog([obj(ID, Name)]), clauses)

# ╔═╡ 5f02a577-3728-447f-9a59-bf1097a7c759
resolve(@julog([cat!obj(ID, CName, OName)]), clauses)

# ╔═╡ 5dd6412c-c784-4de1-ad3d-e5ffd1763935
resolve(@julog([rel(ID, Name)]), clauses)

# ╔═╡ c4ea1c3b-839a-4a1d-985f-a79b5d9c78e8
resolve(@julog([rel!cat(ID, RName, CFName, CTName)]), clauses)

# ╔═╡ db01e53f-c5af-44ad-8ae5-1eccdaee7c41
resolve(@julog([rel!cat!obj(ID, RName, CFName, OFName, CTName, COTName)]), clauses)

# ╔═╡ f856db42-aa7b-4c31-bae0-bb5a6093ac78
resolve(@julog([attr(ID, Name)]), clauses)

# ╔═╡ 5cb3865e-6c21-4074-8d4d-a7d111ed0c81
resolve(@julog([cat!attr(ID, CName, AName, Value)]), clauses)

# ╔═╡ 66929a90-67ce-4768-80ca-79d2e7514763
resolve(@julog([cat!obj!attr(ID, CName, OName, AName, Value, Default)]), clauses)

# ╔═╡ 08b5aef2-900e-4d0d-9def-45027870e8bb
resolve(@julog([rel!attr(ID, RName, AName, Value)]), clauses)

# ╔═╡ cbeaf456-7943-453a-a091-c5862514a3f6
resolve(@julog([rel!cat!attr(ID, RName, CFName, CTName, AName, Value, Default)]), clauses)

# ╔═╡ 83c52a61-01d2-4e7e-be89-73a217ae4755
resolve(@julog([rel!cat!obj!attr(ID, RName, CFName, OFName, CTName, OTName, AName, Value, Default, ADefault)]), clauses)

# ╔═╡ 9dd99bdd-d4d9-436a-99c1-f674cf67208f
select(V, kb)

# ╔═╡ bf9d9c24-770f-4602-ac02-177c396d36ab
select(C, kb)

# ╔═╡ 85f64fd6-3f1e-49da-b13d-4b7b957cbd91
select(R, kb)

# ╔═╡ Cell order:
# ╠═3575e562-c0a0-4b4e-8946-b3126b9420e0
# ╠═9f486d46-9d8a-11ed-1d5b-2db69b21e703
# ╠═0df734c3-152c-4144-be22-012ac0f6f3fa
# ╠═787bf1a5-6e1c-4712-936a-3476b6ecb5de
# ╠═9ac2ed42-47f1-4395-a955-a6f557f56775
# ╠═a4a83ed5-af8e-469e-8d4a-43861240853a
# ╠═2787a28b-aeee-406d-8de2-25bca23ede07
# ╠═b0b2c5d3-375c-4710-9acd-aa3a6fbd4504
# ╠═eea0cb04-b1f4-4c1a-a7be-7b50e5f5b931
# ╠═07874caa-1583-407f-b78b-f56aba8bda5e
# ╠═c72ceffc-cd08-4a18-9b2d-cb58a098d4ed
# ╠═65dee423-23cf-42a5-a859-c0514634b71a
# ╠═1e9ebd6f-33fe-46c9-875e-48a51142fc10
# ╠═5f02a577-3728-447f-9a59-bf1097a7c759
# ╠═5dd6412c-c784-4de1-ad3d-e5ffd1763935
# ╠═c4ea1c3b-839a-4a1d-985f-a79b5d9c78e8
# ╠═db01e53f-c5af-44ad-8ae5-1eccdaee7c41
# ╠═f856db42-aa7b-4c31-bae0-bb5a6093ac78
# ╠═5cb3865e-6c21-4074-8d4d-a7d111ed0c81
# ╠═66929a90-67ce-4768-80ca-79d2e7514763
# ╠═08b5aef2-900e-4d0d-9def-45027870e8bb
# ╠═cbeaf456-7943-453a-a091-c5862514a3f6
# ╠═83c52a61-01d2-4e7e-be89-73a217ae4755
# ╠═9dd99bdd-d4d9-436a-99c1-f674cf67208f
# ╠═bf9d9c24-770f-4602-ac02-177c396d36ab
# ╠═85f64fd6-3f1e-49da-b13d-4b7b957cbd91
