### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 559c4602-a3b2-11ed-04f9-1b67db6db381
using Catlab, Catlab.Theories, Catlab.Graphs, Catlab.CategoricalAlgebra, Catlab.Programs, Catlab.Graphics

# ╔═╡ 805daffe-a47b-42f4-bb33-a29f18cb579d
using JSON, JSONSchema

# ╔═╡ 8138665a-831f-43e4-9362-0f1cc23de457
acset_schema_json_schema()

# ╔═╡ f63d65f7-4542-4d88-b601-c89a3ef51d8f
json_schema = JSONSchema.Schema(acset_schema_json_schema())

# ╔═╡ 6a6d2792-bc1e-4d03-ade5-c4652f53bb54
JSON.print(json_schema, 2)

# ╔═╡ 914f2228-35be-483d-a08f-ccab702fd94b
@present SchDDS(FreeSchema) begin
  X::Ob
  next::Hom(X,X)
end

# ╔═╡ 92c73d19-32ee-4f3c-9616-8c19c1230d9f
SchDDS

# ╔═╡ b63eceff-4a6a-4947-a50b-cc3f48acfa62
generate_json_acset_schema(SchDDS)

# ╔═╡ 08f9714a-1412-422a-888b-62aea36ca837
to_graphviz(SchDDS)

# ╔═╡ ee33c4d2-5898-43cf-9c2e-3108461456ec
@present SchLabeledDDS <: SchDDS begin
  Label::AttrType
  label::Attr(X, Label)
end

# ╔═╡ 5185b19d-fd0f-44d6-bdfb-090967ff8105
to_graphviz(SchLabeledDDS)

# ╔═╡ 59efdb26-5c57-4a48-a85d-455022b76bd0
@acset_type LabeledDDS(SchLabeledDDS, index=[:next, :label])

# ╔═╡ 9951792f-15e1-4df3-afde-48d0f3d22c0d
ldds = LabeledDDS{Int}()

# ╔═╡ 840e2854-e8cc-4016-b7aa-8d9de3b93f0d
add_parts!(ldds, :X, 4, next=[2,3,4,1], label=[100, 101, 102, 103])

# ╔═╡ 0485e73d-994c-4ae5-afa3-6d618c55b2ff
generate_json_acset(ldds)

# ╔═╡ 3835f2c2-aa9b-4ff3-ba83-55ec4af2bd1b
generate_json_acset_schema(SchGraph)

# ╔═╡ 3bef3067-5b08-481c-9a86-4343f4c8cc53
to_graphviz(SchGraph)

# ╔═╡ 12f0b396-753f-4553-99f2-77e6056095c1
g = @acset Catlab.Graphs.Graph begin
  V = 4
  E = 4
  src=[1,2,4,4]
  tgt = [2,3,1,3]
end

# ╔═╡ 7fa0e074-5cf9-4174-b2e6-8344d328ff7a
generate_json_acset(g)

# ╔═╡ e84845fe-54a6-4763-85d4-eb4c613300c2
to_graphviz(g)

# ╔═╡ 4fd04603-868b-4acb-8bd7-a1a548312c3f
@present SchVELabeledGraph <: SchGraph begin
  Label::AttrType
  vlabel::Attr(V,Label)
  elabel::Attr(E,Label)
end


# ╔═╡ ab21d906-0edb-46c4-b3ba-616ced2fb036
to_graphviz(SchVELabeledGraph)

# ╔═╡ 07e10586-ca44-401d-bd90-dad5b1861dca
@acset_type VELabeledGraph(SchVELabeledGraph,
                           index=[:src,:tgt]) <: AbstractGraph

# ╔═╡ 67377a5d-2f8a-4245-9a7b-fc26c875add2
lg = @acset VELabeledGraph{Symbol} begin
  V = 4
  E = 2
  vlabel = [:a, :b, :c, :d]
  elabel = [:e₁, :e₂]
  src=[1,2]
  tgt = [2,3]
end

# ╔═╡ 53ed8d61-e8cc-4bf0-8953-09a851abf8fd
generate_json_acset(lg)

# ╔═╡ 704d8c6a-f457-472c-9e37-285dac72928b
to_graphviz(to_graphviz_property_graph(lg))

# ╔═╡ e4151d79-b48b-4d05-be68-78c61847601e
draw(d::Diagram) = to_graphviz(d, prog="neato", node_labels=true, edge_labels=true)

# ╔═╡ 7150187f-7522-41fd-93b5-60567f064317
D₂ = @free_diagram SchGraph begin
  v::V
  (e₁, e₂)::E
  tgt(e₁) == v
  src(e₂) == v
end


# ╔═╡ e0f98d69-297c-4849-a14d-f518cbb80f34
draw(D₂)

# ╔═╡ bbef2f24-9a59-41b3-8a2b-2e080e4d0b70
D₃ = @free_diagram SchGraph begin
  (v₁, v₂, v₃)::V
  (e₁, e₂, e₃)::E
  src(e₁) == v₁
  tgt(e₁) == v₂
  src(e₂) == v₂
  src(e₃) == v₁
  tgt(e₂) == v₃
  tgt(e₃) == v₃
end

# ╔═╡ 05ebeed5-787f-4e2c-a5a6-9a9fdd44a9ea
draw(D₃)

# ╔═╡ c6170f1b-3ed2-4e29-b7b3-b1faf7d1733b
@present 𝗖(FreeCartesianCategory) begin
  (A,B)::Ob
  f::Hom(A,A)
  g::Hom(A,B)
end

# ╔═╡ 5c2d065d-a800-4c66-841a-262056a6faf6
seq₃ = @free_diagram 𝗖 begin
  (a₀,a₁,a₂,a₃)::A
  a₁ == f(a₀)
  a₂ == f(a₁)
  a₃ == f(a₂)
end

# ╔═╡ 29be572e-9c28-4062-be69-316eda7628fc
draw(seq₃)

# ╔═╡ a515b305-37a8-4dcd-bb58-847e1fa72a64
obs_seq₃ = @free_diagram 𝗖 begin
  (a₀,a₁,a₂,a₃)::A
  (b₁, b₂, b₃ )::B
  a₁ == f(a₀)
  b₁ == g(a₁)
  a₂ == f(a₁)
  b₂ == g(a₂)
  a₃ == f(a₂)
  b₃ == g(a₃)
end

# ╔═╡ 8a69dec1-946b-47ad-8d38-99db66b5cf11
draw(obs_seq₃)

# ╔═╡ 833a2fdc-3029-441a-bbd5-ee4073d6b543
@present 𝐃(FreeCartesianCategory) begin
  (ℝ²,ℝ)::Ob
  f::Hom(ℝ²,ℝ²)
  π₁::Hom(ℝ²,ℝ)
end

# ╔═╡ ed8a573c-12a1-45ea-8b0c-5e1166d55457
fib_seq₃ = @free_diagram 𝐃 begin
  (a₀,a₁,a₂,a₃)::ℝ²
  (b₁, b₂, b₃ )::ℝ
  a₁ == f(a₀)
  b₁ == π₁(a₁)
  a₂ == f(a₁)
  b₂ == π₁(a₂)
  a₃ == f(a₂)
  b₃ == π₁(a₃)
end


# ╔═╡ 270fd322-0ee4-4192-af10-3c9c51c68294
draw(fib_seq₃)


# ╔═╡ 1434a509-6e73-4efe-b400-f12cdbcb8513
@present Analytic(FreeCartesianCategory) begin
  (ℝ,ℝ²)::Ob
  π₁::Hom(ℝ², ℝ)
  π₂::Hom(ℝ², ℝ)
  plus ::Hom(ℝ², ℝ)
  times::Hom(ℝ², ℝ)
  f    ::Hom(ℝ,ℝ)
  f′   ::Hom(ℝ,ℝ)
end

# ╔═╡ 003e3ba4-b07b-4650-96d9-017629062294
newtons = @free_diagram Analytic begin
  (xₖ, xₖ₊₁, dₖ, fx, v, ∏)::ℝ
  (p₁, p₂, p₃)::ℝ²
  dₖ  == f′(xₖ)
  π₁(p₁) == dₖ
  π₂(p₁) == xₖ₊₁
  ∏ == times(p₁)
  fx == f(xₖ)
  π₁(p₂) == ∏
  π₂(p₂) == fx
  plus(p₂) == v
  π₁(p₃) == dₖ
  π₂(p₃) == xₖ
  times(p₃) == v
end

# ╔═╡ cabf55a2-84a3-4b9c-ac2c-d88830fdd954
draw(newtons)


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Catlab = "134e5e36-593f-5add-ad60-77f754baafbe"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
JSONSchema = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"

[compat]
Catlab = "~0.14.14"
JSON = "~0.21.3"
JSONSchema = "~1.0.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "d8c3f7bf2fcfa48ab15dd1c04101e3376d5ad449"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Catlab]]
deps = ["Colors", "CompTime", "Compose", "DataStructures", "GeneralizedGenerated", "JSON", "LightXML", "LinearAlgebra", "Logging", "MLStyle", "Pkg", "PrettyTables", "Random", "Reexport", "Requires", "SparseArrays", "StaticArrays", "Statistics", "StructEquality", "Tables"]
git-tree-sha1 = "51a3fbc3f3b1d09e081bb682c440c76327a8c765"
uuid = "134e5e36-593f-5add-ad60-77f754baafbe"
version = "0.14.14"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.CompTime]]
deps = ["MLStyle", "MacroTools"]
git-tree-sha1 = "8c05059bc293a17f71cae4cd58b1fc18d4ede271"
uuid = "0fb5dd42-039a-4ca4-a1d7-89a96eae6d39"
version = "0.1.2"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "61fdd77467a5c3ad071ef8277ac6bd6af7dd4c04"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "d853e57661ba3a57abcdaa201f4c9917a93487a2"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.4"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.GeneralizedGenerated]]
deps = ["DataStructures", "JuliaVariables", "MLStyle", "Serialization"]
git-tree-sha1 = "60f1fa1696129205873c41763e7d0920ac7d6f1f"
uuid = "6b9d7cbe-bcb9-11e9-073f-15a7a543e2eb"
version = "0.3.3"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "37e4657cd56b11abe3d10cd4a1ec5fbdb4180263"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.7.4"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JSONSchema]]
deps = ["HTTP", "JSON", "URIs"]
git-tree-sha1 = "8d928db71efdc942f10e751564e6bbea1e600dfe"
uuid = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"
version = "1.0.1"

[[deps.JuliaVariables]]
deps = ["MLStyle", "NameResolution"]
git-tree-sha1 = "49fb3cb53362ddadb4415e9b73926d6b40709e70"
uuid = "b14d175d-62b4-44ba-8fb7-3064adc8c3ec"
version = "0.2.4"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.LightXML]]
deps = ["Libdl", "XML2_jll"]
git-tree-sha1 = "e129d9391168c677cd4800f5c0abb1ed8cb3794f"
uuid = "9c8b4983-aa76-5018-a973-4c85ecc9e179"
version = "0.9.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MLStyle]]
git-tree-sha1 = "060ef7956fef2dc06b0e63b294f7dbfbcbdc7ea2"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.16"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NameResolution]]
deps = ["PrettyPrint"]
git-tree-sha1 = "1a0fa0e9613f46c9b8c11eee38ebb4f590013c5e"
uuid = "71a1bf82-56d0-4bbc-8a3c-48b961074391"
version = "0.1.5"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "6503b77492fd7fcb9379bf73cd31035670e3c509"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "151d91d63d8d6c1a5789ecb7de51547e00480f1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.4"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyPrint]]
git-tree-sha1 = "632eb4abab3449ab30c5e1afaa874f0b98b586e4"
uuid = "8162dcfd-2161-5ef2-ae6c-7681170c5f98"
version = "0.2.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "96f6db03ab535bdb901300f88335257b0018689d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "6954a456979f23d05085727adb17c4551c19ecd1"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.12"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.StructEquality]]
deps = ["Compat"]
git-tree-sha1 = "192a9f1de3cfef80ab1a4ba7b150bb0e11ceedcf"
uuid = "6ec83bb0-ed9f-11e9-3b4c-2b04cb4e219c"
version = "2.1.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═559c4602-a3b2-11ed-04f9-1b67db6db381
# ╠═805daffe-a47b-42f4-bb33-a29f18cb579d
# ╠═8138665a-831f-43e4-9362-0f1cc23de457
# ╠═f63d65f7-4542-4d88-b601-c89a3ef51d8f
# ╠═6a6d2792-bc1e-4d03-ade5-c4652f53bb54
# ╠═914f2228-35be-483d-a08f-ccab702fd94b
# ╠═92c73d19-32ee-4f3c-9616-8c19c1230d9f
# ╠═b63eceff-4a6a-4947-a50b-cc3f48acfa62
# ╠═08f9714a-1412-422a-888b-62aea36ca837
# ╠═ee33c4d2-5898-43cf-9c2e-3108461456ec
# ╠═5185b19d-fd0f-44d6-bdfb-090967ff8105
# ╠═59efdb26-5c57-4a48-a85d-455022b76bd0
# ╠═9951792f-15e1-4df3-afde-48d0f3d22c0d
# ╠═840e2854-e8cc-4016-b7aa-8d9de3b93f0d
# ╠═0485e73d-994c-4ae5-afa3-6d618c55b2ff
# ╠═3835f2c2-aa9b-4ff3-ba83-55ec4af2bd1b
# ╠═3bef3067-5b08-481c-9a86-4343f4c8cc53
# ╠═12f0b396-753f-4553-99f2-77e6056095c1
# ╠═7fa0e074-5cf9-4174-b2e6-8344d328ff7a
# ╠═e84845fe-54a6-4763-85d4-eb4c613300c2
# ╠═4fd04603-868b-4acb-8bd7-a1a548312c3f
# ╠═ab21d906-0edb-46c4-b3ba-616ced2fb036
# ╠═07e10586-ca44-401d-bd90-dad5b1861dca
# ╠═67377a5d-2f8a-4245-9a7b-fc26c875add2
# ╠═53ed8d61-e8cc-4bf0-8953-09a851abf8fd
# ╠═704d8c6a-f457-472c-9e37-285dac72928b
# ╠═e4151d79-b48b-4d05-be68-78c61847601e
# ╠═7150187f-7522-41fd-93b5-60567f064317
# ╠═e0f98d69-297c-4849-a14d-f518cbb80f34
# ╠═bbef2f24-9a59-41b3-8a2b-2e080e4d0b70
# ╠═05ebeed5-787f-4e2c-a5a6-9a9fdd44a9ea
# ╠═c6170f1b-3ed2-4e29-b7b3-b1faf7d1733b
# ╠═5c2d065d-a800-4c66-841a-262056a6faf6
# ╠═29be572e-9c28-4062-be69-316eda7628fc
# ╠═a515b305-37a8-4dcd-bb58-847e1fa72a64
# ╠═8a69dec1-946b-47ad-8d38-99db66b5cf11
# ╠═833a2fdc-3029-441a-bbd5-ee4073d6b543
# ╠═ed8a573c-12a1-45ea-8b0c-5e1166d55457
# ╠═270fd322-0ee4-4192-af10-3c9c51c68294
# ╠═1434a509-6e73-4efe-b400-f12cdbcb8513
# ╠═003e3ba4-b07b-4650-96d9-017629062294
# ╠═cabf55a2-84a3-4b9c-ac2c-d88830fdd954
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
