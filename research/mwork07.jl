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

# ╔═╡ d39f7fb9-0222-4edf-a967-9b02e79de051
KBs.select(KBs.CO, kb)

# ╔═╡ e98106f7-5efa-4f83-bbd0-27dee9b247e0
KBs.select(KBs.ACO, kb)

# ╔═╡ 1015889c-30ed-4d23-b67a-69e02a670780
KBs.select(KBs.ACO, kb)[1, :vid]

# ╔═╡ 9dfe3f52-a6f2-401a-a56f-57746037306c
KBs.evalue(kb, KBs.KBs.select(KBs.ACO, kb)[1, :vid])

# ╔═╡ Cell order:
# ╠═220ff242-94a7-11ed-2d9a-7170d2c39d11
# ╠═b5d4587a-d496-475f-b041-8abc83624648
# ╠═8fa18ea1-f039-461f-945d-6dd547285c1a
# ╠═a972219c-e39c-420a-8881-a14823477229
# ╠═d963b987-23c8-4930-89d2-f8fd02bc6bef
# ╠═16573a7e-b6cf-4889-9d82-2828652a6991
# ╠═513575b9-6c7d-4a73-97c9-d6696106d771
# ╠═d39f7fb9-0222-4edf-a967-9b02e79de051
# ╠═e98106f7-5efa-4f83-bbd0-27dee9b247e0
# ╠═1015889c-30ed-4d23-b67a-69e02a670780
# ╠═9dfe3f52-a6f2-401a-a56f-57746037306c
