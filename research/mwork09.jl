### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 3575e562-c0a0-4b4e-8946-b3126b9420e0
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	Pkg.instantiate()
	Pkg.add("Revise")
	Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ 9f486d46-9d8a-11ed-1d5b-2db69b21e703
using Revise, JuliaDB, Serialization, KBs

# ╔═╡ 0df734c3-152c-4144-be22-012ac0f6f3fa
dir = "db-save"

# ╔═╡ 787bf1a5-6e1c-4712-936a-3476b6ecb5de


# ╔═╡ 25d57e40-4d0c-43db-986a-9773a3ff676f
jdb = load_as_juliadb(dir)

# ╔═╡ 4230f7fd-4b99-44c8-8e36-3a211e7612e1


# ╔═╡ Cell order:
# ╠═3575e562-c0a0-4b4e-8946-b3126b9420e0
# ╠═9f486d46-9d8a-11ed-1d5b-2db69b21e703
# ╠═0df734c3-152c-4144-be22-012ac0f6f3fa
# ╠═787bf1a5-6e1c-4712-936a-3476b6ecb5de
# ╠═25d57e40-4d0c-43db-986a-9773a3ff676f
# ╠═4230f7fd-4b99-44c8-8e36-3a211e7612e1
