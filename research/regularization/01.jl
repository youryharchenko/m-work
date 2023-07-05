### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 80e15072-1811-11ee-042e-e18ce5b809ca
function next(A, Xᵢ, Bᵢ)
	A * Xᵢ + Bᵢ
end

# ╔═╡ 705dd939-8897-481a-bacb-fb20c34e265d
A₀ = [1.0 0.0
	  0.0 1.0]

# ╔═╡ 3bad5c40-00ac-4746-a98f-2634c499be2f
X₀ = [1
	  1]

# ╔═╡ 48e95d3a-ff80-4ba4-a02f-0f0f3ac7b5fe
B₀ = [0
	  0]

# ╔═╡ 3b2d9cdc-ec3e-4ca4-8573-c0e89a3291c2
next(A₀, X₀, B₀)

# ╔═╡ Cell order:
# ╠═80e15072-1811-11ee-042e-e18ce5b809ca
# ╠═705dd939-8897-481a-bacb-fb20c34e265d
# ╠═3bad5c40-00ac-4746-a98f-2634c499be2f
# ╠═48e95d3a-ff80-4ba4-a02f-0f0f3ac7b5fe
# ╠═3b2d9cdc-ec3e-4ca4-8573-c0e89a3291c2
