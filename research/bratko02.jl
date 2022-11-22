### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ ee806ca0-68b8-11ed-1b11-853f7cb9dc4b
using Julog

# ╔═╡ 1f9c20eb-6301-43b7-8e7a-4ae0fb30755f
facts = @julog [
	see(a, 2, 5) <<= true,
	see(d, 5, 5) <<= true,
	see(e, 5, 2) <<= true,
	on(a, b) <<= true,
	on(b, c) <<= true,
	on(c, table) <<= true,
	on(d, table) <<= true,
	on(e, table) <<= true,
]

# ╔═╡ f602c695-1f4c-4b4b-8a08-5105eb314678
rules = @julog [
	z(B, 0) <<= on(B, table),
	z(B, Z) <<= on(B, BO) & z(BO, ZO) & is(Z, ZO + 1),
	xy(B, X, Y) <<= see(B, X, Y),
	xy(B, X, Y) <<= on(BO, B) & xy(BO, X, Y),
	xyz(B, X, Y, Z) <<= xy(B, X, Y) & z(B, Z),
]

# ╔═╡ c9701308-91f6-4055-a559-03dcc700afc7
kb = vcat(facts, rules)

# ╔═╡ b80c5675-60f0-4d65-b077-bc5a0fb6dc28
resolve(@julog([on(B, _)]), kb)

# ╔═╡ 4ce6650e-e71e-46a9-bba8-7b6f2910a5e0
resolve(@julog([see(B1, _, Y), see(B2, _, Y), B1 != B2]), kb)

# ╔═╡ b3e88cfa-1f3e-44f1-bfb6-425daff3b1d7
resolve(@julog([on(B, _), on(_, B)]), kb)

# ╔═╡ 2204d921-6989-4613-a562-ddcd09cbbb3d
resolve(@julog([on(B, _), not(see(B, _, _))]), kb)

# ╔═╡ 2bab9b86-467e-441a-9306-2612be0630f0
resolve(@julog([see(B, X, _), not(and(see(B2, X2, _), X2 < X))]), kb)

# ╔═╡ 43a987f4-230c-4f49-9539-dc6619a8fb06
resolve(@julog([z(B, Z)]), kb)

# ╔═╡ 12777128-443d-4f7b-a0ea-7a07eebd6a59
resolve(@julog([z(a, 2)]), kb)

# ╔═╡ ca13bfa6-e76b-42f4-92de-45d990162168
resolve(@julog([xy(B, X, Y), B != table]), kb)

# ╔═╡ d16a3942-8de1-49ec-bc14-518c9a42cab6
resolve(@julog([xyz(B, X, Y, Z)]), kb)

# ╔═╡ 231dafeb-a7fd-4e67-a8cb-c5b25db5741b
resolve(@julog([xyz(B, X, Y, 2)]), kb)

# ╔═╡ 84fe234e-e0c4-4a4a-9920-d65e8638d30b
crossword = @julog [
	word(d,o,g) <<= true,
	word(f,o,u,r) <<= true,
	word(b,a,k,e,r) <<= true,
	word(p,r,o,l,o,g) <<= true,
	word(r,u,n) <<= true,
	word(l,o,s,t) <<= true,
	word(f,o,r,u,m) <<= true,
	word(v,a,n,i,s,h) <<= true,
	word(t,o,p) <<= true,
	word(m,e,s,s) <<= true,
	word(g,r,e,e,n) <<= true,
	word(w,o,n,d,e,r) <<= true,
	word(f,i,v,e) <<= true,
	word(u,n,i,t) <<= true,
	word(s,u,p,e,r) <<= true,
	word(y,e,l,l,o,w) <<= true,
	solution(L1,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15,L16) <<=
		word(L1,L2,L3,L4,L5) &
		word(L9,L10,L11,L12,L13,L14) &
		word(L1,L6,L9,L15) &
		word(L3,L7,L11) &
		word(L5,L8,L13,L16),
]

# ╔═╡ 58ba857d-335e-4717-b234-2b683e43982c
resolve(@julog([solution(L1,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15,L16)]), crossword)

# ╔═╡ f98c04e7-792c-4b14-b9a9-1609c5368379
scheduling = @julog [
	expert(bioinformatics, barbara) <<= true,
	expert(artificial_intelligence, adam) <<= true,
	expert(artificial_intelligence, barbara) <<= true,
	expert(databases, danny) <<= true,
	expert(bioinformatics, ben) <<= true,
	expert(artificial_intelligence, ann) <<= true,
	expert(databases, adam) <<= true,
	time(morning) <<= true,
	time(afternoon) <<= true,
	schedule( Ta, A1, A2, Tb, B1, B2, Td, D1, D2) <<=
		session(Ta, artificial_intelligence, A1, A2) &
		session(Tb, bioinformatics, B1, B2) &
		session(Td, databases, D1, D2) &
		no_conflict(Ta, A1, A2, Tb, B1, B2) &
		no_conflict(Ta, A1, A2, Td, D1, D2) &
		no_conflict(Tb, B1, B2, Td, D1, D2),
	session(Time, Topic, P1, P2) <<=
		time(Time) &
		expert(Topic, P1) &
		expert(Topic, P2) &
		(P1 != P2),
	no_conflict(Time1, _, _, Time2, _, _) <<=
		(Time1 != Time2),
	no_conflict(Time, P1, P2, Time, Q1, Q2) <<=
		(P1 != Q1) & 
		(P1 != Q2) &
		(P2 != Q1) & 
		(P2 != Q2),
	
]

# ╔═╡ 192af62e-145c-426b-8090-59baf1a2b856
resolve(@julog([schedule(Ta, A1, A2, Tb, B1, B2, Td, D1, D2)]), scheduling)

# ╔═╡ 56dcb36d-ebca-446b-ab5c-691875169e4e
resolve(@julog([schedule(T, A1, A2, morning, B1, B2, morning, D1, D2)]), scheduling)

# ╔═╡ 8aefec01-b89b-4e90-bc43-19c4ebaa5364
colouring = @julog [
	n(red, green) <<= true,
	n(green, red) <<= true,
	n(blue, red) <<= true,
	n(yellow, red) <<= true,
	n(red, blue) <<= true,
	n(green, blue) <<= true,
	n(blue, green) <<= true,
	n(yellow, green) <<= true,
	n(red, yellow) <<= true,
	n(green, yellow) <<= true,
	n(blue, yellow) <<= true,
	n(yellow, blue) <<= true,
	colours(IT, SI, HR, CH, AT, HU, DE, SK, CZ, PL, SEA) <<=
		
		n(IT, CH) &
		n(IT, AT) &
		n(IT, SI) &
		n(IT, SEA) & 
		n(SI, AT) &
		n(SI, HR) &
		n(SI, HU) &
		n(SI, SEA) &
		n(HR, HU) &
		n(HR, SEA) &
		n(AT, CH) &
		n(AT, DE) &
		n(AT, HU) &
		n(AT, SK) &
		n(AT, CZ) &
		n(CH, DE) &
		n(HU, SK) &
		n(DE, SK) &
		n(DE, CZ) &
		n(DE, PL) &
		n(SK, CZ) &
		n(SK, PL) &
		n(CZ, PL) &
		(SEA == blue),
]

# ╔═╡ 475c92b3-02c4-432e-a46d-ead689129c10
resolve(@julog([colours(IT, SI, HR, CH, AT, HU, DE, SK, CZ, PL, SEA)]), colouring)

# ╔═╡ d392a1d6-ec63-4192-8218-0e04faa01d7a
Text(write_prolog(colouring))

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
# ╠═ee806ca0-68b8-11ed-1b11-853f7cb9dc4b
# ╠═1f9c20eb-6301-43b7-8e7a-4ae0fb30755f
# ╠═f602c695-1f4c-4b4b-8a08-5105eb314678
# ╠═c9701308-91f6-4055-a559-03dcc700afc7
# ╠═b80c5675-60f0-4d65-b077-bc5a0fb6dc28
# ╠═4ce6650e-e71e-46a9-bba8-7b6f2910a5e0
# ╠═b3e88cfa-1f3e-44f1-bfb6-425daff3b1d7
# ╠═2204d921-6989-4613-a562-ddcd09cbbb3d
# ╠═2bab9b86-467e-441a-9306-2612be0630f0
# ╠═43a987f4-230c-4f49-9539-dc6619a8fb06
# ╠═12777128-443d-4f7b-a0ea-7a07eebd6a59
# ╠═ca13bfa6-e76b-42f4-92de-45d990162168
# ╠═d16a3942-8de1-49ec-bc14-518c9a42cab6
# ╠═231dafeb-a7fd-4e67-a8cb-c5b25db5741b
# ╠═84fe234e-e0c4-4a4a-9920-d65e8638d30b
# ╠═58ba857d-335e-4717-b234-2b683e43982c
# ╠═f98c04e7-792c-4b14-b9a9-1609c5368379
# ╠═192af62e-145c-426b-8090-59baf1a2b856
# ╠═56dcb36d-ebca-446b-ab5c-691875169e4e
# ╠═8aefec01-b89b-4e90-bc43-19c4ebaa5364
# ╠═475c92b3-02c4-432e-a46d-ead689129c10
# ╠═d392a1d6-ec63-4192-8218-0e04faa01d7a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
