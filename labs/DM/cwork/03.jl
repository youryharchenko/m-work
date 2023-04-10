### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ ff878574-d799-11ed-39c3-73c786a13f07
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	Pkg.instantiate()
	Pkg.add("Revise")
	#Pkg.add("GZip")
	Pkg.add("DataFrames")
	Pkg.add("Dates")
	Pkg.add("Parsers")
	Pkg.add("Julog")
	Pkg.develop(path=joinpath(@__DIR__, "/home/youry/Projects/m-work/research/KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ 2d70746b-76f7-4f05-bb46-dc534b1f7971
using Revise, KBs, Dates, Julog, DataFrames, Parsers

# ╔═╡ 7f15e0b7-6775-44a8-a9d0-df234ad1178f
kb = KBs.load("log-02")

# ╔═╡ 8d509731-685f-4480-a624-3fe3d8af62e8
rules = @julog [
	cat(ID, Name) <<= c(ID, VID) & v(VID, Name),
	obj(ID, Name) <<= o(ID, VID) & v(VID, Name),
	cat!obj(ID, CName, OName) <<= co(ID, CID, OID) & cat(CID, CName) & obj(OID, OName),
	rel(ID, Name) <<= r(ID, VID) & v(VID, Name),
	rel!cat(ID, RName, CFName, CTName) <<= rc(ID, RID, CFID, CTID) & rel(RID, RName) & cat(CFID, CFName) & cat(CTID, CTName),
]

# ╔═╡ bb4fa4fb-cd5e-4404-a3fc-5179c42db2bd
clauses = vcat(to_clauses(kb), rules)

# ╔═╡ 089f5fbe-43d1-4aa3-9e62-c07656a5c78e
get_records = @julog([
	c(CID_Record, CVID_Record),
	v(CVID_Record, $(:Record)),
	co(COID_Record, CID_Record, OID_Record),
	o(OID_Record, OVID_Record),
	v(OVID_Record, Record),
],)

# ╔═╡ ad45aa0f-19ab-420a-84c0-67d3f4583799
function xsplit(s, delim=" ", quot=[("\"","\""), ("[", "]")])
	qo = [x[1] for x in quot]
	qc = [x[2] for x in quot]
	qi = nothing
	res = []
	e = " "
	for c in split(s, "")
		if isnothing(qi) 
			qi = findfirst(qo .== c)
			if !isnothing(qi) 
				continue
			end
		end
		if !isnothing(qi)
			if qi == findfirst(qc .== c)
				qi = nothing
				continue
			end
		end
		
		if c == delim && isnothing(qi) 
			if length(e) > 0
				push!(res, strip(e))
			end
			e = " "
			continue
		else
			e = e * c
		end
	end
	if length(e) > 0
		push!(res, strip(e))
	end
	res
end

# ╔═╡ 53994a11-9285-49aa-8f9c-c3294da76ea8
findfirst(["a", "b"] .== "b")

# ╔═╡ 7eeebb15-57f3-4895-9182-a71422158fb8
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

# ╔═╡ 89f51b49-d07c-4037-95c5-2380f7f15955
res, df = request(get_records, [:Record])

# ╔═╡ e89996ea-851f-49f4-83d7-fd0081e85ffe
df[3128, :Record]

# ╔═╡ 75547835-d9c3-444c-af17-b2de8ca184f4
rec = let
	r_has = KBs.make!(R, kb, :HAS)
	
	c_record = KBs.make!(C, kb, :Record)

	c_time = KBs.make!(C, kb, :Time)
	c_host = KBs.make!(C, kb, :Host)
	c_request = KBs.make!(C, kb, :Request)
	c_return = KBs.make!(C, kb, :Return)
	c_agent = KBs.make!(C, kb, :Agent)
	
	rc_has_record_time = KBs.make!(RC, kb, r_has, c_record, c_time)
	rc_has_record_host = KBs.make!(RC, kb, r_has, c_record, c_host)
	rc_has_record_request = KBs.make!(RC, kb, r_has, c_record, c_request)
	rc_has_record_return = KBs.make!(RC, kb, r_has, c_record, c_return)
	rc_has_record_agent = KBs.make!(RC, kb, r_has, c_record, c_agent)

	rec = ""
	arec = []
	count = 0
	
	for r in eachrow(df)
		count += 1
		
		rec = r[1].name
		o_record = KBs.make!(O, kb, rec)
		co_record = KBs.make!(CO, kb, c_record, o_record)

		arec = xsplit(rec)

		if length(arec) != 9 
			println(rec)
			continue
		end
		
		host = arec[1]
		o_host = KBs.make!(O, kb, string(host))
		co_host = KBs.make!(CO, kb, c_host, o_host)
		KBs.make!(RCO, kb, rc_has_record_host, co_record, co_host)

		time = arec[4]
		o_time = KBs.make!(O, kb, string(time))
		co_time = KBs.make!(CO, kb, c_time, o_time)
		KBs.make!(RCO, kb, rc_has_record_time, co_record, co_time)

		request = arec[5]
		o_request = KBs.make!(O, kb, string(request))
		co_request = KBs.make!(CO, kb, c_request, o_request)
		KBs.make!(RCO, kb, rc_has_record_request, co_record, co_request)

		return_ = arec[6]
		o_return = KBs.make!(O, kb, string(return_))
		co_return = KBs.make!(CO, kb, c_return, o_return)
		KBs.make!(RCO, kb, rc_has_record_return, co_record, co_return)

		agent = arec[9]
		o_agent = KBs.make!(O, kb, string(agent))
		co_agent = KBs.make!(CO, kb, c_agent, o_agent)
		KBs.make!(RCO, kb, rc_has_record_agent, co_record, co_agent)
		
		
	end
	count, arec 
end

# ╔═╡ 68692df6-1191-4f13-afbd-6a04e5b9e8b0
request(@julog([cat(_, Cat)]), [:Cat])

# ╔═╡ 4544db55-766c-49d9-bdf4-11e8931e913e
request(@julog([rel!cat(_, Rel, From, To)]), [:Rel, :From, :To])

# ╔═╡ 371b2279-2eb1-49e1-abe8-e4d0bd510471
request(@julog([cat!obj(_, Cat, Obj), Cat == $(:Host)]), [:Cat, :Obj])

# ╔═╡ 2eff36d7-d25b-470c-ae65-b0c76172b56d
request(@julog([cat!obj(_, Cat, Obj), Cat == $(:Request)]), [:Cat, :Obj])

# ╔═╡ 76efdda5-8185-4fd0-a658-920f5b5d63ec
request(@julog([cat!obj(_, Cat, Obj), Cat == $(:Return)]), [:Cat, :Obj])

# ╔═╡ f6724235-9bd0-4e1e-b45d-26133bc4a36e
request(@julog([cat!obj(_, Cat, Obj), Cat == $(:Time)]), [:Cat, :Obj])

# ╔═╡ f53f0575-4f2f-4f1f-bc29-eca4451eb803
request(@julog([cat!obj(_, Cat, Obj), Cat == $(:Agent)]), [:Cat, :Obj])

# ╔═╡ b9d11e9b-35f9-474b-b86f-e01b1271e16b
request(@julog([cat!obj(_, Cat, Obj), Cat == $(:Record)]), [:Cat, :Obj])

# ╔═╡ Cell order:
# ╠═ff878574-d799-11ed-39c3-73c786a13f07
# ╠═2d70746b-76f7-4f05-bb46-dc534b1f7971
# ╠═7f15e0b7-6775-44a8-a9d0-df234ad1178f
# ╠═8d509731-685f-4480-a624-3fe3d8af62e8
# ╠═bb4fa4fb-cd5e-4404-a3fc-5179c42db2bd
# ╠═089f5fbe-43d1-4aa3-9e62-c07656a5c78e
# ╠═89f51b49-d07c-4037-95c5-2380f7f15955
# ╠═e89996ea-851f-49f4-83d7-fd0081e85ffe
# ╠═75547835-d9c3-444c-af17-b2de8ca184f4
# ╠═ad45aa0f-19ab-420a-84c0-67d3f4583799
# ╠═53994a11-9285-49aa-8f9c-c3294da76ea8
# ╠═68692df6-1191-4f13-afbd-6a04e5b9e8b0
# ╠═4544db55-766c-49d9-bdf4-11e8931e913e
# ╠═371b2279-2eb1-49e1-abe8-e4d0bd510471
# ╠═2eff36d7-d25b-470c-ae65-b0c76172b56d
# ╠═76efdda5-8185-4fd0-a658-920f5b5d63ec
# ╠═f6724235-9bd0-4e1e-b45d-26133bc4a36e
# ╠═f53f0575-4f2f-4f1f-bc29-eca4451eb803
# ╠═b9d11e9b-35f9-474b-b86f-e01b1271e16b
# ╠═7eeebb15-57f3-4895-9182-a71422158fb8
