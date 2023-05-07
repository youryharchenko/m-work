### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 8a05d1a2-e815-11ed-1a25-15311c99ba7f
using Julog

# ╔═╡ 3e31eafd-ac64-49f0-9e19-08186459cb1f
@julog([unifies(a, a)])

# ╔═╡ 0c1313ea-0b38-430a-96da-a70b2268569a
list_a = @julog(list[a, b])

# ╔═╡ e378bbe6-83b7-4e74-8ab7-7373bdadb509
dump(list_a)

# ╔═╡ 9b289d5e-c1f2-44f0-aba8-8583093b90ca
Compound(:unifies, [Const(:a), Const(:a)])

# ╔═╡ 375d4bff-6187-45e2-a975-6d2a18fc89bc
resolve([Compound(:unifies, [Const(:a), Const(:a)])], Clause[])

# ╔═╡ 976d800c-4324-4243-bab3-64c7b2333304
resolve([Compound(:unifies, [Const(:a), Const(:b)])], Clause[])

# ╔═╡ 2933cfcf-bdaa-4e45-9e63-90e0f3c5a1a2
resolve([Compound(:unifies, [Var(:A), Const(:a)])], Clause[])

# ╔═╡ afeeae7b-fdfc-4b2c-ba2a-3b42acaf3fe7
resolve([Compound(:unifies, [Var(:A), Const("abc")])], Clause[])

# ╔═╡ ad364fd7-68b2-499b-b0ca-0fe12beb0b71
resolve([Compound(:unifies, [Var(:A), Const(1)])], Clause[])

# ╔═╡ 488524c8-bf3a-4645-88ce-80a52691a744
resolve([Compound(:unifies, [Var(:A), Const(true)])], Clause[])

# ╔═╡ 45e37302-6ff4-4871-9ffe-4bb96421c683
resolve([Compound(:unifies, [Var(:A), Const(nothing)])], Clause[])

# ╔═╡ 8bd272e9-d736-40a5-9822-2d47f3f50a44
resolve([Compound(:unifies, [Const(:a), Const("a")])], Clause[])

# ╔═╡ ebf77f08-defb-46e6-bfda-b73d5da7692d
let
	r = unify(@julog(a), @julog(a),)
	r == nothing ? false : r
end

# ╔═╡ abd53ea2-2dd4-47d7-98a4-d541876a5d2f
let
	r = unify(@julog(list[A]), @julog(list[a]),)
	r == nothing ? false : r
end

# ╔═╡ 6f94fe33-304b-48e5-8a7f-aa9fe331444d
resolve([@julog(unifies([a], [a]))], Clause[])

# ╔═╡ 336b7f97-50e1-46b9-9ecc-c3016c51d472
resolve([@julog(unifies([a], [b]))], Clause[])

# ╔═╡ a1c3ff2a-2a6c-47cc-b7fb-9f3f0b8aea17
resolve([@julog(unifies([A], [b]))], Clause[])

# ╔═╡ 6d1fb585-b8ab-475f-acaf-203f97d797b3
resolve([@julog(unifies([a], [B]))], Clause[])

# ╔═╡ e7e59114-4fdf-43a2-a1b1-9b9a19acdc40
clause = @julog [
	member(X, [X | Y]) <<= true,
    member(X, [Y | YS]) <<= member(X, YS),
    append([], L, L) <<= true,
    append([X | XS], YS, [X | ZS]) <<= append(XS, YS, ZS),
]

# ╔═╡ d6a4092e-5e48-4da2-b26e-4d9cba72c5a0
resolve([@julog(
	append([a], [b], C)
)], clause)

# ╔═╡ 9f1d4749-ba7c-496e-96f4-fc553c28f91b
resolve([@julog(
	append(A, B, [a, b, c, d])
)], clause)

# ╔═╡ 2fec4267-60ce-4431-a67e-16ddd3043295
resolve(@julog([
	append([a], B, L1),
	append(L1, C, L2),
	append(L2, [d], [a, b, c, d]),
]), clause; mode=:any)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Julog = "5d8bcb5e-2b2c-4a96-a2b1-d40b3d3c344f"

[compat]
Julog = "~0.1.15"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "70766b4fd54d420a6a0480e9e975f42d84503543"

[[deps.Julog]]
git-tree-sha1 = "191e4f6de2ddf2dc60d5d90c412d066814f1655b"
uuid = "5d8bcb5e-2b2c-4a96-a2b1-d40b3d3c344f"
version = "0.1.15"
"""

# ╔═╡ Cell order:
# ╠═8a05d1a2-e815-11ed-1a25-15311c99ba7f
# ╠═3e31eafd-ac64-49f0-9e19-08186459cb1f
# ╠═0c1313ea-0b38-430a-96da-a70b2268569a
# ╠═e378bbe6-83b7-4e74-8ab7-7373bdadb509
# ╠═9b289d5e-c1f2-44f0-aba8-8583093b90ca
# ╠═375d4bff-6187-45e2-a975-6d2a18fc89bc
# ╠═976d800c-4324-4243-bab3-64c7b2333304
# ╠═2933cfcf-bdaa-4e45-9e63-90e0f3c5a1a2
# ╠═afeeae7b-fdfc-4b2c-ba2a-3b42acaf3fe7
# ╠═ad364fd7-68b2-499b-b0ca-0fe12beb0b71
# ╠═488524c8-bf3a-4645-88ce-80a52691a744
# ╠═45e37302-6ff4-4871-9ffe-4bb96421c683
# ╠═8bd272e9-d736-40a5-9822-2d47f3f50a44
# ╠═ebf77f08-defb-46e6-bfda-b73d5da7692d
# ╠═abd53ea2-2dd4-47d7-98a4-d541876a5d2f
# ╠═6f94fe33-304b-48e5-8a7f-aa9fe331444d
# ╠═336b7f97-50e1-46b9-9ecc-c3016c51d472
# ╠═a1c3ff2a-2a6c-47cc-b7fb-9f3f0b8aea17
# ╠═6d1fb585-b8ab-475f-acaf-203f97d797b3
# ╠═e7e59114-4fdf-43a2-a1b1-9b9a19acdc40
# ╠═d6a4092e-5e48-4da2-b26e-4d9cba72c5a0
# ╠═9f1d4749-ba7c-496e-96f4-fc553c28f91b
# ╠═2fec4267-60ce-4431-a67e-16ddd3043295
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
