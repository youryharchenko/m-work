### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 81a02bca-aae1-11ed-1559-993b711a915a
using Statistics

# ╔═╡ a52d1b07-490a-4060-ac08-6bc88a549d12
using IterTools

# ╔═╡ 7c94bea4-977f-4339-9148-483441f89b1a
using FileIO

# ╔═╡ ddbde0c0-6e56-4af4-bd02-9f39953a4613
using JSON

# ╔═╡ 1e2145af-1716-4f51-a29c-c9290789bbb8
using PyCall, JLD2, CUDA

# ╔═╡ 81340365-32ad-4f81-a646-203b3c0cca5d
using Knet: Knet, AutoGrad, RNN, param, dropout, minibatch, nll, accuracy, progress!, adam, gc

# ╔═╡ 6d169c47-9a32-44b9-8b4d-703f0f5de708
ENV["COLUMNS"] = 72

# ╔═╡ 4ad0e8d0-43c8-402a-8f0b-afcd4d5daeb5
begin
	EPOCHS=3          # Number of training epochs
	BATCHSIZE=64      # Number of instances in a minibatch
	EMBEDSIZE=125     # Word embedding size
	NUMHIDDEN=100     # Hidden layer size
	MAXLEN=150        # maximum size of the word sequence, pad shorter sequences, truncate longer ones
	VOCABSIZE=30000   # maximum vocabulary size, keep the most frequent 30K, map the rest to UNK token
	NUMCLASS=2        # number of output classes
	DROPOUT=0.5       # Dropout rate
	LR=0.001          # Learning rate
	BETA_1=0.9        # Adam optimization parameter
	BETA_2=0.999      # Adam optimization parameter
	EPS=1e-08         # Adam optimization parameter
end

# ╔═╡ 7afc967f-ce56-401a-ba6d-25b8afc3b862
dir = Knet.dir("data","imdb.jl")

# ╔═╡ 8eaf2ca2-8b44-4b77-8ca5-263c9abda67a
begin

struct SequenceClassifier 
	input 
	rnn 
	output 
	pdrop 
end

SequenceClassifier(input::Int, embed::Int, hidden::Int, output::Int; pdrop=0) =
	SequenceClassifier(param(embed,input), RNN(embed,hidden,rnnType=:gru), param(output,hidden), pdrop)

function (sc::SequenceClassifier)(input)
    embed = sc.input[:, permutedims(hcat(input...))]
    embed = dropout(embed,sc.pdrop)
    hidden = sc.rnn(embed)
    hidden = dropout(hidden,sc.pdrop)
    return sc.output * hidden[:,:,end]
end

(sc::SequenceClassifier)(input,output) = nll(sc(input),output)
end

# ╔═╡ 3a3e1942-1caf-4b55-8ef0-a46b519425d1
maker() = SequenceClassifier(VOCABSIZE, EMBEDSIZE, NUMHIDDEN, NUMCLASS, pdrop=DROPOUT)

# ╔═╡ b0fb0201-432a-4d27-aa03-a15d092160c1
UNK = VOCABSIZE-2

# ╔═╡ 9e82f073-baa8-4b2c-95ea-c74d35b71c61
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end


# ╔═╡ 52e79ec4-d231-4393-a17c-b0ea3161ff7d
imdb = ingredients(dir)

# ╔═╡ 2f2ebdbf-dd73-4d30-92ca-95aef11113d5
(xtrn,ytrn,xtst,ytst,imdbdict) = imdb.imdb(maxlen=MAXLEN, maxval=VOCABSIZE)

# ╔═╡ 07d0f067-315a-4acd-8b68-6f4761d0a692
summary.((xtrn,ytrn,xtst,ytst,imdbdict))

# ╔═╡ 00f4d1d9-1938-43b3-ad45-ae99e805987e
rand(xtrn)'

# ╔═╡ ed9a5538-59f4-41d4-bfa0-489504c6c021
length.(xtrn)'

# ╔═╡ 47f333c8-a6b9-4292-9f8c-1a4bbca340d6
begin
	imdbvocab = Array{String}(undef,length(imdbdict))
	
	for (k,v) in imdbdict
		imdbvocab[v]=k 
	end
	
	imdbvocab[VOCABSIZE-2:VOCABSIZE] = ["","",""]
	
	function reviewstring(x, y=0)
    	x = x[x.!=VOCABSIZE] # remove pads
    	"""$(("Sample", "Negative", "Positive")[y+1])\n$(join(imdbvocab[x], " "))"""
	end
end

# ╔═╡ 80838422-3001-4e98-b230-da29e3699787
let
	r = rand(1:length(xtrn))
	reviewstring(xtrn[r], ytrn[r])
end

# ╔═╡ 6391c09b-d3af-4567-acdd-94b57be66642
ytrn'

# ╔═╡ 04c5c368-d93c-41e7-88d4-0ec2eda055d0
dtrn = minibatch(xtrn, ytrn, BATCHSIZE; shuffle=true)     

# ╔═╡ 01e8f135-5fb8-4037-95bc-20864db96659
function trainresults(file, maker, scratch=true ; o...)
    if scratch == true
        model = maker()
        progress!(adam(model, ncycle(dtrn, EPOCHS); lr=LR, beta1=BETA_1, beta2=BETA_2, eps=EPS))
        save(file,"model", model)
        GC.gc(true) # To save gpu memory
    else
        isfile(file) || download("https://github.com/denizyuret/Knet.jl/releases/download/v1.4.9/$file", file)
        model = load(file,"model")
    end
    return model
end

# ╔═╡ 04a96dc1-de47-4328-a86c-7269a846b0ea
begin
	CUDA.allowscalar(true)
	model = trainresults("imdbmodel149.jld2", maker, true)
end

# ╔═╡ c886c41c-73d4-4e7e-a779-946e39228bad
predictstring(x) = "\nPrediction: " * ("Negative","Positive")[argmax(Array(vec(model([x]))))]

# ╔═╡ b9e1356a-7525-48bd-8f50-1365aad86412
dtst = minibatch(xtst, ytst, BATCHSIZE)

# ╔═╡ 82025e4d-7f0f-44b4-9ac4-a23641c140c5
str2ids(s::String) = [(i=get(imdbdict, w, UNK); i >= UNK ? UNK : i) for w in split(lowercase(s))]

# ╔═╡ 4a1fee6c-767f-42a8-bb94-fb3be510cedd
predictstring(str2ids("very good"))

# ╔═╡ e7b0fa31-a952-4167-874e-e169345bd6a5
predictstring(str2ids("very bad"))

# ╔═╡ 138bf5a3-fe1e-41df-97a8-c73e340e6fb6
let
	r = rand(1:length(xtst))
	Text(reviewstring(xtst[r], ytst[r]) * predictstring(xtst[r]))
end

# ╔═╡ 214a7ef3-ef2f-4120-9247-00a442db541b


# ╔═╡ 8a61f3ac-978c-4f5f-b5db-e2fd1882e692


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
IterTools = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
JLD2 = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
Knet = "1902f260-5fb4-5aff-8c31-6271790ab950"
PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
CUDA = "~3.13.1"
FileIO = "~1.16.0"
IterTools = "~1.4.0"
JLD2 = "~0.4.30"
JSON = "~0.21.3"
Knet = "~1.4.10"
PyCall = "~1.95.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "5fcc7ff33371fb4a84f041aa5a668e76e0bf0c71"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "0310e08cb19f5da31d08341c6120c047598f5b9c"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.5.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AutoGrad]]
deps = ["Libdl", "LinearAlgebra", "SpecialFunctions", "Statistics", "TimerOutputs"]
git-tree-sha1 = "0f97c20e513d18e9c0d8f58e1b6eb0e288249832"
uuid = "6710c13c-97f1-543f-91c5-74e8f7d95b35"
version = "1.2.5"

[[deps.BFloat16s]]
deps = ["LinearAlgebra", "Printf", "Random", "Test"]
git-tree-sha1 = "a598ecb0d717092b5539dbbe890c98bac842b072"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.2.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CompilerSupportLibraries_jll", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions", "TimerOutputs"]
git-tree-sha1 = "6717cb9a3425ebb7b31ca4f832823615d175f64a"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "3.13.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "844b061c104c408b24537482469400af6075aae4"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.5"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "61fdd77467a5c3ad071ef8277ac6bd6af7dd4c04"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "e32a90da027ca45d84678b826fffd3110bb3fc90"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.8.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.GPUArrays]]
deps = ["Adapt", "GPUArraysCore", "LLVM", "LinearAlgebra", "Printf", "Random", "Reexport", "Serialization", "Statistics"]
git-tree-sha1 = "4dfaff044eb2ce11a897fecd85538310e60b91e6"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "8.6.2"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "57f7cde02d7a53c9d1d28443b9f11ac5fbe7ebc9"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.3"

[[deps.GPUCompiler]]
deps = ["ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "95185985a5d2388c6d0fedb06181ad4ddd40e0cb"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.17.2"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "43ba3d3c82c18d88471cfd2924931658838c9d8f"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.0+4"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils", "Libdl", "Pkg", "Random"]
git-tree-sha1 = "5bc1cb62e0c5f1005868358db0692c994c3a13c6"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.1"

[[deps.ImageMagick_jll]]
deps = ["Artifacts", "Ghostscript_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "124626988534986113cfd876e3093e4a03890f58"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.12+3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "c3244ef42b7d4508c638339df1bdbf4353e144db"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.30"

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

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.Knet]]
deps = ["AutoGrad", "CUDA", "FileIO", "ImageCore", "ImageMagick", "JLD2", "Libdl", "LinearAlgebra", "NNlib", "Pkg", "Printf", "Random", "Serialization", "SpecialFunctions", "Statistics"]
git-tree-sha1 = "b1874af1797705ae47773c2c7aa1ad4aad76dd1e"
uuid = "1902f260-5fb4-5aff-8c31-6271790ab950"
version = "1.4.10"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "df115c31f5c163697eede495918d8e85045c8f04"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "4.16.0"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg", "TOML"]
git-tree-sha1 = "771bfe376249626d3ca12bcd58ba243d3f961576"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.16+0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "680e733c3a0a9cea9e935c8c2184aea6a63fa0b5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.21"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NNlib]]
deps = ["Adapt", "ChainRulesCore", "LinearAlgebra", "Pkg", "Random", "Requires", "Statistics"]
git-tree-sha1 = "ddf38a5d9140bc8c08ea6158484a455ca3efdd2d"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.8.18"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "82d7c9e310fe55aa54996e6f7f94674e2a38fcb4"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.9"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "946b56b2135c6c10bbb93efad8a78b699b6383ab"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.6"

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

[[deps.PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "62f417f6ad727987c755549e9cd88c46578da562"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.95.1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Random123]]
deps = ["Random", "RandomNumbers"]
git-tree-sha1 = "7a1a306b72cfa60634f03a911405f4e64d1b718b"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.6.0"

[[deps.RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

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

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

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

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f2fd3f288dfc6f507b0c3a2eb3bac009251e548b"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.22"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

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
# ╠═81a02bca-aae1-11ed-1559-993b711a915a
# ╠═a52d1b07-490a-4060-ac08-6bc88a549d12
# ╠═7c94bea4-977f-4339-9148-483441f89b1a
# ╠═ddbde0c0-6e56-4af4-bd02-9f39953a4613
# ╠═1e2145af-1716-4f51-a29c-c9290789bbb8
# ╠═81340365-32ad-4f81-a646-203b3c0cca5d
# ╠═6d169c47-9a32-44b9-8b4d-703f0f5de708
# ╠═4ad0e8d0-43c8-402a-8f0b-afcd4d5daeb5
# ╠═7afc967f-ce56-401a-ba6d-25b8afc3b862
# ╠═52e79ec4-d231-4393-a17c-b0ea3161ff7d
# ╠═2f2ebdbf-dd73-4d30-92ca-95aef11113d5
# ╠═07d0f067-315a-4acd-8b68-6f4761d0a692
# ╠═00f4d1d9-1938-43b3-ad45-ae99e805987e
# ╠═ed9a5538-59f4-41d4-bfa0-489504c6c021
# ╠═47f333c8-a6b9-4292-9f8c-1a4bbca340d6
# ╠═80838422-3001-4e98-b230-da29e3699787
# ╠═6391c09b-d3af-4567-acdd-94b57be66642
# ╠═8eaf2ca2-8b44-4b77-8ca5-263c9abda67a
# ╠═04c5c368-d93c-41e7-88d4-0ec2eda055d0
# ╠═b9e1356a-7525-48bd-8f50-1365aad86412
# ╠═01e8f135-5fb8-4037-95bc-20864db96659
# ╠═3a3e1942-1caf-4b55-8ef0-a46b519425d1
# ╠═04a96dc1-de47-4328-a86c-7269a846b0ea
# ╠═c886c41c-73d4-4e7e-a779-946e39228bad
# ╠═b0fb0201-432a-4d27-aa03-a15d092160c1
# ╠═82025e4d-7f0f-44b4-9ac4-a23641c140c5
# ╠═138bf5a3-fe1e-41df-97a8-c73e340e6fb6
# ╠═4a1fee6c-767f-42a8-bb94-fb3be510cedd
# ╠═e7b0fa31-a952-4167-874e-e169345bd6a5
# ╠═9e82f073-baa8-4b2c-95ea-c74d35b71c61
# ╠═214a7ef3-ef2f-4120-9247-00a442db541b
# ╠═8a61f3ac-978c-4f5f-b5db-e2fd1882e692
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
