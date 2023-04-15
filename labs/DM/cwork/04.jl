### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 6f341f22-d9d4-11ed-1df6-91d6765c4d5c
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	Pkg.instantiate()
	Pkg.add("Revise")
	Pkg.add("PlutoUI")
	Pkg.add("DataFrames")
	Pkg.add("Dates")
	Pkg.add("Parsers")
	Pkg.add("Julog")
	Pkg.develop(path=joinpath(@__DIR__, "/home/youry/Projects/m-work/research/KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ 23531297-30da-46e2-baa7-5fad223a27de
using Revise, KBs, Dates, Julog, DataFrames, PlutoUI

# ╔═╡ 96208bce-fc25-411d-bb54-2b93b83b28d3
rules = @julog [
	cat(ID, Name) <<= c(ID, VID) & v(VID, Name),
	obj(ID, Name) <<= o(ID, VID) & v(VID, Name),
	cat!obj(ID, CName, OName) <<= co(ID, CID, OID) & cat(CID, CName) & obj(OID, OName),
	rel(ID, Name) <<= r(ID, VID) & v(VID, Name),
	rel!cat(ID, RName, CFName, CTName) <<= rc(ID, RID, CFID, CTID) & rel(RID, RName) & cat(CFID, CFName) & cat(CTID, CTName),
]

# ╔═╡ 713a667f-5d13-4ab9-91f6-bc7488de75e0
funcs = Dict(
	:occursin => (sub, str) -> occursin(sub, str),
	:good_return => (ret) -> parse(Int, ret) < 400,
)

# ╔═╡ 53333214-90fa-40ab-83fb-640186fdf5bf
clauses = vcat(to_clauses(KBs.load("log-03")), rules)

# ╔═╡ 1245d50d-bb52-4960-a855-2590740efd0d
1493 + 4402

# ╔═╡ 9ad36ece-6b54-4868-8de3-40ded4292ca3
function request(query, vars)
	res, dicts = resolve(query, clauses, funcs=funcs)
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

# ╔═╡ 0c57e66b-15e7-48df-b77d-332105160f25
request(@julog([cat(_, Cat)]), [:Cat])

# ╔═╡ fe1accc1-da2b-4f75-b035-36c4a00bbd0b
request(@julog([rel!cat(_, Rel, From, To)]), [:Rel, :From, :To])

# ╔═╡ 8bb6f9d3-c0e3-45bb-8fa1-629bd9c0a537
request(@julog([
	cat!obj(_, Cat, Obj),
	Cat == $(:Return),
	]),
	
	[:Cat, :Obj]
)

# ╔═╡ d1d86097-8e1d-4903-b4c8-8e158c9dfdf1
request(@julog([
	cat!obj(_, Cat, Obj),
	Cat == $(:Return),
	good_return(Obj),
	]),
	
	[:Cat, :Obj]
)

# ╔═╡ 0d5f10bd-941b-4c93-8f5b-b8de89157def
request(@julog([
	cat!obj(_, Cat, Obj),
	Cat == $(:Record),
	]),
	
	[:Cat, :Obj]
)

# ╔═╡ 4f9f1b27-a6b9-4c36-a5de-864b3d5e35e8
request(@julog([

	r(RID, RVID), v(RVID, $(:HAS)),
	
	c(CID_RET, CVID_RET), v(CVID_RET, $(:Return)),
	co(COTID, CID_RET, OID_RET), 
	o(OID_RET, OVID_RET), v(OVID_RET, Ret),
	good_return(Ret),
	
	c(CID_REC, CVID_REC), v(CVID_REC, $(:Record)),
	rc(RCID, RID, CID_REC, CID_RET),
	rco(_, RCID, COFID, COTID), 
	
	co(COFID, CID_REC, OID_REC), 
	o(OID_REC, OVID_REC), v(OVID_REC, Rec),
	
	]),
	
	[:Ret, :Rec]
)

# ╔═╡ 68293e9d-8dba-4d30-a7cc-8dc3d8eaba42
request(@julog([

	r(RID, RVID), v(RVID, $(:HAS)),
	
	c(CID_RET, CVID_RET), v(CVID_RET, $(:Return)),
	co(COTID, CID_RET, OID_RET), 
	o(OID_RET, OVID_RET), v(OVID_RET, Ret),
	not(good_return(Ret)),
	
	c(CID_REC, CVID_REC), v(CVID_REC, $(:Record)),
	rc(RCID, RID, CID_REC, CID_RET),
	rco(_, RCID, COFID, COTID), 
	
	co(COFID, CID_REC, OID_REC), 
	o(OID_REC, OVID_REC), v(OVID_REC, Rec),
	
	]),
	
	[:Ret, :Rec]
)

# ╔═╡ 240ee8cf-2ba9-4b1b-a40d-afe2eea89000
request(@julog([
	cat!obj(_, Cat, Obj),
	Cat == $(:Return),
	not(good_return(Obj)),
	]),
	
	[:Cat, :Obj]
)

# ╔═╡ 7a0d7ccb-b42c-49ed-83fe-992363308891
let
structure_kb = """
@startuml

Class Log
Class Record
Class Time
Class Return
Class Word
Class Request
Class WordInst
Class Host
Class RecordInst
Class Agent
Class Path
Class Method


Log -- RecordInst : HAS >
RecordInst -- Record : IS >
Record -- Time : HAS >
Record -- Host : HAS >
Record -- Request : HAS >
Record -- Return : HAS >
Record -- Agent : HAS >
Agent -- WordInst : HAS >
WordInst -- Word : IS >
Request -- Method : HAS >
Request -- Path : HAS >

@enduml
"""
file = "pic01"
open("$file.txt", "w") do io
	write(io, structure_kb)
end
run(`plantuml "$file.txt"`)
LocalResource("$file.png")
end

# ╔═╡ Cell order:
# ╠═6f341f22-d9d4-11ed-1df6-91d6765c4d5c
# ╠═23531297-30da-46e2-baa7-5fad223a27de
# ╠═96208bce-fc25-411d-bb54-2b93b83b28d3
# ╠═713a667f-5d13-4ab9-91f6-bc7488de75e0
# ╠═53333214-90fa-40ab-83fb-640186fdf5bf
# ╠═0c57e66b-15e7-48df-b77d-332105160f25
# ╠═fe1accc1-da2b-4f75-b035-36c4a00bbd0b
# ╠═8bb6f9d3-c0e3-45bb-8fa1-629bd9c0a537
# ╠═d1d86097-8e1d-4903-b4c8-8e158c9dfdf1
# ╠═0d5f10bd-941b-4c93-8f5b-b8de89157def
# ╠═1245d50d-bb52-4960-a855-2590740efd0d
# ╠═4f9f1b27-a6b9-4c36-a5de-864b3d5e35e8
# ╠═68293e9d-8dba-4d30-a7cc-8dc3d8eaba42
# ╠═240ee8cf-2ba9-4b1b-a40d-afe2eea89000
# ╠═9ad36ece-6b54-4868-8de3-40ded4292ca3
# ╠═7a0d7ccb-b42c-49ed-83fe-992363308891
