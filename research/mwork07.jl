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

# ╔═╡ a972219c-e39c-420a-8881-a14823477229
kb = KBs.load("mwork06/save")

# ╔═╡ d963b987-23c8-4930-89d2-f8fd02bc6bef
Core.eval(KBs, :((a, b) = (4, 5)))

# ╔═╡ 513575b9-6c7d-4a73-97c9-d6696106d771
KBs.select(KBs.V, kb)

# ╔═╡ Cell order:
# ╠═220ff242-94a7-11ed-2d9a-7170d2c39d11
# ╠═b5d4587a-d496-475f-b041-8abc83624648
# ╠═a972219c-e39c-420a-8881-a14823477229
# ╠═d963b987-23c8-4930-89d2-f8fd02bc6bef
# ╠═513575b9-6c7d-4a73-97c9-d6696106d771
