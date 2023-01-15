### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 3f030f34-932d-11ed-3c86-cdd782a64ac1
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	Pkg.instantiate()
	Pkg.add("Revise")
	Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ d04d2385-27cd-4a51-bad1-79748de47c96
using Revise, KBs, UUIDs

# ╔═╡ 713f471e-7939-43e7-84ef-7a460d3dc7d4
script1 = """
begin
	using KBs
	kb1 = KBs.KBase()
end
"""

# ╔═╡ a3f88d25-b7df-46ac-9720-07e895e51807
expr1 = Meta.parse(script1)

# ╔═╡ 8345b39a-f91b-4b5b-8fc5-090ed421fa6c
expr2 = Expr(:block, 
			Expr(:using, 
				Expr(:(.), 
					:KBs
				)
			),
			Expr(:(=), 
				:kb2, 
				Expr(:call, 
					Expr(:(.), 
						:KBs,
						QuoteNode(:KBase)
					)
				)
				
			)
		)

# ╔═╡ a21861ff-8e05-4bec-821e-19bca075025a
dump(expr1)

# ╔═╡ 98a3202f-448e-4ee3-9276-c7897ff83510
dump(expr2)

# ╔═╡ b314cae4-038b-45e8-8a8d-c712a6250684
eval(expr1)

# ╔═╡ d951bc8b-1d5c-4167-b5fe-306dbc3a91b5
eval(expr2)

# ╔═╡ db39194d-3fe4-45c8-8fa8-fd7b4bcc6180
kb1

# ╔═╡ 486caeef-2165-492a-86df-5b99abc66f71
kb3 = KBs.load("mwork06/save")

# ╔═╡ a9ff18fa-c063-4488-99bd-838f81dc2bdb
Core.eval(KBs, :((a, b) = (4, 5)))

# ╔═╡ caf2a996-b4a2-41ee-ac22-4b20a083b9fb
KBs.select(KBs.V, kb3)

# ╔═╡ 8d450d39-5663-477f-862e-432d70973900
KBs.select(KBs.C, kb3)

# ╔═╡ feee8bd9-7598-4dde-b797-09b72c3e2547
KBs.select(KBs.O, kb3)

# ╔═╡ 94e9643e-31e0-4fb5-a446-68506a600677
KBs.select(KBs.CO, kb3)

# ╔═╡ ee5620ae-282b-4481-9630-9737ffd6a734
Core.eval(KBs, KBs.select(KBs.O, kb3)[1, :v].value)

# ╔═╡ fe06bd10-1a0a-4d97-b39d-54857e286e5d
oid = KBs.select(KBs.O, kb3)[1, :oid]

# ╔═╡ 71076eea-0beb-4e22-a857-576aaf4f69da
expr3 = :((kb, id) -> println(KBs.value(kb, id)))

# ╔═╡ ae1855dc-8bf7-48da-8c62-e72b2ee2e462
f = eval(expr3)

# ╔═╡ ffad666d-b6ab-4d44-a281-a95de7649fd1
f(kb3, oid)

# ╔═╡ f8ac7242-7ba6-467d-a8e9-4c8f2493bc7d
kb4 = KBs.load("db-save")

# ╔═╡ efaee156-00af-4af5-b1c7-8f80d2cb6e7a
KBs.select(KBs.V, kb4; cs = [:vid, :ev])

# ╔═╡ b061fe29-e9ad-4631-b9d0-4a4f40205dc5
KBs.select(KBs.C, kb4; cs = [:cid, :v, :ev])

# ╔═╡ 9a07b080-5bda-4627-992c-060c3f7e7e63
KBs.select(KBs.O, kb4; cs = [:oid, :v, :ev])

# ╔═╡ d9f0eb77-7d8b-4092-8bd5-c6cfabb66f25
KBs.select(KBs.CO, kb4; cs = [:cid, :cev, :oev])

# ╔═╡ f27ea266-47e4-43ef-b4e4-edd5a405adef
KBs.select(KBs.R, kb4; cs = [:rid, :v])

# ╔═╡ 887dbe97-a328-4705-a456-01c16433feff
KBs.select(KBs.RC, kb4; cs = [:rcid, :cfv, :ctv])

# ╔═╡ dc08d73c-0e83-45eb-b0e5-284589129901
KBs.select(KBs.RCO, kb4; cs = [:rcoid, :cfv, :ofv, :ctv, :otv])

# ╔═╡ e59e9e64-d5a7-459a-b367-4ffd1b3343ed
KBs.select(KBs.A, kb4; cs = [:aid, :v])

# ╔═╡ c9f1c4fd-f56a-4455-b9a8-c23da866e840
KBs.select(KBs.AC, kb4; cs = [:acid, :cv, :av, :v])

# ╔═╡ 1d9794ea-d4b5-4b39-bea0-42313304e71d
KBs.select(KBs.ACO, kb4; cs = [:acid, :cv, :ov, :av, :v])

# ╔═╡ bb240998-f987-4b30-b039-498c5c177488
KBs.select(KBs.AR, kb4; cs = [:arid, :rv, :av, :v])

# ╔═╡ d6045b12-49eb-4246-8505-705dcf2ce213
KBs.select(KBs.ARC, kb4; cs = [:arcid, :cfv, :ctv, :av, :v])

# ╔═╡ 025645c0-497c-4451-9d01-98fe67887dde
KBs.select(KBs.ARCO, kb4; cs = [:arcid, :cfv, :ofv, :ctv, :otv, :av, :v])

# ╔═╡ 1a8f0993-0022-4255-92c2-7493e816ab81
let
	d = Dict()
	(:vid in [:vid, :value]) && (d[:vid] = [1, 2])
	d
end

# ╔═╡ Cell order:
# ╠═3f030f34-932d-11ed-3c86-cdd782a64ac1
# ╠═d04d2385-27cd-4a51-bad1-79748de47c96
# ╠═713f471e-7939-43e7-84ef-7a460d3dc7d4
# ╠═a3f88d25-b7df-46ac-9720-07e895e51807
# ╠═8345b39a-f91b-4b5b-8fc5-090ed421fa6c
# ╠═a21861ff-8e05-4bec-821e-19bca075025a
# ╠═98a3202f-448e-4ee3-9276-c7897ff83510
# ╠═b314cae4-038b-45e8-8a8d-c712a6250684
# ╠═d951bc8b-1d5c-4167-b5fe-306dbc3a91b5
# ╠═db39194d-3fe4-45c8-8fa8-fd7b4bcc6180
# ╠═486caeef-2165-492a-86df-5b99abc66f71
# ╠═a9ff18fa-c063-4488-99bd-838f81dc2bdb
# ╠═caf2a996-b4a2-41ee-ac22-4b20a083b9fb
# ╠═8d450d39-5663-477f-862e-432d70973900
# ╠═feee8bd9-7598-4dde-b797-09b72c3e2547
# ╠═94e9643e-31e0-4fb5-a446-68506a600677
# ╠═ee5620ae-282b-4481-9630-9737ffd6a734
# ╠═fe06bd10-1a0a-4d97-b39d-54857e286e5d
# ╠═71076eea-0beb-4e22-a857-576aaf4f69da
# ╠═ae1855dc-8bf7-48da-8c62-e72b2ee2e462
# ╠═ffad666d-b6ab-4d44-a281-a95de7649fd1
# ╠═f8ac7242-7ba6-467d-a8e9-4c8f2493bc7d
# ╠═efaee156-00af-4af5-b1c7-8f80d2cb6e7a
# ╠═b061fe29-e9ad-4631-b9d0-4a4f40205dc5
# ╠═9a07b080-5bda-4627-992c-060c3f7e7e63
# ╠═d9f0eb77-7d8b-4092-8bd5-c6cfabb66f25
# ╠═f27ea266-47e4-43ef-b4e4-edd5a405adef
# ╠═887dbe97-a328-4705-a456-01c16433feff
# ╠═dc08d73c-0e83-45eb-b0e5-284589129901
# ╠═e59e9e64-d5a7-459a-b367-4ffd1b3343ed
# ╠═c9f1c4fd-f56a-4455-b9a8-c23da866e840
# ╠═1d9794ea-d4b5-4b39-bea0-42313304e71d
# ╠═bb240998-f987-4b30-b039-498c5c177488
# ╠═d6045b12-49eb-4246-8505-705dcf2ce213
# ╠═025645c0-497c-4451-9d01-98fe67887dde
# ╠═1a8f0993-0022-4255-92c2-7493e816ab81
