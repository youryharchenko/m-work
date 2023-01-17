### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 220ff242-94a7-11ed-2d9a-7170d2c39d11
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	Pkg.instantiate()
	Pkg.add("Revise")
	Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ b5d4587a-d496-475f-b041-8abc83624648
using Revise, KBs

# ╔═╡ 8fa18ea1-f039-461f-945d-6dd547285c1a
let
	init_script = quote
    	a = 11
    	b = 22

    	"OK"
	end
	
	kb = KBs.init(init_script)
	KBs.save(kb, "mwork06/save-06")
end

# ╔═╡ a972219c-e39c-420a-8881-a14823477229
kb = KBs.load("mwork06/save-06")

# ╔═╡ d963b987-23c8-4930-89d2-f8fd02bc6bef
KBs.init_run(kb)

# ╔═╡ 16573a7e-b6cf-4889-9d82-2828652a6991
KBs.make!(KBs.ACO, kb, 
        KBs.make!(KBs.CO, kb, KBs.make!(KBs.C, kb, :System), KBs.make!(KBs.O, kb, :Test)), 
        KBs.make!(KBs.AC, kb, KBs.make!(KBs.C, kb, :System), KBs.make!(KBs.A, kb, :script), nothing),
        :(a+b))

# ╔═╡ 513575b9-6c7d-4a73-97c9-d6696106d771
KBs.select(KBs.V, kb)

# ╔═╡ e95b7bec-98d4-47c0-9a96-f3706b7776db
KBs.select(KBs.C, kb)

# ╔═╡ d39f7fb9-0222-4edf-a967-9b02e79de051
KBs.select(KBs.CO, kb)

# ╔═╡ e98106f7-5efa-4f83-bbd0-27dee9b247e0
KBs.select(KBs.ACO, kb)

# ╔═╡ 1015889c-30ed-4d23-b67a-69e02a670780
KBs.select(KBs.ACO, kb)[1, :vid]

# ╔═╡ 9dfe3f52-a6f2-401a-a56f-57746037306c
KBs.evalue(kb, KBs.KBs.select(KBs.ACO, kb)[1, :vid])

# ╔═╡ 46839ab9-9998-46e0-93d8-b0bbad17f430
KBs.make!(KBs.RCO, kb, 
	KBs.make!(KBs.RC, kb, 
		KBs.make!(KBs.R, kb, :part_of), 
		KBs.make!(KBs.C, kb, :Module),
		KBs.make!(KBs.C, kb, :System),
	),
    KBs.make!(KBs.CO, kb, 
		KBs.make!(KBs.C, kb, :Module), 
		KBs.make!(KBs.O, kb, :Input)),
	KBs.make!(KBs.CO, kb, 
		KBs.make!(KBs.C, kb, :System), 
		KBs.make!(KBs.O, kb, :Agent)),
	
)

# ╔═╡ 0ca25fb2-8e24-4f62-88c5-5eb93893d82c
KBs.select(KBs.RCO, kb)

# ╔═╡ 8867ddc7-f98d-4f9a-bc55-a2145d24c0cb
KBs.make!(KBs.ARC, kb,
		KBs.make!(KBs.RC, kb, 
			KBs.make!(KBs.R, kb, :part_of), 
			KBs.make!(KBs.C, kb, :Module),
			KBs.make!(KBs.C, kb, :System),
		),
		KBs.make!(KBs.AR, kb, 
			KBs.make!(KBs.R, kb, :part_of), 
			KBs.make!(KBs.A, kb, :number), 
			0),
        0)

# ╔═╡ 3f3e79da-9d8c-47de-9021-0c84f078c9a0
KBs.select(KBs.ARC, kb)

# ╔═╡ 75b2be38-8e3f-46c5-88de-7e52176c3a86
KBs.make!(KBs.ARCO, kb,
		KBs.make!(KBs.RCO, kb, 
			KBs.make!(KBs.RC, kb, 
				KBs.make!(KBs.R, kb, :part_of), 
				KBs.make!(KBs.C, kb, :Module),
				KBs.make!(KBs.C, kb, :System),
			),
    		KBs.make!(KBs.CO, kb, 
				KBs.make!(KBs.C, kb, :Module), 
				KBs.make!(KBs.O, kb, :Input)
			),
			KBs.make!(KBs.CO, kb, 
				KBs.make!(KBs.C, kb, :System), 
				KBs.make!(KBs.O, kb, :Agent)
			),
		),
		KBs.make!(KBs.ARC, kb, 
			KBs.make!(KBs.RC, kb, 
				KBs.make!(KBs.R, kb, :part_of), 
				KBs.make!(KBs.C, kb, :Module),
				KBs.make!(KBs.C, kb, :System),
			),
			KBs.make!(KBs.AR, kb, 
				KBs.make!(KBs.R, kb, :part_of), 
				KBs.make!(KBs.A, kb, :number), 
				0),
        0),
		1)

# ╔═╡ 6f124751-485f-4b96-bff2-89225b82ed8e
KBs.select(KBs.ARCO, kb)

# ╔═╡ 11e8cc52-f8f1-48ec-b072-db88970fbd4a
methods(KBs.id)

# ╔═╡ 6e7b12e6-7248-4601-8d85-48cd3ef77704
KBs.id(kb, 0)

# ╔═╡ a63013af-9454-4caa-9260-8e3cf27b6832
v_system = KBs.id(kb, KBs.V(:System))

# ╔═╡ d3610d3b-0026-44ae-8cca-3a2165840d55
c_system = KBs.id(kb, KBs.C(v_system))

# ╔═╡ 69ac47e5-a8f9-481f-80c5-cfeaafe00c41
v_agent = KBs.id(kb, KBs.V(:Agent))

# ╔═╡ 8803a9c4-badd-4df6-a510-241a9ed3c5a9
o_agent = KBs.id(kb, KBs.O(v_agent))

# ╔═╡ 3992f180-7d45-437e-9e5a-e004e00761d6
v_nothing = KBs.idg!(kb, nothing)

# ╔═╡ b14a0b79-c4d1-4007-8281-82a11b5c5b54
KBs.idg!(kb, KBs.V(nothing))

# ╔═╡ 75e570c8-d5fb-4eb8-ba4f-fc076fbc4a67
KBs.idg!(kb, KBs.C(v_system))

# ╔═╡ 4bf9246a-88ed-4e20-bbcf-e58a88a79599
KBs.idg!(kb, KBs.O(v_agent))

# ╔═╡ 764a19cf-f830-4f30-8743-62348e8887da
KBs.idg!(kb, KBs.CO(c_system, o_agent))

# ╔═╡ de421a73-0daf-4da9-b499-f308c2ccaff3
v_script = KBs.idg!(kb, KBs.V(:script))

# ╔═╡ 17cf3152-64ea-4e3a-9d5c-9c0fe1882085
a_script = KBs.idg!(kb, KBs.A(v_script))

# ╔═╡ f1350238-b73e-4385-b85b-63cd67a87e61
KBs.idg!(kb, KBs.AC(c_system, a_script, v_nothing))

# ╔═╡ 5f14115a-b20c-477b-95c7-1e735a023bc9
KBs.select(KBs.CO, kb)

# ╔═╡ 21f0b2cc-4910-431b-8f0d-835cb386e558
KBs.select(KBs.AC, kb)

# ╔═╡ 9e7c443e-1322-4d6f-94b4-b3e2a41b8d87
KBs.select(KBs.A, kb)

# ╔═╡ Cell order:
# ╠═220ff242-94a7-11ed-2d9a-7170d2c39d11
# ╠═b5d4587a-d496-475f-b041-8abc83624648
# ╠═8fa18ea1-f039-461f-945d-6dd547285c1a
# ╠═a972219c-e39c-420a-8881-a14823477229
# ╠═d963b987-23c8-4930-89d2-f8fd02bc6bef
# ╠═16573a7e-b6cf-4889-9d82-2828652a6991
# ╠═513575b9-6c7d-4a73-97c9-d6696106d771
# ╠═e95b7bec-98d4-47c0-9a96-f3706b7776db
# ╠═d39f7fb9-0222-4edf-a967-9b02e79de051
# ╠═e98106f7-5efa-4f83-bbd0-27dee9b247e0
# ╠═1015889c-30ed-4d23-b67a-69e02a670780
# ╠═9dfe3f52-a6f2-401a-a56f-57746037306c
# ╠═46839ab9-9998-46e0-93d8-b0bbad17f430
# ╠═0ca25fb2-8e24-4f62-88c5-5eb93893d82c
# ╠═8867ddc7-f98d-4f9a-bc55-a2145d24c0cb
# ╠═3f3e79da-9d8c-47de-9021-0c84f078c9a0
# ╠═75b2be38-8e3f-46c5-88de-7e52176c3a86
# ╠═6f124751-485f-4b96-bff2-89225b82ed8e
# ╠═11e8cc52-f8f1-48ec-b072-db88970fbd4a
# ╠═6e7b12e6-7248-4601-8d85-48cd3ef77704
# ╠═a63013af-9454-4caa-9260-8e3cf27b6832
# ╠═d3610d3b-0026-44ae-8cca-3a2165840d55
# ╠═69ac47e5-a8f9-481f-80c5-cfeaafe00c41
# ╠═8803a9c4-badd-4df6-a510-241a9ed3c5a9
# ╠═3992f180-7d45-437e-9e5a-e004e00761d6
# ╠═b14a0b79-c4d1-4007-8281-82a11b5c5b54
# ╠═75e570c8-d5fb-4eb8-ba4f-fc076fbc4a67
# ╠═4bf9246a-88ed-4e20-bbcf-e58a88a79599
# ╠═764a19cf-f830-4f30-8743-62348e8887da
# ╠═de421a73-0daf-4da9-b499-f308c2ccaff3
# ╠═17cf3152-64ea-4e3a-9d5c-9c0fe1882085
# ╠═f1350238-b73e-4385-b85b-63cd67a87e61
# ╠═5f14115a-b20c-477b-95c7-1e735a023bc9
# ╠═21f0b2cc-4910-431b-8f0d-835cb386e558
# ╠═9e7c443e-1322-4d6f-94b4-b3e2a41b8d87
