### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 9dc5d3ce-6a3c-11ed-1d70-c56e23b3755d
using Julog

# ╔═╡ bddf2327-ebff-4b00-90d1-98fa9f56a694
resolve(@julog(unifies(date(D, M, Y), date(D, may, 2002))), Clause[])

# ╔═╡ 37a61be8-89ce-4d0e-a8e1-51fa0a60c66e
resolve(
	@julog(vertical(seg(point(1, 1), point(1, 2)))), 
	@julog([
		vertical(seg(point(X1, Y1), point(X1, Y2))) <<= true,
		horizontal(seg(point(X1,Y1), point(X2, Y1))) <<= true,
	])
)

# ╔═╡ f30a289c-7d45-4e97-a2a5-0989d51912b9
resolve(
	@julog(vertical(seg(point(1, 1), point(2, Y)))), 
	@julog([
		vertical(seg(point(X1, Y1), point(X1, Y2))) <<= true,
		horizontal(seg(point(X1,Y1), point(X2, Y1))) <<= true,
	])
)

# ╔═╡ eda98229-71e1-432f-8168-c82f0018744b
resolve(
	@julog(horizontal(seg(point(1, 1), point(2, Y)))), 
	@julog([
		vertical(seg(point(X1, Y1), point(X1, Y2))) <<= true,
		horizontal(seg(point(X1,Y1), point(X2, Y1))) <<= true,
	])
)

# ╔═╡ e05a9831-e7c5-435d-b3bc-21bb7c572e64
resolve(
	@julog(vertical(seg(point(2,3), P))), 
	@julog([
		vertical(seg(point(X1, Y1), point(X1, Y2))) <<= true,
		horizontal(seg(point(X1,Y1), point(X2, Y1))) <<= true,
	])
)

# ╔═╡ 504d716d-a430-4fbb-8e5a-a6ef3e103f80
resolve(
	@julog([vertical(S), horizontal(S)]), 
	@julog([
		vertical(seg(point(X1, Y1), point(X1, Y2))) <<= true,
		horizontal(seg(point(X1,Y1), point(X2, Y1))) <<= true,
	])
)

# ╔═╡ 5fb230b1-8bf2-4cdd-a41c-20e9cda025c4
lists = @julog [
    member(X, [X | Y]) <<= true,
    member(X, [Y | YS]) <<= member(X, YS),
	
    append([], L, L) <<= true,
    append([X | XS], YS, [X | ZS]) <<= append(XS, YS, ZS),
	
    reverse(X, Y) <<= reverse(X, [], Y),
    reverse([], YS, YS) <<= true,
    reverse([X | XS], Accu, YS) <<= reverse(XS, [X | Accu], YS),
	
	conc([], L, L) <<= true,
	conc([X | L1], L2, [X | L3]) <<= conc(L1, L2, L3),
	
	sublist(S, L) <<= conc(L1, L2, L) &
		conc(S, L3, L2),

	insert(X, [], [X])  <<= true,
	insert(X, [H | T], [X, H | T]) <<= true,
	insert(X, [H | T], [H | T2]) <<= insert(X, T, T2),
	
	permutation([],[]) <<= true,
	permutation([X | L], P) <<=
		permutation(L, L1) &
		insert(X, L1, P),
	
]


# ╔═╡ c1882fee-5e93-47c5-b9f7-46e610f97052
resolve(@julog(member(a, [a, b])), lists)

# ╔═╡ 461ba403-0910-4248-8ad7-ffd454c3a346
resolve(@julog(member(b, [a, [b, c]])), lists)

# ╔═╡ 5256fad7-5030-45f2-94e5-b80c5882ad96
resolve(@julog(member([b, c], [a, [b, c]])), lists)

# ╔═╡ 3a34ce0e-2ede-47c7-a866-4d611ba3d5eb
resolve(@julog(member(X, [a, [b, c]])), lists)

# ╔═╡ 5a8b6679-22e7-46b1-888b-517b8081e297
resolve(@julog(conc([], [], L)), lists)

# ╔═╡ 98c036e5-b51b-4c30-8866-790fa82a3c63
resolve(@julog(conc([a], [], L)), lists)

# ╔═╡ 8a1f0696-958e-4a91-be52-094a2aa974f1
resolve(@julog(conc([], [b], L)), lists)

# ╔═╡ b5e2acf1-b90b-483a-9a71-3fe257552961
resolve(@julog(conc([a], [b], L)), lists)

# ╔═╡ 7e4030c0-2856-4de4-a7b9-60ed9404ab98
resolve(@julog(conc([a, b], [c, d], L)), lists)

# ╔═╡ 91e0433c-a7b0-4de8-bbea-1b001a241146
resolve(@julog(conc(L1, L2, [c, d])), lists)

# ╔═╡ 2bef2a13-83b3-4b2f-958c-9e4215708370
resolve(@julog(conc(Before, [may | After], [jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec])), lists)

# ╔═╡ 36e7dc58-4d24-4195-a3b8-1ddbccae73b3
resolve(@julog(conc(_, [M1, may, M2 | _], [jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec])), lists)

# ╔═╡ e1ccfa97-605e-4b20-a5a0-edd826e33a2a
resolve(@julog(sublist([apr, may, jun], [jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec])), lists)

# ╔═╡ d1470388-d976-439b-ba00-728ea8ea224c
resolve(@julog(sublist([M1, M2, M3], [jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec])), lists)

# ╔═╡ ccbab989-8bba-4b1a-8f3f-9881f167ad91
resolve(@julog(insert(a, [], L)), lists)

# ╔═╡ ab3bbb1f-f897-4159-af7c-616478ece17b
resolve(@julog(insert(a, [b], L)), lists)

# ╔═╡ a6ef258a-775f-404f-99d6-07b378e3de57
resolve(@julog(insert(a, [b, c], L)), lists)

# ╔═╡ 27fc7512-93b9-4f5d-9108-d9290d44ac8d
resolve(@julog(insert(X, [b, c], [b, c, a])), lists)

# ╔═╡ e01a6862-0552-43f7-b2ad-66b43b536d97
resolve(@julog(insert(a, L, [b, c, a])), lists)

# ╔═╡ d6dedf56-f76e-4f29-b862-d6d82ab84c02
resolve(@julog(permutation([red, blue, green], P)), lists)

# ╔═╡ 92b94966-8307-475f-bd03-cf4fd831f845
resolve(@julog(permutation(P, [red, blue, green])), lists; mode=:any)

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
# ╠═9dc5d3ce-6a3c-11ed-1d70-c56e23b3755d
# ╠═bddf2327-ebff-4b00-90d1-98fa9f56a694
# ╠═37a61be8-89ce-4d0e-a8e1-51fa0a60c66e
# ╠═f30a289c-7d45-4e97-a2a5-0989d51912b9
# ╠═eda98229-71e1-432f-8168-c82f0018744b
# ╠═e05a9831-e7c5-435d-b3bc-21bb7c572e64
# ╠═504d716d-a430-4fbb-8e5a-a6ef3e103f80
# ╠═5fb230b1-8bf2-4cdd-a41c-20e9cda025c4
# ╠═c1882fee-5e93-47c5-b9f7-46e610f97052
# ╠═461ba403-0910-4248-8ad7-ffd454c3a346
# ╠═5256fad7-5030-45f2-94e5-b80c5882ad96
# ╠═3a34ce0e-2ede-47c7-a866-4d611ba3d5eb
# ╠═5a8b6679-22e7-46b1-888b-517b8081e297
# ╠═98c036e5-b51b-4c30-8866-790fa82a3c63
# ╠═8a1f0696-958e-4a91-be52-094a2aa974f1
# ╠═b5e2acf1-b90b-483a-9a71-3fe257552961
# ╠═7e4030c0-2856-4de4-a7b9-60ed9404ab98
# ╠═91e0433c-a7b0-4de8-bbea-1b001a241146
# ╠═2bef2a13-83b3-4b2f-958c-9e4215708370
# ╠═36e7dc58-4d24-4195-a3b8-1ddbccae73b3
# ╠═e1ccfa97-605e-4b20-a5a0-edd826e33a2a
# ╠═d1470388-d976-439b-ba00-728ea8ea224c
# ╠═ccbab989-8bba-4b1a-8f3f-9881f167ad91
# ╠═ab3bbb1f-f897-4159-af7c-616478ece17b
# ╠═a6ef258a-775f-404f-99d6-07b378e3de57
# ╠═27fc7512-93b9-4f5d-9108-d9290d44ac8d
# ╠═e01a6862-0552-43f7-b2ad-66b43b536d97
# ╠═d6dedf56-f76e-4f29-b862-d6d82ab84c02
# ╠═92b94966-8307-475f-bd03-cf4fd831f845
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
