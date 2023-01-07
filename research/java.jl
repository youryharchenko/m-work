### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ b56b580f-bc9b-4c20-9d9b-da35cf387104
using JavaCall

# ╔═╡ 533cd6ef-b2a4-4b63-9c49-5de1a066044a
dir = "/home/youry/Projects/lucene-9.4.2/modules"

# ╔═╡ 87c22bf6-f420-45ee-991f-af4e067116fc
jars = [
	"lucene-core-9.4.2.jar",
	"lucene-queryparser-9.4.2.jar",
	"lucene-analysis-common-9.4.2.jar",
	"lucene-demo-9.4.2.jar",
]

# ╔═╡ daa7b708-316f-4140-b0fb-b08a7b491592
cp = join([joinpath(dir, jar) for jar in jars], ":")

# ╔═╡ 8d9ea2be-89d9-4fa1-8cb9-8d20f9093a6e
JavaCall.init(["-Xmx128M", "-Djava.class.path=$cp"])

# ╔═╡ 250ba52a-69ba-4849-a715-fb458c707b9b
jlm = @jimport java.lang.Math

# ╔═╡ fd1b73a4-c3d6-4bfe-bfa2-4ba9d1da7239
jcall(jlm, "sin", jdouble, (jdouble,), pi/2)

# ╔═╡ 215c50a4-14ee-4097-aa3a-5d765cd44de3
jnu = @jimport java.net.URL

# ╔═╡ 383e2417-3931-4c04-baa1-fec5d81e765c
gurl = jnu((JString,), "http://www.google.com")

# ╔═╡ 1b4b9b64-2f6e-49d5-8e10-0761c26a88f0
jcall(gurl, "getHost", JString,())

# ╔═╡ a55d12bb-57de-4974-8d40-f4379edf1139
j_u_arrays = @jimport java.util.Arrays

# ╔═╡ 542336c9-3103-4ae7-9f80-eb7a71bf1b40
jcall(j_u_arrays, "binarySearch", jint, (Array{jint,1}, jint), [10,20,30,40,50,60], 40)

# ╔═╡ 1d02a2aa-15cf-4160-b46c-afa3fab25e99
index_file = @jimport org.apache.lucene.demo.IndexFiles

# ╔═╡ 6073d3ed-cabc-4fe4-8cca-5c167b61704c
jmethods = listmethods(index_file)

# ╔═╡ 2977f067-7d1a-4c33-9aab-db49f33d8a30
args = JString[]

# ╔═╡ 0675527f-9af5-4d41-a933-9e9e29e16e14
jcall(index_file, jmethods[1], args...)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
JavaCall = "494afd89-becb-516b-aafa-70d2670c0337"

[compat]
JavaCall = "~0.7.8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "e521f8165f68fd04ecc960d6efd5e3553d921b6c"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JavaCall]]
deps = ["DataStructures", "Dates", "Libdl", "WinReg"]
git-tree-sha1 = "2ca155cf69fe84e7c77992ce891f98fee93be834"
uuid = "494afd89-becb-516b-aafa-70d2670c0337"
version = "0.7.8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WinReg]]
deps = ["Test"]
git-tree-sha1 = "808380e0a0483e134081cc54150be4177959b5f4"
uuid = "1b915085-20d7-51cf-bf83-8f477d6f5128"
version = "0.3.1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"
"""

# ╔═╡ Cell order:
# ╠═b56b580f-bc9b-4c20-9d9b-da35cf387104
# ╠═533cd6ef-b2a4-4b63-9c49-5de1a066044a
# ╠═87c22bf6-f420-45ee-991f-af4e067116fc
# ╠═daa7b708-316f-4140-b0fb-b08a7b491592
# ╠═8d9ea2be-89d9-4fa1-8cb9-8d20f9093a6e
# ╠═250ba52a-69ba-4849-a715-fb458c707b9b
# ╠═fd1b73a4-c3d6-4bfe-bfa2-4ba9d1da7239
# ╠═215c50a4-14ee-4097-aa3a-5d765cd44de3
# ╠═383e2417-3931-4c04-baa1-fec5d81e765c
# ╠═1b4b9b64-2f6e-49d5-8e10-0761c26a88f0
# ╠═a55d12bb-57de-4974-8d40-f4379edf1139
# ╠═542336c9-3103-4ae7-9f80-eb7a71bf1b40
# ╠═1d02a2aa-15cf-4160-b46c-afa3fab25e99
# ╠═6073d3ed-cabc-4fe4-8cca-5c167b61704c
# ╠═2977f067-7d1a-4c33-9aab-db49f33d8a30
# ╠═0675527f-9af5-4d41-a933-9e9e29e16e14
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
