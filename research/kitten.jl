### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 069dcc50-a528-11ed-0a6a-09521fd1a9a2
abstract type 𝔽 end

# ╔═╡ 293aa311-1165-466c-b02c-e75420369fa6
begin

struct Vec𝔽 <: 𝔽
  elems::Set{Any}
end

Base.:(∈)(a, A::Vec𝔽) = a ∈ A.elems
Base.:(==)(A::Vec𝔽, B::Vec𝔽) = issetequal(A.elems, B.elems)
	
Base.iterate(A::Vec𝔽) = iterate(A.elems)
Base.iterate(A::Vec𝔽, k) = iterate(A.elems, k)

end

# ╔═╡ 24242f3c-80bc-4c66-abf5-589a2491ea1a
begin
	
struct 𝔽Mor
  dom::𝔽
  codom::𝔽
  vals::Dict{Any,Any}
end
(f::𝔽Mor)(x) = f.vals[x]
	
end

# ╔═╡ 853986e3-403a-466f-ac41-4e6bb76ca2d9
isvalid(f::𝔽Mor) =
  all(x ∈ keys(f.vals) && f(x) ∈ f.codom for x ∈ f.dom)

# ╔═╡ 1716c47a-cf26-44bd-becd-6d715214d45f
A = Vec𝔽(Set((:carrots, :peas)))

# ╔═╡ c5614c33-db01-4a1a-aa9f-07b050859277
B = Vec𝔽(Set((3, 7, 8)))

# ╔═╡ 516dfa76-9bae-468f-b638-4492f4364fb1
f1 = 𝔽Mor(A, B, Dict(:carrots => 3, :peas => 3))

# ╔═╡ cedf5619-7e54-403a-a1d4-da8c27997fbf
isvalid(f1)

# ╔═╡ 5b2d9440-822d-4e21-9f03-a5cb78cafdd8
f1(:carrots)

# ╔═╡ d1233a54-fa1b-41c1-93e0-a4fd607ac275
f1(:peas)

# ╔═╡ 78a4effa-3263-4d46-8e09-591381df3fe4
isvalid(𝔽Mor(A, B, Dict(:peas => 3)))

# ╔═╡ 5550d2d8-79c0-4a87-a8b0-906c8c969807
isvalid(𝔽Mor(A, B, Dict(:peas => 8, :carrots => 3)))

# ╔═╡ 69792f22-8e0b-465c-9688-fa813c457374
function compose(g::𝔽Mor, f::𝔽Mor)
  @assert f.codom == g.dom
  𝔽Mor(f.dom, g.codom, Dict(a => g(f(a)) for a in f.dom))
end

# ╔═╡ 5b1fad49-b460-4be4-a63b-921b0fbde1e9
A1,B1,C1 = Vec𝔽(Set((1,2,3))), Vec𝔽(Set((:a,:b))), Vec𝔽(Set(("s", "t")))

# ╔═╡ e6a991b8-0fc6-4bd2-859f-58da9a87d2f4
f = 𝔽Mor(A1,B1,Dict(1=>:a,2=>:a,3=>:b))

# ╔═╡ 429db204-b601-49ff-be5c-db31decc9df5
g = 𝔽Mor(B1,C1,Dict(:a=>"t",:b=>"s"))

# ╔═╡ 048a5387-2aee-455c-9584-ed40c5d13bf5
compose(g, f)

# ╔═╡ fbbe1a36-971c-4650-ba1d-2daada265cd4
compose(g, f).vals

# ╔═╡ 0e8d02c7-20fa-47b4-987e-c2141f9aa7cc
let
	A, A′ = Vec𝔽(Set((1,2,3,3))), Vec𝔽(Set((3,2,1)))
	A == A′
end

# ╔═╡ 4793e974-d0cd-4b6d-b3d4-92fe6ce13c8a


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
# ╠═069dcc50-a528-11ed-0a6a-09521fd1a9a2
# ╠═293aa311-1165-466c-b02c-e75420369fa6
# ╠═24242f3c-80bc-4c66-abf5-589a2491ea1a
# ╠═853986e3-403a-466f-ac41-4e6bb76ca2d9
# ╠═1716c47a-cf26-44bd-becd-6d715214d45f
# ╠═c5614c33-db01-4a1a-aa9f-07b050859277
# ╠═516dfa76-9bae-468f-b638-4492f4364fb1
# ╠═cedf5619-7e54-403a-a1d4-da8c27997fbf
# ╠═5b2d9440-822d-4e21-9f03-a5cb78cafdd8
# ╠═d1233a54-fa1b-41c1-93e0-a4fd607ac275
# ╠═78a4effa-3263-4d46-8e09-591381df3fe4
# ╠═5550d2d8-79c0-4a87-a8b0-906c8c969807
# ╠═69792f22-8e0b-465c-9688-fa813c457374
# ╠═5b1fad49-b460-4be4-a63b-921b0fbde1e9
# ╠═e6a991b8-0fc6-4bd2-859f-58da9a87d2f4
# ╠═429db204-b601-49ff-be5c-db31decc9df5
# ╠═048a5387-2aee-455c-9584-ed40c5d13bf5
# ╠═fbbe1a36-971c-4650-ba1d-2daada265cd4
# ╠═0e8d02c7-20fa-47b4-987e-c2141f9aa7cc
# ╠═4793e974-d0cd-4b6d-b3d4-92fe6ce13c8a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
