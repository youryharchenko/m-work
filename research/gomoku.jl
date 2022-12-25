### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 33ad9164-8438-11ed-22ca-9b5cdf37f99b
using Julog

# ╔═╡ 0b8580ac-ef11-4aaa-add8-568eb5603a51
xs = [ @julog(x($i)<<=true) for i in 1:15]

# ╔═╡ 48df9293-5959-4165-b99a-ffbccd36ca20
ys = [ @julog(y($i)<<=true) for i in 1:15]

# ╔═╡ f837a6d1-ecde-4306-9d1d-6479dfc99b2a
cs = [ @julog(cs($c)<<=true) for c in [:b, :w]]

# ╔═╡ 8cd2833e-1a70-47fa-8f0c-f487b60e9b49
facts = @julog [
	step(1, p(8, 8)) <<= true,
	step(2, p(8, 9)) <<= true,
	step(3, p(9, 9)) <<= true,
	step(4, p(10, 9)) <<= true,
]

# ╔═╡ c0d30a3e-2b66-4ac1-8780-0cb45c2d60fa
rules = @julog [
	# odd(N) <<= is(R, N % 2) & (R == 0) 
	# chX(X) <<= x(X),
	# chY(Y) <<= y(Y),
	chN(N) <<= and(N > 0, N < 226),
	c(N, b) <<= chN(N) & is(R, N % 2) & (R != 0),
	c(N, w) <<= chN(N) & is(R, N % 2) & (R == 0),
	c(N, errN) <<= not(chN(N)),

	# desk(X, Y, C) <<= x(X) & y(Y) & pos(X, Y, C),

	pos(X, Y, e) <<= x(X) & y(Y) & not(step(N, p(X, Y))),
	pos(X, Y, C) <<= x(X) & y(Y) & step(N, p(X, Y)) & c(N, C),
	
	point(X, Y, C) <<= pos(X, Y, C),

	slot(X, Y, h, [p(X, Y), p(X1, Y), p(X2, Y), p(X3, Y), p(X4, Y),]) <<= point(X, Y, _) & is(X1, X+1) & x(X1) & is(X2, X+2) & x(X2) & is(X3, X+3) & x(X3) & is(X4, X+4) & x(X4),
	slot(X, Y, v, [p(X, Y), p(X, Y1), p(X, Y2), p(X, Y3), p(X, Y4),]) <<= point(X, Y, _) & is(Y1, Y+1) & y(Y1) & is(Y2, Y+2) & y(Y2) & is(Y3, Y+3) & y(Y3) & is(Y4, Y+4) & y(Y4),
	slot(X, Y, u, [p(X, Y), p(X1, Y1), p(X2, Y2), p(X3, Y3), p(X4, Y4),]) <<= point(X, Y, _) & is(X1, X+1) & x(X1) & is(X2, X+2) & x(X2) & is(X3, X+3) & x(X3) & is(X4, X+4) & x(X4) & is(Y1, Y+1) & y(Y1) & is(Y2, Y+2) & y(Y2) & is(Y3, Y+3) & y(Y3) & is(Y4, Y+4) & y(Y4),
	slot(X, Y, d, [p(X, Y), p(X1, Y1), p(X2, Y2), p(X3, Y3), p(X4, Y4),]) <<= point(X, Y, _) & is(X1, X+1) & x(X1) & is(X2, X+2) & x(X2) & is(X3, X+3) & x(X3) & is(X4, X+4) & x(X4) & is(Y1, Y-1) & y(Y1) & is(Y2, Y-2) & y(Y2) & is(Y3, Y-3) & y(Y3) & is(Y4, Y-4) & y(Y4),

	op_c(b, w) <<= true, 
	op_c(w, b) <<= true, 

	has_c([C1, C2, C3, C4, C5], C) <<= or(C1 == C, C2 == C, C3 == C, C4 == C, C5 == C),

	# count(L, C, R) <<= 
	count([], _,  0) <<= true,
	count([X | T], X, N) <<= count(T, X, N1) & is(N, N1+1),
	count([X1 | T], X, N) <<= (X1 != X) & count(T, X, N),

	#slot_status([p(X1, Y1), p(X2, Y2), p(X3, Y3), p(X4, Y4), p(X5, Y5)], e) <<=
	#point(X1, Y1, C1) & point(X2, Y2, C2) & point(X3, Y3, C3) & point(X4, Y4, C4) & point(X5, Y5, C5) & and(C1 == e, C2 == e, C3 == e, C4 == e, C5 == e),

	slot_status([p(X1, Y1), p(X2, Y2), p(X3, Y3), p(X4, Y4), p(X5, Y5)], e, 0) <<=
	point(X1, Y1, C1) & point(X2, Y2, C2) & point(X3, Y3, C3) & point(X4, Y4, C4) & point(X5, Y5, C5) & unifies(L, [C1, C2, C3, C4, C5]) & has_c(L, e) & not(has_c(L, b)) & not(has_c(L, w)),

	slot_status([p(X1, Y1), p(X2, Y2), p(X3, Y3), p(X4, Y4), p(X5, Y5)], f, -1) <<=
	point(X1, Y1, C1) & point(X2, Y2, C2) & point(X3, Y3, C3) & point(X4, Y4, C4) & point(X5, Y5, C5) & unifies(L, [C1, C2, C3, C4, C5]) & has_c(L, b) & has_c(L, w),

	slot_status([p(X1, Y1), p(X2, Y2), p(X3, Y3), p(X4, Y4), p(X5, Y5)], C, R) <<=
	cs(C) & point(X1, Y1, C1) & point(X2, Y2, C2) & point(X3, Y3, C3) & point(X4, Y4, C4) & point(X5, Y5, C5) & unifies(L, [C1, C2, C3, C4, C5]) & has_c(L, C) & op_c(C, OC) & not(has_c(L, OC)) & count(L, C, R),
]

# ╔═╡ 248cfc8e-3368-4604-8ba7-3e85705f9db0
funcs = Dict(
	:% => (%),
	#:+ => (+),
)

# ╔═╡ a6bd751a-2925-4122-891b-ff6abab6b782
clauses = [xs; ys; cs; facts; rules]

# ╔═╡ 9de4f1c0-fa22-42ef-b900-81d6ee5bc14e
resolve(@julog([count([b, a, b], b, R)]), clauses, funcs = funcs)

# ╔═╡ ed3f026a-da29-4be0-925a-27e9a23588d9
resolve(@julog([point(X, Y, C)]), clauses, funcs = funcs)

# ╔═╡ 8f25b412-555c-4c0e-96ff-ecfaf4d5aacc
resolve(@julog([slot(X, Y, h, PS)]), clauses, funcs = funcs)

# ╔═╡ b95cabcb-462f-456f-8766-b18ae23d957d
resolve(@julog([slot(X, Y, v, PS)]), clauses, funcs = funcs)

# ╔═╡ 924f9b2e-b62d-408a-adfc-2aaf7c006251
resolve(@julog([slot(X, Y, u, PS)]), clauses, funcs = funcs)

# ╔═╡ 3d1e8e6c-46b0-46ad-a081-0611dee54ad4
resolve(@julog([slot(X, Y, d, PS)]), clauses, funcs = funcs)

# ╔═╡ 86b0e421-4d77-4565-8d10-5ee41cb8763e
resolve(@julog([slot(X, Y, D, PS)]), clauses, funcs = funcs)

# ╔═╡ 7cecde9f-a57e-427b-84b5-155059039663
resolve(@julog([slot(X, Y, D, PS), slot_status(PS, e, R)]), clauses, funcs = funcs)

# ╔═╡ ccc14198-b02d-4cb5-8cba-62c5c0607f04
resolve(@julog([slot(X, Y, D, PS), slot_status(PS, b, R)]), clauses, funcs = funcs)

# ╔═╡ 4b9794d5-0765-4cc3-ab6a-b3b0da730f68
resolve(@julog([slot(X, Y, D, PS), slot_status(PS, w, R)]), clauses, funcs = funcs)

# ╔═╡ d40ba1ed-c86b-45ba-b69e-43134ceb8953
resolve(@julog([slot(X, Y, D, PS), slot_status(PS, f, R)]), clauses, funcs = funcs)

# ╔═╡ 85c33431-bb5d-4ceb-a93f-054580cd8281
resolve(@julog([slot(X, Y, D, PS), slot_status(PS, S, R)]), clauses, funcs = funcs)

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
project_hash = "70766b4fd54d420a6a0480e9e975f42d84503543"

[[deps.Julog]]
git-tree-sha1 = "191e4f6de2ddf2dc60d5d90c412d066814f1655b"
uuid = "5d8bcb5e-2b2c-4a96-a2b1-d40b3d3c344f"
version = "0.1.15"
"""

# ╔═╡ Cell order:
# ╠═33ad9164-8438-11ed-22ca-9b5cdf37f99b
# ╠═0b8580ac-ef11-4aaa-add8-568eb5603a51
# ╠═48df9293-5959-4165-b99a-ffbccd36ca20
# ╠═f837a6d1-ecde-4306-9d1d-6479dfc99b2a
# ╠═8cd2833e-1a70-47fa-8f0c-f487b60e9b49
# ╠═c0d30a3e-2b66-4ac1-8780-0cb45c2d60fa
# ╠═248cfc8e-3368-4604-8ba7-3e85705f9db0
# ╠═a6bd751a-2925-4122-891b-ff6abab6b782
# ╠═9de4f1c0-fa22-42ef-b900-81d6ee5bc14e
# ╠═ed3f026a-da29-4be0-925a-27e9a23588d9
# ╠═8f25b412-555c-4c0e-96ff-ecfaf4d5aacc
# ╠═b95cabcb-462f-456f-8766-b18ae23d957d
# ╠═924f9b2e-b62d-408a-adfc-2aaf7c006251
# ╠═3d1e8e6c-46b0-46ad-a081-0611dee54ad4
# ╠═86b0e421-4d77-4565-8d10-5ee41cb8763e
# ╠═7cecde9f-a57e-427b-84b5-155059039663
# ╠═ccc14198-b02d-4cb5-8cba-62c5c0607f04
# ╠═4b9794d5-0765-4cc3-ab6a-b3b0da730f68
# ╠═d40ba1ed-c86b-45ba-b69e-43134ceb8953
# ╠═85c33431-bb5d-4ceb-a93f-054580cd8281
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
