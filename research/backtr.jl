### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 33370fe8-15cc-4246-b338-41512f2520e5
@inline function run!(c, p)
	put!(c, p)
	take!(c)
end

# ╔═╡ e77242f4-df3f-40c9-8b16-2561a8c47514
function factorial(c)
	
	@inline function f(c)
		n = take!(c)
		r(c, n)
	end

	@inline function r(c, n)
		(n == 1) ? put!(c, 1) : put!(c, n * run!(Channel(f), n - 1))
	end
	
	while true
		n = take!(c)
		if n < 0
			put!(c, "exit")
			break
		elseif n == 0
			put!(c, 1)
		else
			r(c, n)
		end
	end
end

# ╔═╡ 6c22bdf4-b1c8-44eb-8126-468451bf11a3
n = big(21)

# ╔═╡ 37e512a8-a0a7-11ed-22a4-6fbddf2f2ba7
run!(Channel(factorial), n)

# ╔═╡ 73dc2156-dd15-4a63-9682-d25961875fe4
let 
	ch = Channel(factorial)
	[run!(ch, big(n)) for n in 21:-2:-1] 
end

# ╔═╡ 777a0aff-f80f-40eb-8007-962e41e4ad10
run!(Channel(factorial), -1)

# ╔═╡ 0d4d501d-ab50-4ab2-806e-742bb4d1b1b3
function fib(n, m = vcat([1], (n == 0) ? [] : fill(0, n - 1)))
	n == 0 && return 0
	if m[n] > 0
		m[n]
	else
		r = fib(n - 1, m) + fib(n - 2, m)
		m[n] = r
	end
end

# ╔═╡ 0be9c39f-117b-488f-bd87-465ea0da2d93
[fib(n) for n in 0:50]

# ╔═╡ 059f6bf8-9621-4b9e-bb7c-c6b9198e674b
fib(80)

# ╔═╡ c9c8a7d7-b030-442b-8e5e-8d8d222547b8
function fibonacci(c)
	
	m = [] 
	
	@inline function f(c)
		n = take!(c)
		r(c, n)
	end

	function r(c, n)
		
		if n == 0
			put!(c, 0) 
		elseif n == 1
			put!(c, 1)
		else
			
			mn = m[n]
			if mn > 0 
				put!(c, mn)
			else
				println((n, m))
				r = run!(Channel(f), n - 1) + run!(Channel(f), n - 2)
				m[n] = r
				println((n, r, m))
				put!(c, r)
			end
		end
	end

	
			
	while true
		n = take!(c)
		
		if n < 0
			put!(c, "exit")
			break
		elseif n == 0
			put!(c, 0)
		else
			m = vcat([1], fill(0, n - 1))
			
			r(c, n)
		end
	end
end

# ╔═╡ b90334a4-30fc-4cf4-9f1f-76daec595889
let 
	ch = Channel(fibonacci)
	#[run!(ch, n) for n in 9:-1:-1] 
end

# ╔═╡ 9f94a982-3b9d-4a1e-973a-7eb9ea69ee8b
run!(Channel(fibonacci), 3) 

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╠═33370fe8-15cc-4246-b338-41512f2520e5
# ╠═e77242f4-df3f-40c9-8b16-2561a8c47514
# ╠═6c22bdf4-b1c8-44eb-8126-468451bf11a3
# ╠═37e512a8-a0a7-11ed-22a4-6fbddf2f2ba7
# ╠═73dc2156-dd15-4a63-9682-d25961875fe4
# ╠═777a0aff-f80f-40eb-8007-962e41e4ad10
# ╠═0d4d501d-ab50-4ab2-806e-742bb4d1b1b3
# ╠═0be9c39f-117b-488f-bd87-465ea0da2d93
# ╠═059f6bf8-9621-4b9e-bb7c-c6b9198e674b
# ╠═c9c8a7d7-b030-442b-8e5e-8d8d222547b8
# ╠═b90334a4-30fc-4cf4-9f1f-76daec595889
# ╠═9f94a982-3b9d-4a1e-973a-7eb9ea69ee8b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
