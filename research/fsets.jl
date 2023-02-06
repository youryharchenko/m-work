### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 1f226556-a537-11ed-07c6-2563801fe89e
using Julog

# ╔═╡ f8da962b-8ec6-4526-91f5-6d35dce2354b
funcs = Dict(
	:iselm => (e, s) -> e in s,
	:set => (s) -> Set(s)
)

# ╔═╡ f8460a70-3bb1-4085-8656-19330001ba3a
funcs[:set]((:a, :b))

# ╔═╡ 7c73396d-ef20-44a2-8e16-666e4cb4d6e2
rules = @julog [
	∈(E, C) <<= ∪(A, B, C) & ∈(E, A),
	∈(E, C) <<= ∪(A, B, C) & ∈(E, B),
	∈(E, C) <<= ∩(A, B, C) & ∈(E, A) & ∈(E, B),
	∈(E, C) <<= /(A, B, C) & ∈(E, A) & not(∈(E, B)),
	⊂(A, B) <<= forall(∈(E, A), ∈(E, B)),
	eval(M, X, Y) <<= mor(M, A, B) & ob(A) & ob(B) & ∈(X, A) & ∈(Y, B) & call(M, X, Y),
	eval(M, X, Z) <<= comp(F, G, M) & eval(F, X, Y) & eval(G, Y, Z),
	eval(I, X, Y) <<= ident(I) & mor(I, A, A) & ob(A) & ∈(X, A) & ∈(Y, A) & unifies(X, Y),
	eq(M1, M2) <<= forall(eval(M1, X1, Y1), and(eval(M2, X2, Y2), unifies(X1, X2),  unifies(Y1, Y2))) & forall(eval(M2, X2, Y2), and(eval(M1, X1, Y1), unifies(X1, X2), unifies(Y1, Y2))),
]

# ╔═╡ e1baa397-3d34-44f6-9b5e-4048f9437d37
facts = @julog [
	∈(e1, a) <<= true,
	∈(e2, a) <<= true,
	∈(e3, a) <<= true,
	∈(e2, b) <<= true,
	∈(e4, b) <<= true,
	∈(e5, b) <<= true,
    ∪(a, b, c) <<= true,
	∩(a, b, d) <<= true,
	/(a, b, f) <<= true,
	/(c, d, g) <<= true,
	ob(a) <<= true,
	ob(b) <<= true,
	mor(f, a, b) <<= true,
	mor(g, b, a) <<= true,
	mor(ia, a, a) <<= true,
	ident(ia) <<= true,
	mor(ib, b, b) <<= true,
	ident(ib) <<= true,
	f(e1, e4)  <<= true,
	f(e2, e2)  <<= true,
	f(e3, e5)  <<= true,
	g(e4, e1)  <<= true,
	g(e2, e2)  <<= true,
	g(e5, e3)  <<= true,
	comp(f, g, h) <<= true,
	comp(g, f, j) <<= true,
	comp(h, f, k) <<= true,
	comp(j, g, l) <<= true,
]

# ╔═╡ 2a5ea873-8a2f-4c76-8b3c-d2d4c82cc699
resolve(@julog([eval(f, e1, C)]), vcat(facts, rules))

# ╔═╡ 80e135cb-119c-44d9-a15d-0d963e244607
resolve(@julog([eval(f, e2, C)]), vcat(facts, rules))

# ╔═╡ 262a3c63-50ac-4ca5-b77b-30aba7162328
resolve(@julog([eval(f, e3, C)]), vcat(facts, rules))

# ╔═╡ d4a4fee4-c241-4b0e-952d-c1900addf6a7
resolve(@julog([eval(g, e4, C)]), vcat(facts, rules))

# ╔═╡ 3c5dffd3-4f11-4aa7-add7-26cad57d2560
resolve(@julog([eval(g, e2, C)]), vcat(facts, rules))

# ╔═╡ aa6b2a66-ed60-4fc5-9d7e-501e784b30d8
resolve(@julog([eval(g, e5, C)]), vcat(facts, rules))

# ╔═╡ 9a7b5d6f-6c55-4ee8-a28d-b66bea40b23b
resolve(@julog([eval(h, e1, C)]), vcat(facts, rules))

# ╔═╡ f74b0958-f366-47b8-9fde-8668f4fea223
resolve(@julog([eval(h, e2, C)]), vcat(facts, rules))

# ╔═╡ a3e77a9c-b47f-46a5-bb9c-bb49bc32aa2c
resolve(@julog([eval(h, e3, C)]), vcat(facts, rules))

# ╔═╡ 0bbac5b8-6388-48b7-853d-8b9e5da1b5f4
resolve(@julog([eval(j, e4, C)]), vcat(facts, rules))

# ╔═╡ 4fc1035c-c4a4-4050-a1c6-b262529b48ce
resolve(@julog([eval(k, e1, C)]), vcat(facts, rules))

# ╔═╡ e53d3aef-d674-4965-936c-aa390475b5f2
resolve(@julog([eval(l, e5, C)]), vcat(facts, rules))

# ╔═╡ 49078507-e850-442b-88d1-d4985034a658
resolve(@julog([eval(ia, e1, C)]), vcat(facts, rules))

# ╔═╡ ba68f3d9-4017-4300-86af-b2ce8c179fc9
resolve(@julog([eval(ia, e2, C)]), vcat(facts, rules))

# ╔═╡ 92e23dfa-9d07-4bfa-b288-d349542e3635
resolve(@julog([eval(ia, e3, C)]), vcat(facts, rules))

# ╔═╡ 4950b1f5-1ccb-43f0-becf-e9806c7d6a53
resolve(@julog([eval(ib, e4, C)]), vcat(facts, rules))

# ╔═╡ 72da0b85-c824-478a-93b3-cf3449a3fd37
resolve(@julog([eval(ib, e5, C)]), vcat(facts, rules))

# ╔═╡ 53e0c9a0-e2a0-4694-bda6-dd961b4e71aa
resolve(@julog([eq(ia, ia)]), vcat(facts, rules))

# ╔═╡ 2b4b74a2-de6b-446e-a960-936f8811d9e0
resolve(@julog([eq(f, f)]), vcat(facts, rules))

# ╔═╡ 825c2cef-b99f-4920-98ff-d09369127c75
resolve(@julog([eq(f, g)]), vcat(facts, rules))

# ╔═╡ aedc5980-9d6c-45d9-80f7-4cf0af3089b2
resolve(@julog([eq(g, g)]), vcat(facts, rules))

# ╔═╡ 14e54cf3-2cb0-4587-8243-5e16f9c01435
resolve(@julog([eq(ia, h)]), vcat(facts, rules))

# ╔═╡ 5dc26ceb-ddd9-44e5-9ff4-13186b88750e
resolve(@julog([eq(j, ib)]), vcat(facts, rules))

# ╔═╡ 03b0018e-d932-4a35-8062-8f64350b1566
resolve(@julog([eval(ia, X, Y)]), vcat(facts, rules))

# ╔═╡ 073a3d75-b5f2-44aa-aa14-a6294b608435
resolve(@julog([eval(i, X, Y)]), vcat(facts, rules))

# ╔═╡ 5a408eeb-b636-4e90-b0f7-4cfa428baf6f
resolve(@julog([∈(e1, a)]), vcat(facts, rules))

# ╔═╡ 005bf7d6-d79c-4684-a983-7a3191b103a7
resolve(@julog([∈(e2, S)]), vcat(facts, rules))

# ╔═╡ 4c61150c-5936-4c42-b52a-250684e0d5b6
resolve(@julog([∈(e3, S)]), vcat(facts, rules))

# ╔═╡ 536be535-f81b-420e-a705-f36e70c1fe81
resolve(@julog([∪(a, b, c)]), vcat(facts, rules))

# ╔═╡ 230faad3-be42-4fb4-977f-febffa92cc00
resolve(@julog([∪(A, B, c)]), vcat(facts, rules))

# ╔═╡ 30ecd476-2ee2-488f-ba9c-97ce0008a035
resolve(@julog([∈(E, c)]), vcat(facts, rules))

# ╔═╡ 55740c6c-bd5f-4257-9ffd-ae3b4f16147e
resolve(@julog([∈(E, d)]), vcat(facts, rules))

# ╔═╡ 6e91f158-6efb-4eb0-bac0-712a16c6f76c
resolve(@julog([∈(E, f)]), vcat(facts, rules))

# ╔═╡ a9e0e8b4-f59a-4e6a-9b94-1affa835cb94
resolve(@julog([∈(E, g)]), vcat(facts, rules))

# ╔═╡ 7791c8da-7228-47a2-a489-62274b600766
resolve(@julog([∈(e5, S)]), vcat(facts, rules))

# ╔═╡ 571158f3-7146-4bb5-bc0f-3ee7309d8dfc
resolve(@julog([⊂(g, c)]), vcat(facts, rules))

# ╔═╡ 890a9fec-8dfe-4fa2-9db8-2a5ed7fa3085
resolve(@julog([findall(E, ∈(E, a), L)]), vcat(facts, rules))

# ╔═╡ 3cc3b0c6-647e-42d6-b0ec-959ce240d658
resolve(@julog([findall(E, ∈(E, b), L)]), vcat(facts, rules))

# ╔═╡ 1f9311ac-382b-46d0-a413-08c25f63d71f
resolve(@julog([findall(E, ∈(E, c), L)]), vcat(facts, rules))

# ╔═╡ c4673e66-89d8-472d-bfc4-3b70dcc0e3c2
resolve(@julog([findall(E, ∈(E, d), L)]), vcat(facts, rules))

# ╔═╡ 2f6d9a61-940b-41f6-970f-78cb9c9dd4e4
resolve(@julog([findall(E, ∈(E, f), L)]), vcat(facts, rules))

# ╔═╡ 7cdafb01-c5df-4216-9699-a6e8bac11403
resolve(@julog([findall(E, ∈(E, g), L)]), vcat(facts, rules))

# ╔═╡ 58eef354-ab61-42bc-bed0-144f26bb8514
resolve(@julog([findall(S, ∈(e1, S), L)]), vcat(facts, rules))

# ╔═╡ 80c35d84-506a-4b6a-8bad-acd936a08f75
resolve(@julog([findall(S, ∈(e2, S), L)]), vcat(facts, rules))

# ╔═╡ 3b5b99b9-27eb-4050-9f3a-f0f28fba9420
resolve(@julog([findall(S, ∈(e3, S), L)]), vcat(facts, rules))

# ╔═╡ 31fb95d4-be42-492a-9b62-dccfc6abdd8b
resolve(@julog([findall(S, ∈(e4, S), L)]), vcat(facts, rules))

# ╔═╡ ea0331c7-d113-4bb9-9de2-6ccb7925340b
resolve(@julog([findall(S, ∈(e5, S), L)]), vcat(facts, rules))

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
# ╠═1f226556-a537-11ed-07c6-2563801fe89e
# ╠═f8da962b-8ec6-4526-91f5-6d35dce2354b
# ╠═f8460a70-3bb1-4085-8656-19330001ba3a
# ╠═7c73396d-ef20-44a2-8e16-666e4cb4d6e2
# ╠═e1baa397-3d34-44f6-9b5e-4048f9437d37
# ╠═2a5ea873-8a2f-4c76-8b3c-d2d4c82cc699
# ╠═80e135cb-119c-44d9-a15d-0d963e244607
# ╠═262a3c63-50ac-4ca5-b77b-30aba7162328
# ╠═d4a4fee4-c241-4b0e-952d-c1900addf6a7
# ╠═3c5dffd3-4f11-4aa7-add7-26cad57d2560
# ╠═aa6b2a66-ed60-4fc5-9d7e-501e784b30d8
# ╠═9a7b5d6f-6c55-4ee8-a28d-b66bea40b23b
# ╠═f74b0958-f366-47b8-9fde-8668f4fea223
# ╠═a3e77a9c-b47f-46a5-bb9c-bb49bc32aa2c
# ╠═0bbac5b8-6388-48b7-853d-8b9e5da1b5f4
# ╠═4fc1035c-c4a4-4050-a1c6-b262529b48ce
# ╠═e53d3aef-d674-4965-936c-aa390475b5f2
# ╠═49078507-e850-442b-88d1-d4985034a658
# ╠═ba68f3d9-4017-4300-86af-b2ce8c179fc9
# ╠═92e23dfa-9d07-4bfa-b288-d349542e3635
# ╠═4950b1f5-1ccb-43f0-becf-e9806c7d6a53
# ╠═72da0b85-c824-478a-93b3-cf3449a3fd37
# ╠═53e0c9a0-e2a0-4694-bda6-dd961b4e71aa
# ╠═2b4b74a2-de6b-446e-a960-936f8811d9e0
# ╠═825c2cef-b99f-4920-98ff-d09369127c75
# ╠═aedc5980-9d6c-45d9-80f7-4cf0af3089b2
# ╠═14e54cf3-2cb0-4587-8243-5e16f9c01435
# ╠═5dc26ceb-ddd9-44e5-9ff4-13186b88750e
# ╠═03b0018e-d932-4a35-8062-8f64350b1566
# ╠═073a3d75-b5f2-44aa-aa14-a6294b608435
# ╠═5a408eeb-b636-4e90-b0f7-4cfa428baf6f
# ╠═005bf7d6-d79c-4684-a983-7a3191b103a7
# ╠═4c61150c-5936-4c42-b52a-250684e0d5b6
# ╠═536be535-f81b-420e-a705-f36e70c1fe81
# ╠═230faad3-be42-4fb4-977f-febffa92cc00
# ╠═30ecd476-2ee2-488f-ba9c-97ce0008a035
# ╠═55740c6c-bd5f-4257-9ffd-ae3b4f16147e
# ╠═6e91f158-6efb-4eb0-bac0-712a16c6f76c
# ╠═a9e0e8b4-f59a-4e6a-9b94-1affa835cb94
# ╠═7791c8da-7228-47a2-a489-62274b600766
# ╠═571158f3-7146-4bb5-bc0f-3ee7309d8dfc
# ╠═890a9fec-8dfe-4fa2-9db8-2a5ed7fa3085
# ╠═3cc3b0c6-647e-42d6-b0ec-959ce240d658
# ╠═1f9311ac-382b-46d0-a413-08c25f63d71f
# ╠═c4673e66-89d8-472d-bfc4-3b70dcc0e3c2
# ╠═2f6d9a61-940b-41f6-970f-78cb9c9dd4e4
# ╠═7cdafb01-c5df-4216-9699-a6e8bac11403
# ╠═58eef354-ab61-42bc-bed0-144f26bb8514
# ╠═80c35d84-506a-4b6a-8bad-acd936a08f75
# ╠═3b5b99b9-27eb-4050-9f3a-f0f28fba9420
# ╠═31fb95d4-be42-492a-9b62-dccfc6abdd8b
# ╠═ea0331c7-d113-4bb9-9de2-6ccb7925340b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
