### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ e916006d-d1ac-455d-95b6-67c566e36d0f
using Word2Vec

# ╔═╡ bd5137f0-cc8a-11ed-3eaa-3f7d98b3ca8c
dir = "20_newsgroups"

# ╔═╡ d6d46abb-4ee1-434b-ba68-7e95845ab3b3
texts, labels_index, labels, label_text = let

texts = []         # list of text samples
labels_index = Dict()  # dictionary mapping label name to numeric id
labels = []        # list of label ids
label_text = []    # list of label texts
	
len = length
	
for name in sort(readdir(dir))
    path = joinpath(dir, name)
    if isdir(path)
        label_id = len(labels_index) + 1
        labels_index[name] = label_id
        for fname in sort(readdir(path))
            # News groups posts are named as numbers, with no extensions.
            if all(isdigit, fname)
                fpath = joinpath(path, fname)
                open(fpath) do f # , encoding="latin-1"
                	t = read(f, String)
                	i = findfirst("\n\n", t)  # skip header in file (starts with two newlines.)
                	if !isnothing(i)
                    	t = t[i[1]:end]
					end
                	push!(texts, t)
				end
                push!(labels, label_id)
                push!(label_text, name)
			end
		end
	end
end

for ii in eachindex(texts)
	sentences = []
	for x in split(texts[ii], ("\n"))
		if !endswith(x, "writes:")
			s = replace(x, r"[\!\"#$%&\*+,-./:;<=>?@^_`()|~=]" => "")
			s = strip(s)
			s = split(s, " ")
			push!(sentences, s)
		end
	end
    texts[ii] = [x for x in sentences if x != [""]]
  
end
	
texts, labels_index, labels, label_text
end

# ╔═╡ 3313aea4-838f-48ac-bccb-a45839a564a0
labels

# ╔═╡ bfa9fbd9-f524-4434-9e66-72b61a3067ed
labels_index

# ╔═╡ 01add470-acb8-493f-b80e-fc4dc2030d6f
label_text

# ╔═╡ 016a45e0-fc32-4611-ae89-395974529e2a
texts

# ╔═╡ 3df05892-00d0-4c19-897a-da324177e8e4
begin
all_sentences = []
for text in texts
	append!(all_sentences, text)
end
end

# ╔═╡ 785459d5-9b2d-4ec0-acf3-a9d4948949bc
all_sentences

# ╔═╡ 1c4660a9-e6b8-408e-bd2d-d861e7b37b13
open("news.txt", "w") do f
	for sen in all_sentences
		for w in sen
			if all(isdigit, w) ; continue; end
				
			try
				w = lowercase(w)
			catch e
				println(e)
			end
			print(f, "$(w) ")
		end
	end
end

# ╔═╡ c11bc228-9cd6-495c-a88c-eee3d3064a05
begin
	word2phrase("news.txt", "news_phrase")
	word2vec("news_phrase", "news_phrase-vec.txt", verbose=true, size=200, iter=30, min_count=3)
end

# ╔═╡ 5f36764d-91b9-4d41-9fd9-b85cd90ab679
model = wordvectors("news_phrase-vec.txt")

# ╔═╡ effee681-b51e-449e-a32b-4b921f023caf
size(model)

# ╔═╡ 7460919e-40d6-4718-aa0d-ae04d7759ac9
words = vocabulary(model)

# ╔═╡ ad102cea-4b2c-43e4-8a58-5d9314fff09c
cosine_similar_words(model, "los_angeles", 10)

# ╔═╡ 04f5534b-214a-47f2-9098-23096f3d5330
cosine_similar_words(model, "new_york", 10)

# ╔═╡ a8b869e4-1f89-470d-96a8-50212e380c73
cosine_similar_words(model, "oil", 10)

# ╔═╡ a8032bb8-a786-4888-ba55-6f48277f0371
cosine_similar_words(model, "human", 10)

# ╔═╡ 014a883b-7a74-45e3-8cb6-0eb44d99a539
analogy_words(model,  ["god"], [], 10)

# ╔═╡ 942fc2bc-4efb-400e-adda-a19d09eb509f
analogy_words(model,  ["god", "man"], [], 10)

# ╔═╡ cdf87a29-23b1-41b2-8a73-2403e9401604
analogy_words(model,  ["india", "gods"], [], 10)

# ╔═╡ e1921540-4ad5-47e2-b55c-23ccd60baaaa
analogy_words(model,  ["king", "woman"], ["man"], 10)

# ╔═╡ 54315015-6734-47d4-accb-779c64231a7f
analogy_words(model,  ["paris", "germany"], ["france"], 10)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Word2Vec = "c64b6f0f-98cd-51d1-af78-58ae84944834"

[compat]
Word2Vec = "~0.5.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "46bc954cff2a4176b1beb0a47e41b051f50d40ea"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

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

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Word2Vec]]
deps = ["LinearAlgebra", "Statistics", "Word2Vec_jll"]
git-tree-sha1 = "a4e76aeaaf2bda1556864b610051960cea642958"
uuid = "c64b6f0f-98cd-51d1-af78-58ae84944834"
version = "0.5.3"

[[deps.Word2Vec_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "264768df753f8328295d7b7cff55edc52f180284"
uuid = "9fbe4022-c126-5389-b4b2-756cc9f654d0"
version = "0.1.0+0"

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
# ╠═e916006d-d1ac-455d-95b6-67c566e36d0f
# ╠═bd5137f0-cc8a-11ed-3eaa-3f7d98b3ca8c
# ╠═d6d46abb-4ee1-434b-ba68-7e95845ab3b3
# ╠═3313aea4-838f-48ac-bccb-a45839a564a0
# ╠═bfa9fbd9-f524-4434-9e66-72b61a3067ed
# ╠═01add470-acb8-493f-b80e-fc4dc2030d6f
# ╠═016a45e0-fc32-4611-ae89-395974529e2a
# ╠═3df05892-00d0-4c19-897a-da324177e8e4
# ╠═785459d5-9b2d-4ec0-acf3-a9d4948949bc
# ╠═1c4660a9-e6b8-408e-bd2d-d861e7b37b13
# ╠═c11bc228-9cd6-495c-a88c-eee3d3064a05
# ╠═5f36764d-91b9-4d41-9fd9-b85cd90ab679
# ╠═effee681-b51e-449e-a32b-4b921f023caf
# ╠═7460919e-40d6-4718-aa0d-ae04d7759ac9
# ╠═ad102cea-4b2c-43e4-8a58-5d9314fff09c
# ╠═04f5534b-214a-47f2-9098-23096f3d5330
# ╠═a8b869e4-1f89-470d-96a8-50212e380c73
# ╠═a8032bb8-a786-4888-ba55-6f48277f0371
# ╠═014a883b-7a74-45e3-8cb6-0eb44d99a539
# ╠═942fc2bc-4efb-400e-adda-a19d09eb509f
# ╠═cdf87a29-23b1-41b2-8a73-2403e9401604
# ╠═e1921540-4ad5-47e2-b55c-23ccd60baaaa
# ╠═54315015-6734-47d4-accb-779c64231a7f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
