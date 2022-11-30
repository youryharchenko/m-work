### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ a677931e-6bbc-11ed-04ce-f9fe76c08a93
using Julog

# ╔═╡ 3ea8e8e4-240a-4ca0-977b-542ab06eb4c7
graph = @julog [
	link(a, b) <<= true, 
	link(a, c) <<= true,
	link(b, d) <<= true,
	link(c, d) <<= true,
	link(c, f) <<= true, 
	link(d, e) <<= true,
	link(d, f) <<= true,
	link(f, a) <<= true,

	path(Node, Node) <<= true,
	path(StartNode, EndNode) <<= link(StartNode, NextNode) & path(NextNode, EndNode),

	path( Node, Node, [Node]) <<= true,
	path( StartNode, EndNode, [StartNode | Rest]) <<=
		link(StartNode, NextNode) &
		path(NextNode, EndNode, Rest),

]

# ╔═╡ 2ee38361-f45e-4f2e-8ab1-eb1452894dcf
resolve(@julog(path(a, f, P)), graph; mode=:any)

# ╔═╡ 075d0f4e-3a1d-41ad-a6b7-b78e61e79231
robot = @julog [
	action(state(P1, P2, floor(P1)), pickup, state(P1, P2, held)) <<= true,
	action(state(P, P, held), drop, state(P, P, in_basket)) <<= true,
	action(state(P, P, L), push(P, NewP), state(NewP, NewP, L)) <<= true,
	action(state(P1, P2, L), go(P1, NewP1), state(NewP1, P2, L)) <<= true,
	
	plan(S, S, []) <<= true,
	plan(S1, GS, [A1 | Rest]) <<=
		action(S1, A1, S2) &
		plan(S2, GS, Rest),
]

# ╔═╡ 089b060c-0265-47d7-b979-f39e0503ee35
resolve(@julog([
	plan(state(door, corner2, floor(middle)), state(_, _, held), Plan)
]), robot; mode=:any)

# ╔═╡ 83496dc3-99a9-4133-ac2e-60530a39493d
resolve(@julog([
	plan(state(door, corner2, floor(middle)), state(_, _, in_basket), Plan)
]), robot; mode=:any)

# ╔═╡ df3d625f-c631-4f6d-b295-2379c6d86fa0
resolve(@julog([
	plan(state(door, corner2, floor(middle)), state(_, middle, in_basket), Plan)
]), robot; mode=:any)

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

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "25a880238abbcd6efedc1ca67007db53e56aa2e8"

[[deps.Julog]]
git-tree-sha1 = "191e4f6de2ddf2dc60d5d90c412d066814f1655b"
uuid = "5d8bcb5e-2b2c-4a96-a2b1-d40b3d3c344f"
version = "0.1.15"
"""

# ╔═╡ Cell order:
# ╠═a677931e-6bbc-11ed-04ce-f9fe76c08a93
# ╠═3ea8e8e4-240a-4ca0-977b-542ab06eb4c7
# ╠═2ee38361-f45e-4f2e-8ab1-eb1452894dcf
# ╠═075d0f4e-3a1d-41ad-a6b7-b78e61e79231
# ╠═089b060c-0265-47d7-b979-f39e0503ee35
# ╠═83496dc3-99a9-4133-ac2e-60530a39493d
# ╠═df3d625f-c631-4f6d-b295-2379c6d86fa0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
