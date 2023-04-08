### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 520b00fa-d5f1-11ed-0634-f3c2979c5960
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	Pkg.instantiate()
	Pkg.add("Revise")
	Pkg.add("GZip")
	#Pkg.add("DataFrames")
	Pkg.add("Dates")
	#Pkg.add("CSV")
	Pkg.develop(path=joinpath(@__DIR__, "/home/youry/Projects/m-work/research/KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ e413091e-d54a-4315-bdf9-f1b362c5ae78
using Revise, KBs, GZip, Dates

# ╔═╡ f9c94aea-1a42-4019-8280-2128b7b80ed3
let
	init_script = quote
    	"OK"
	end
	
	kb = KBs.init(init_script)
	KBs.save(kb, "log-01")
end

# ╔═╡ 215f1158-7e89-4ecc-9ff3-ac5d7e1899dc
kb = KBs.load("log-01")

# ╔═╡ 488bca4f-60b9-4ecc-8bed-c9dbe6cd4b89
KBs.init_run(kb)

# ╔═╡ 1b02233b-afea-409c-b1c2-7cd64418fb96
begin
	c_log = @c! kb :Log (
		rct=[
			(r=:HAS, ct=:Record),
		],
		arct=[
			(r=:HAS, ct=:Record, a=:number, v=0),
		],
	)

	c_record = @c! kb :Record (
		rct=[
			(r=:HAS, ct=:Time),
			(r=:HAS, ct=:Host), 
			(r=:HAS, ct=:Request),
			(r=:HAS, ct=:Return),
			(r=:HAS, ct=:Agent),
		],
	)

	c_record_inst = @c! kb :RecordInst (
		rct=[
			(r=:IS, ct=:Record),
		],
	)

	@c! kb :Request (
		rct=[
			(r=:HAS, ct=:Method),
			(r=:HAS, ct=:Path),
		],
	)

	@c! kb :Agent (
		rct=[
			(r=:HAS, ct=:WordInst),
		],
		arct=[(r=:HAS, ct=:WordInst, a=:number, v=0)],
	)

	@c! kb :WordInst (
		rct=[
			(r=:IS, ct=:Word),
		],
	)

	let 
		count = 0
		header=["ip","f1","f2","ts","met","ret","nb","f4","br"]
		logs_dir = joinpath("logs", "nginx")
		#files = []
		#records = String[]
		#log = []
		
		r_has = KBs.make!(R, kb, :HAS)
		rc_log_has_record = KBs.make!(RC, kb, r_has, c_log, c_record)
		r_is = KBs.make!(R, kb, :IS)
		rc_inst_is_record = KBs.make!(RC, kb, r_is, c_record_inst, c_record)
		a_number = KBs.make!(A, kb, :number)
		ar_has_number = KBs.make!(AR, kb, r_has, a_number, 0)
		arc_log_has_record_number = KBs.make!(ARC, kb, 
			rc_log_has_record, ar_has_number, 0)
		
		for file in filter(x -> occursin("access", x) && occursin("gz", x), 	readdir(logs_dir, join=true))
			#push!(files, file)

			o_file = KBs.make!(O, kb, file)
			co_log_file = KBs.make!(CO, kb, c_log, o_file)
			
			#fh = GZip.open(file)
			#append!(records, readlines(fh))

			GZip.open(file) do io
				i = 1
           		while !eof(io)
               		record = readline(io)
					
					o_record = KBs.make!(O, kb, record)
					co_record = KBs.make!(CO, kb, c_record, o_record)
					o_record_inst = KBs.make!(O, kb, count)
					co_record_inst = KBs.make!(CO, kb, c_record_inst, o_record_inst)
					rco_inst_is_record = KBs.make!(RCO, kb, 
						rc_inst_is_record, co_record_inst, co_record)
					rco_log_has_record = KBs.make!(RCO, kb, 
						rc_log_has_record, co_log_file, co_record)
					arco_log_has_record_number =  KBs.make!(ARCO, kb,
						rco_log_has_record, arc_log_has_record_number, i)
						

					#@o! kb record (
					#	co=[(c=:Record,)],
					#	rcof=[(c=:Record, r=:HAS, cf=:Log, of=file)],
					#	arcof=[(c=:Record, r=:HAS, cf=:Log, of=file, a=:number, v=i)],
					#)
		

					i+=1
					count+=1
           		end
       		end
		end
	
		for file in filter(x -> occursin("access", x) && !occursin("gz", x), readdir(logs_dir, join=true))
			#push!(files, file)

			o_file = KBs.make!(O, kb, file)
			co_log_file = KBs.make!(CO, kb, c_log, o_file)
			
			#fh = open(file)
			#append!(records, readlines(fh))
			open(file) do io
				i = 1
           		while !eof(io)
               		record = readline(io)

					o_record = KBs.make!(O, kb, record)
					co_record = KBs.make!(CO, kb, c_record, o_record)
					o_record_inst = KBs.make!(O, kb, count)
					co_record_inst = KBs.make!(CO, kb, c_record_inst, o_record_inst)
					rco_inst_is_record = KBs.make!(RCO, kb, 
						rc_inst_is_record, co_record_inst, co_record)
					rco_log_has_record = KBs.make!(RCO, kb, 
						rc_log_has_record, co_log_file, co_record)
					arco_log_has_record_number =  KBs.make!(ARCO, kb,
						rco_log_has_record, arc_log_has_record_number, i)

					#@o! kb record (
					#	co=[(c=:Record,)],
					#	rcof=[(c=:Record, r=:HAS, cf=:Log, of=file)],
					#	arcof=[(c=:Record, r=:HAS, cf=:Log, of=file, a=:number, v=i)],
					#)

					i+=1
					count+=1
           		end
       		end
			
		end
		count

		KBs.save(kb, "log-02")
		#records
		
		#types=[String,String,String,DateTime,String,Int,Int,String,String]
	
		#df = CSV.File(IOBuffer.(records); header=header, delim=' ',types=types, silencewarnings=true, dateformat="[d/u/yyyy:H:M:S +0000]") |> DataFrame

		#DataFrames.select(df, header)
	
	end
	
end

# ╔═╡ 84fc0e25-3191-4d1d-ab14-2666ba5a0ba1
select(O, kb; cs = [:v])

# ╔═╡ ad52bdbe-bf91-4ff1-9e25-22991b196f4c
select(CO, kb; cs = [:cv, :ov])

# ╔═╡ efb487cb-7b87-4d68-830d-50702db664b4
select(ARCO, kb)

# ╔═╡ 7ec9929e-cbf9-442c-aaac-98f80890b780
select(C, kb; cs = [:v])

# ╔═╡ 46c1930b-3fd1-410d-abb4-d9f52bb6e020
select(R, kb; cs = [:v])

# ╔═╡ eca79a61-0871-488a-a5df-fb5a9e8a6f6b
select(A, kb; cs = [:v])

# ╔═╡ 0c5228c9-e066-410f-92cf-ea74cdae605c
select(RC, kb; cs = [:rv, :cfv, :ctv])

# ╔═╡ eb02d3b7-a70d-464d-bcdb-ae95e27a1579
select(AC, kb; cs = [:cv, :av])

# ╔═╡ 2fd456bf-9dfa-4d9a-9ff8-21bc42cd0caf
select(ARC, kb; cs = [:rv, :cfv, :ctv, :av])

# ╔═╡ Cell order:
# ╠═520b00fa-d5f1-11ed-0634-f3c2979c5960
# ╠═e413091e-d54a-4315-bdf9-f1b362c5ae78
# ╠═f9c94aea-1a42-4019-8280-2128b7b80ed3
# ╠═215f1158-7e89-4ecc-9ff3-ac5d7e1899dc
# ╠═488bca4f-60b9-4ecc-8bed-c9dbe6cd4b89
# ╠═1b02233b-afea-409c-b1c2-7cd64418fb96
# ╠═84fc0e25-3191-4d1d-ab14-2666ba5a0ba1
# ╠═ad52bdbe-bf91-4ff1-9e25-22991b196f4c
# ╠═efb487cb-7b87-4d68-830d-50702db664b4
# ╠═7ec9929e-cbf9-442c-aaac-98f80890b780
# ╠═46c1930b-3fd1-410d-abb4-d9f52bb6e020
# ╠═eca79a61-0871-488a-a5df-fb5a9e8a6f6b
# ╠═0c5228c9-e066-410f-92cf-ea74cdae605c
# ╠═eb02d3b7-a70d-464d-bcdb-ae95e27a1579
# ╠═2fd456bf-9dfa-4d9a-9ff8-21bc42cd0caf
