### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ e1f6dbfb-f9b8-438c-a7da-0d8d439dc50a
macro m(c) 
	dump(c)
	
	return :($c+$c)
end

# ╔═╡ b511cbde-52b5-47cf-917e-a4e7b2f6770b
a = 0

# ╔═╡ d8883468-2080-4a08-85d4-4d61a3081c1d
@m a

# ╔═╡ cf9111ee-882f-11ed-1abb-f5e4c62b8a0f
macro iif(c, t, f) 
	dump(c)
	dump(t)
	dump(f)
	r = :($c ? $t : $f)
	dump(r)
	return r
end

# ╔═╡ e3630a0e-8f37-4d62-9c5f-80ba7c40e7c5
@macroexpand @iif x != 0 1/x error("zero devide")

# ╔═╡ 6b30264b-441b-44bd-af28-f3b8174d4fa0
x = 0

# ╔═╡ 594fd78d-9aa1-4d05-8ea3-8d26e15656ac
	
@iif x != 0 1/x error("zero devide")


# ╔═╡ 031f05d0-8a35-4c1b-a75f-50837f4fc683
macro prog(vars, oper...)
	local mvars 
	if vars isa Symbol
		mvars = :($vars)
	end
	return quote
		module M1
			$mvars
			eval($oper[1])
		end
	end
end

# ╔═╡ 734d5013-f3cf-4243-bd01-b9c6b7e6db89
@macroexpand @prog (x) x

# ╔═╡ e5162ad8-4b80-49ad-9a2f-30ab4b710d78
@prog (y) y = 4	y


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
# ╠═e1f6dbfb-f9b8-438c-a7da-0d8d439dc50a
# ╠═b511cbde-52b5-47cf-917e-a4e7b2f6770b
# ╠═d8883468-2080-4a08-85d4-4d61a3081c1d
# ╠═cf9111ee-882f-11ed-1abb-f5e4c62b8a0f
# ╠═e3630a0e-8f37-4d62-9c5f-80ba7c40e7c5
# ╠═6b30264b-441b-44bd-af28-f3b8174d4fa0
# ╠═594fd78d-9aa1-4d05-8ea3-8d26e15656ac
# ╠═031f05d0-8a35-4c1b-a75f-50837f4fc683
# ╠═734d5013-f3cf-4243-bd01-b9c6b7e6db89
# ╠═e5162ad8-4b80-49ad-9a2f-30ab4b710d78
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
