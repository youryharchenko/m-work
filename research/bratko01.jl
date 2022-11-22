### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 9dbb6c3c-68b0-11ed-35c8-7953986f2004
using Julog

# ╔═╡ 9c5f95aa-8a39-45f1-b279-c5c0f23de253
facts = @julog [
	parent(pam, bob) <<= true,
	parent(tom, bob) <<= true,
	parent(tom, liz) <<= true,
	parent(bob, ann) <<= true,
	parent(bob, pat) <<= true,
	parent(pat, jim) <<= true,
	female(pam) <<= true,
	male(tom) <<= true,
	male(bob) <<= true,
	female(liz) <<= true,
	female(pat) <<= true,
	female(ann) <<= true,
	male(jim) <<= true,
]

# ╔═╡ ce67d822-0b1d-4c9d-8125-1e534145a9fd
rules = @julog [
	mother(X, Y) <<=  parent(X, Y) & female(X),
	father(X, Y) <<=  parent(X, Y) & male(X),
	grandparent(X, Z) <<= parent(X, Y) & parent(Y, Z),
	sister(X, Y) <<= parent(Z, X) & parent(Z, Y) & female(X) & not(X == Y),
	ancestor(X, Z) <<= parent(X, Z),
	ancestor(X, Z) <<= parent(X, Y) & ancestor(Y, Z),
	
]

# ╔═╡ 1021a298-249c-4869-9f55-dc89ee9c9e3c
kb = vcat(facts, rules)

# ╔═╡ aa7524e4-46a2-447f-8f4b-c3e58017435a
resolve(@julog([parent(X, bob)]), kb)

# ╔═╡ 155e8574-d233-4660-ad29-d76948c596f1
resolve(@julog([parent(bob, Y)]), kb)

# ╔═╡ 2bf69496-4075-4574-9674-71f6b31ac54a
resolve(@julog([parent(X, ann), parent(X, pat)]), kb)

# ╔═╡ f073c62c-1101-4fe7-91dc-bc30921a44d9
resolve(@julog([mother(X, bob)]), kb)

# ╔═╡ d395023c-eaf8-4ba8-8c71-1e4e9ae50f5a
resolve(@julog([mother(pat, Y)]), kb)

# ╔═╡ 7f3e6138-5d9a-420b-8e5c-36479c10baf7
resolve(@julog([father(bob, Y)]), kb)

# ╔═╡ d232df66-4ae6-4144-9b3d-68b332587f03
resolve(@julog([grandparent(pam, Y)]), kb)

# ╔═╡ d77bf279-05e7-4583-804b-785f97ddd9f8
resolve(@julog([sister(liz, Y)]), kb)

# ╔═╡ cd2efe2c-c6fb-42fe-9eb1-ef51bf3c8139
resolve(@julog([ancestor(X, jim)]), kb)

# ╔═╡ 7677c23c-de85-4199-81f5-045913b0f1cf
resolve(@julog([ancestor(X, pam)]), kb)

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

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.Julog]]
git-tree-sha1 = "191e4f6de2ddf2dc60d5d90c412d066814f1655b"
uuid = "5d8bcb5e-2b2c-4a96-a2b1-d40b3d3c344f"
version = "0.1.15"
"""

# ╔═╡ Cell order:
# ╠═9dbb6c3c-68b0-11ed-35c8-7953986f2004
# ╠═9c5f95aa-8a39-45f1-b279-c5c0f23de253
# ╠═ce67d822-0b1d-4c9d-8125-1e534145a9fd
# ╠═1021a298-249c-4869-9f55-dc89ee9c9e3c
# ╠═aa7524e4-46a2-447f-8f4b-c3e58017435a
# ╠═155e8574-d233-4660-ad29-d76948c596f1
# ╠═2bf69496-4075-4574-9674-71f6b31ac54a
# ╠═f073c62c-1101-4fe7-91dc-bc30921a44d9
# ╠═d395023c-eaf8-4ba8-8c71-1e4e9ae50f5a
# ╠═7f3e6138-5d9a-420b-8e5c-36479c10baf7
# ╠═d232df66-4ae6-4144-9b3d-68b332587f03
# ╠═d77bf279-05e7-4583-804b-785f97ddd9f8
# ╠═cd2efe2c-c6fb-42fe-9eb1-ef51bf3c8139
# ╠═7677c23c-de85-4199-81f5-045913b0f1cf
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
