### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 993f2812-d6ae-11ed-2600-e1c8b7cb04de
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	Pkg.instantiate()
	Pkg.add("Revise")
	#Pkg.add("GZip")
	Pkg.add("DataFrames")
	Pkg.add("Dates")
	#Pkg.add("CSV")
	Pkg.add("Julog")
	Pkg.develop(path=joinpath(@__DIR__, "/home/youry/Projects/m-work/research/KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ fd07f6bb-7e14-47db-85b9-b4993e34ed05
using Revise, KBs, Dates, Julog, DataFrames

# ╔═╡ 166c9aab-45cb-4a03-a6f9-ebf44ba7723f
kb = KBs.load("log-02")

# ╔═╡ 2c088851-8335-468f-8afe-d6698e2ffa88
facts = to_clauses(kb)

# ╔═╡ d03c6442-d0f7-4de6-8550-1560d47c29aa
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

# ╔═╡ 1778042d-76f5-4e27-9abf-06126512d237
clauses = vcat(to_clauses(kb), rules)

# ╔═╡ 388969d8-3363-4253-af3b-e4ff717a4151
function request(query, vars)
	res, dicts = resolve(query, clauses)
	if res
		columns = []
		for var in vars
			v = Julog.Var(var)
			column = [d[v] for d in dicts]
			push!(columns, column)
		end
		true, DataFrame(columns, vars)
	else
		false, DataFrame()
	end
end

# ╔═╡ bab8b4a1-3afe-4f17-b903-479563f458e8
request(@julog([cat(_, Cat)]), [:Cat])

# ╔═╡ 2fd5587b-d1fa-489e-b781-626f8d523a9c
request(@julog([obj(_, Obj)]), [:Obj])

# ╔═╡ f46449e7-7c9f-4875-a4c2-2cd2ce21f6ed
request(@julog([cat!obj(_, Cat, Obj)]), [:Cat, :Obj])

# ╔═╡ dab1dc89-ff3f-4996-8796-d835bb5da85f
request(@julog([cat!obj(_, Cat, Obj), Cat == $(:Log)]), [:Cat, :Obj])

# ╔═╡ f94b51b3-ccb2-4d60-8bd9-f92f507e3299
request(@julog([cat!obj(_, Cat, Obj), Cat == $(:Record)]), [:Cat, :Obj])

# ╔═╡ 7bc62e81-4fda-4a3f-a784-a4525c34ff4d
request(@julog([cat!obj(_, Cat, Obj), Cat == $(:RecordInst)]), [:Cat, :Obj])

# ╔═╡ 0ef20ce6-c8bf-4081-b424-f7ffcc6028c2
request(@julog([rel(ID, Rel)]), [:Rel])

# ╔═╡ 5a59c21b-1826-494f-85b9-7de1b540abec
request(@julog([rel!attr(_, Rel, Attr, V)]), [:Rel, :Attr, :V])

# ╔═╡ cc43e6a1-fd5a-4a5a-9640-f4da607b2572
request(@julog([rel!cat(_, Rel, From, To)]), [:Rel, :From, :To])

# ╔═╡ 15b8b7f8-9294-401b-b4ab-2b510069f7f1
request(@julog([rel!cat!attr(_, Rel, From, To, Attr, V, _)]), [:Rel, :From, :To, :Attr, :V])

# ╔═╡ 81044380-a6d4-4855-b179-cbfa96ca6a43
request(
	@julog([
		arco(_, RCOID, ARCID, VID),
		v(VID, V),
		V == 100,
		
		rco(RCOID, RCID, COFID, COTID), 
		rc(RCID, RID, CFID, CTID), 
		r(RID, RVID), v(RVID, Rel),
		Rel == $(:HAS),
		
		c(CFID, CFVID), v(CFVID, CFrom),
		CFrom == $(:Log), 
		c(CTID, CTVID), v(CTVID, CTo),
		CTo == $(:RecordInst),

		arc(ARCID, RCID, ARID, _),
		ar(ARID, RID, AID, _), 
		a(AID, AVID), v(AVID, Attr),
		Attr == $(:number),
		
		co(COFID, CFID, OFID),
		o(OFID, OFVID), v(OFVID, OFrom),
		co(COTID, CTID, OTID),
				
		rco(_, RCID2, COTID, COTID2),
		rc(RCID2, RID2, CTID, CTID2),
		r(RID2, RVID2), v(RVID2, $(:IS)),
		c(CTID2, CTVID2), v(CTVID2, $(:Record)),
		co(COTID2, CTID2, OTID2),
		o(OTID2, OTVID2), v(OTVID2, OTo),
		
	]), 
	#[:Rel, :CFrom, :CTo, :OFrom, :OTo, :Attr, :V]
	[:V, :OTo]
)

# ╔═╡ Cell order:
# ╠═993f2812-d6ae-11ed-2600-e1c8b7cb04de
# ╠═fd07f6bb-7e14-47db-85b9-b4993e34ed05
# ╠═166c9aab-45cb-4a03-a6f9-ebf44ba7723f
# ╠═2c088851-8335-468f-8afe-d6698e2ffa88
# ╠═d03c6442-d0f7-4de6-8550-1560d47c29aa
# ╠═1778042d-76f5-4e27-9abf-06126512d237
# ╠═bab8b4a1-3afe-4f17-b903-479563f458e8
# ╠═2fd5587b-d1fa-489e-b781-626f8d523a9c
# ╠═f46449e7-7c9f-4875-a4c2-2cd2ce21f6ed
# ╠═dab1dc89-ff3f-4996-8796-d835bb5da85f
# ╠═f94b51b3-ccb2-4d60-8bd9-f92f507e3299
# ╠═7bc62e81-4fda-4a3f-a784-a4525c34ff4d
# ╠═0ef20ce6-c8bf-4081-b424-f7ffcc6028c2
# ╠═5a59c21b-1826-494f-85b9-7de1b540abec
# ╠═cc43e6a1-fd5a-4a5a-9640-f4da607b2572
# ╠═15b8b7f8-9294-401b-b4ab-2b510069f7f1
# ╠═81044380-a6d4-4855-b179-cbfa96ca6a43
# ╠═388969d8-3363-4253-af3b-e4ff717a4151
