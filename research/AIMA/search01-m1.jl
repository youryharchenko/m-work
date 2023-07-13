### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 9c8becae-9f28-411b-b351-73bdfc586a07
using DataStructures

# ╔═╡ ae467e1d-0887-4461-a72c-900997498c56
using Graphs, GraphPlot

# ╔═╡ 1c90223e-72ba-4054-8512-6e37e22da767
abstract type AbstractState end

# ╔═╡ 6df51de2-5a01-449a-ada9-3adb64b2813b
abstract type AbstractNode end

# ╔═╡ 5fb611fe-b9ea-4d3e-b0f8-eddb4e0f9b69
abstract type AbstractAction end

# ╔═╡ 7811a736-4116-40ec-a47d-539bc4659678
const ID = Union{Symbol, String, Int}

# ╔═╡ 21cc727a-1e58-11ee-1a11-f34307c928bf
@kwdef struct In <: AbstractState
	id::ID = nothing
end

# ╔═╡ 700aff0b-904e-4a34-883f-eba2249e80cb
isequal(in1::In, in2::In)::Bool = in1.id == in2.id


# ╔═╡ daa8c017-2170-421b-b4b0-46f6712a449a
@kwdef struct Go <: AbstractAction
	id::ID = nothing
end

# ╔═╡ 94f38634-78b0-4579-ac31-23cd27f293e7
@kwdef struct Node <: AbstractNode 
	state::Union{AbstractState, Nothing} = nothing
	parent::Union{AbstractNode, Nothing} = nothing
	action::Union{AbstractAction, Nothing} = nothing
	cost::Int = 0
	depth::Int = 0
end

# ╔═╡ 1bdfa350-4c08-4fa9-be8a-a92cb3c3f5f5
has_equal_states(n1::AbstractNode, n2::AbstractNode)::Bool = isequal(n1.state, n2.state)

# ╔═╡ 989946aa-106d-44a5-a674-05b6d3b36b85
@kwdef struct Result
	succ::Bool = false
	count::Int = 0
	solution = nothing
end

# ╔═╡ bfc8d89b-db80-4ba6-94c4-4491b54f8c6a
function summary(result::Result)
	(result.succ, result.count,
	[[n.action.id for n in s] for s in result.solution])
end

# ╔═╡ 176506d8-fa09-4511-8ab3-f19c350ae885
@kwdef struct Problem
	initial_state::AbstractState = nothing
	initial_action::AbstractAction = nothing
	goal::AbstractState = nothing
	graph::Dict = nothing
end

# ╔═╡ b51516db-a317-4b17-ac61-b22f2f8a9e96
function goal_test(problem, state)
	isequal(problem.goal, state)
end

# ╔═╡ 815acc89-6590-4153-92ac-82dde80653c5
function successors(problem, state)
	[(Go(id=s), In(id=s)) 
		for s in keys(problem.graph[state.id])]
end

# ╔═╡ ee04e931-26cf-4ec7-a403-db6983984e61
function make_solution(node)
	ret = []
	n = node
	while !isnothing(n)
		push!(ret, n)
		n = n.parent
	end
	reverse!(ret)
end

# ╔═╡ b2e140e7-8a3e-4765-8756-54962d16ca13
function can_cycle(node::AbstractNode)
	n = node.parent
	while !isnothing(n)
		if has_equal_states(node, n) #node.state.name == n.state.name
			return true
		end
		n = n.parent
	end
	false
end

# ╔═╡ 58ff17d7-d5ee-4bce-a94a-2ac45da07ad3
function expand(problem, node)
	filter((n)->!can_cycle(n), [Node(state=s[2], parent=node, action=s[1]) 
		for s in successors(problem, node.state)])
end

# ╔═╡ e871997b-84bf-4c48-bc33-8312f2195469


# ╔═╡ f15d6a76-637d-451f-b20e-fab74183de57
function tree_search(problem, n=1)
	fringe = Queue{Node}()
	#visited = []
	enqueue!(fringe, Node(state=problem.initial_state, action=problem.initial_action))
	solutions = []
	succ = false
	count = 1
	while !isempty(fringe)
		node = dequeue!(fringe)
		#push!(visited, node.state.name)
		if goal_test(problem, node.state)
			#return Result(solution=make_solution(node), succ=true)
			succ = true
			push!(solutions, make_solution(node))
			if count == n 
				break
			end
			count += 1
		end

		foreach((n)->enqueue!(fringe, n), expand(problem, node))
		#for n in expand(problem, node)
		#filter((n)->!(n.state.name in visited), expand(problem, node)) #"setdiff(expand(problem, node), visited)
		#	if !can_cycle(n)
		#		enqueue!(fringe, n)
		#	end
		#end
	end
	
	Result(succ=succ, count=length(solutions), solution=solutions)
	
end

# ╔═╡ 55f9b410-6fd9-452e-aa55-9afa855f3a70
q = Queue{Int}()

# ╔═╡ ec2ed73b-ca2d-4ba2-8a0a-a6d30c9705d7
enqueue!(q, 1)

# ╔═╡ f623dc6f-294b-45fa-8b22-5210d50f3367
isempty(q)

# ╔═╡ 147c9821-a587-471b-94c2-7c5aca5cf327
eltype(q)

# ╔═╡ 8242a749-2c59-4a59-afb8-660952a0017e
1 in q

# ╔═╡ ea5ed506-4462-43e7-beff-0b498eed9817
romania = Dict(
    	:A=>Dict(:Z=>75, :S=>140, :T=>118),
		:Z=>Dict(:A=>75, :O=>71),
		:S=>Dict(:A=>140, :F=>99, :R=>80, :O=>151),
		:T=>Dict(:A=>118, :L=>111),
		:O=>Dict(:Z=>71, :S=>151),
		:F=>Dict(:S=>99, :B=>211),
		:R=>Dict(:S=>80, :C=>146, :P=>97),
		:L=>Dict(:T=>111, :M=>70),
        :B=>Dict(:F=>211, :U=>85, :P=>101, :G=>90),
        :C=>Dict(:R=>146, :D=>120, :P=>138),
		:P=>Dict(:R=>97, :C=>138, :B=>101),
		:M=>Dict(:L=>70, :D=>75),
        :D=>Dict(:M=>75, :C=>120),
		:U=>Dict(:B=>85, :H=>98, :V=>142),
		:G=>Dict(:B=>90),
		:H=>Dict(:U=>98, :E=>86),
        :E=>Dict(:H=>86),
        :V=>Dict(:U=>142, :I=>92),
        :I=>Dict(:V=>92, :N=>87),
		:N=>Dict(:I=>87),
   )

# ╔═╡ a9958620-13a1-4bc1-afea-723f2434de91
tree_search(
	Problem(initial_state=In(id=:A), initial_action=Go(id=:A), goal=In(id=:B), graph=romania),
	20
) |> summary

# ╔═╡ d640649c-5fd3-413f-a0a1-b013587beddc
tree_search(
	Problem(initial_state=In(id=:L), initial_action=Go(id=:L), goal=In(id=:F), graph=romania),
	20
) |> summary

# ╔═╡ 8626f57e-73d9-451e-945b-3573ec13c412
tree_search(
	Problem(initial_state=In(id=:L), initial_action=Go(id=:L), goal=In(id=:B), graph=romania),
	20
) |> summary

# ╔═╡ b0872b58-a70a-4806-a8cb-bab1f8efdff7
tree_search(
	Problem(initial_state=In(id=:C), initial_action=Go(id=:C), goal=In(id=:F), graph=romania),
	20
) |> summary

# ╔═╡ 569fa42c-ad77-468d-9a67-0d84db6ff1ee
tree_search(
	Problem(initial_state=In(id=:O), initial_action=Go(id=:O), goal=In(id=:U), graph=romania),
	20
) |> summary

# ╔═╡ 916e97ee-6670-4448-8a84-404a5df47b00
for k1 in keys(romania)
	d1 = romania[k1]
	for k2 in keys(d1)
		d2 = romania[k2]
		if !(k1 in keys(d2))
			println("$k1 not in $(keys(d2))")
		else
			if d1[k2] != d2[k1]
				println("$(d1[k2]) != $(d2[k1])")
			end
		end
	end
end

# ╔═╡ 5b0d827d-183d-4c46-8c8a-2131b77cc5f3
coord = Dict(
	:A=>( 91, 492), :B=>(400, 327), :C=>(253, 288), :D=>(165, 299),
	:E=>(562, 293), :F=>(305, 449), :G=>(375, 270), :H=>(534, 350),
	:I=>(473, 506), :L=>(165, 379), :M=>(168, 339), :N=>(406, 537),
	:O=>(131, 571), :P=>(320, 368), :R=>(233, 410), :S=>(207, 457),
	:T=>( 94, 410), :U=>(456, 350), :V=>(509, 444), :Z=>(108, 531),
)

# ╔═╡ c1d45ed6-8fac-423a-ac40-296d4e331651
nodes_id = collect(keys(romania))

# ╔═╡ cf7fbe90-41a2-47d0-aa6e-ae3e012cd426
d = Dict([(nodes_id[i], i) for i in eachindex(nodes_id)])

# ╔═╡ bc2f6434-e33b-4a07-8692-161cffc9b842
edgelist = let
	edgelist = Set([])
	for k1 in keys(romania)
		
		d1 = romania[k1]
		for k2 in keys(d1)
			push!(edgelist, Graphs.SimpleEdge(d[k1], d[k2]))	
		end
	end
	edgelist
end

# ╔═╡ 91abb2f8-ba0e-4be8-81a3-18203b195d4a
g=SimpleGraphFromIterator(edgelist)

# ╔═╡ c069f520-eb3f-4368-be27-b87bf0dac0e1
vertices(g)

# ╔═╡ 21f62cfb-d7c8-4dc0-a21e-396601ea54e0
[ (nodes_id[e.src], nodes_id[e.dst]) for e in edges(g)]

# ╔═╡ 1da319f9-17c5-4d6a-8aec-5c9659f631ce
edgedist=[romania[nodes_id[e.src]][nodes_id[e.dst]] for e in edges(g)]

# ╔═╡ 82aab5fb-8578-4d32-a66c-2d9dcd966850
locs_x = [Float64(coord[nodes_id[v]][1]) for v in vertices(g)]

# ╔═╡ 61801717-f702-4e54-92c7-52bdec020d1b
locs_y = [Float64(coord[nodes_id[v]][2]) for v in vertices(g)]

# ╔═╡ 6f9e9cf9-5612-4610-9ebc-729f641e9cee
gplot(g, locs_x, locs_y,
	nodelabel=nodes_id,
	edgelabel=edgedist, #edgelabeldistx=1.0, edgelabeldisty=1.0
)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
GraphPlot = "a2cc645c-3eea-5389-862e-a155d0052231"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"

[compat]
DataStructures = "~0.18.14"
GraphPlot = "~0.5.2"
Graphs = "~1.8.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.1"
manifest_format = "2.0"
project_hash = "a6a68fdd0903eb152a686e7d9b500055cc0990b6"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

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

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "4e88377ae7ebeaf29a047aa1ee40826e0b708a5d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.7.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "bf6570a34c850f99407b494757f5d7ad233a7257"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.5"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "cf25ccb972fec4e4817764d01c82386ae94f77b4"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.14"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

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

[[deps.GraphPlot]]
deps = ["ArnoldiMethod", "ColorTypes", "Colors", "Compose", "DelimitedFiles", "Graphs", "LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "5cd479730a0cb01f880eff119e9803c13f214cab"
uuid = "a2cc645c-3eea-5389-862e-a155d0052231"
version = "0.5.2"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "1cf1d7dcb4bc32d7b4a5add4232db3750c27ecb4"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.8.0"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IterTools]]
git-tree-sha1 = "4ced6667f9974fc5c5943fa5e2ef1ca43ea9e450"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.8.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

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
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "4b2e829ee66d4218e0cef22c0a64ee37cf258c29"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

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

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "832afbae2a45b4ae7e831f86965469a24d1d8a83"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.26"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

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
# ╠═9c8becae-9f28-411b-b351-73bdfc586a07
# ╠═1c90223e-72ba-4054-8512-6e37e22da767
# ╠═6df51de2-5a01-449a-ada9-3adb64b2813b
# ╠═5fb611fe-b9ea-4d3e-b0f8-eddb4e0f9b69
# ╠═7811a736-4116-40ec-a47d-539bc4659678
# ╠═21cc727a-1e58-11ee-1a11-f34307c928bf
# ╠═700aff0b-904e-4a34-883f-eba2249e80cb
# ╠═daa8c017-2170-421b-b4b0-46f6712a449a
# ╠═94f38634-78b0-4579-ac31-23cd27f293e7
# ╠═1bdfa350-4c08-4fa9-be8a-a92cb3c3f5f5
# ╠═989946aa-106d-44a5-a674-05b6d3b36b85
# ╠═bfc8d89b-db80-4ba6-94c4-4491b54f8c6a
# ╠═176506d8-fa09-4511-8ab3-f19c350ae885
# ╠═b51516db-a317-4b17-ac61-b22f2f8a9e96
# ╠═58ff17d7-d5ee-4bce-a94a-2ac45da07ad3
# ╠═815acc89-6590-4153-92ac-82dde80653c5
# ╠═ee04e931-26cf-4ec7-a403-db6983984e61
# ╠═b2e140e7-8a3e-4765-8756-54962d16ca13
# ╠═e871997b-84bf-4c48-bc33-8312f2195469
# ╠═f15d6a76-637d-451f-b20e-fab74183de57
# ╠═a9958620-13a1-4bc1-afea-723f2434de91
# ╠═d640649c-5fd3-413f-a0a1-b013587beddc
# ╠═8626f57e-73d9-451e-945b-3573ec13c412
# ╠═b0872b58-a70a-4806-a8cb-bab1f8efdff7
# ╠═569fa42c-ad77-468d-9a67-0d84db6ff1ee
# ╠═55f9b410-6fd9-452e-aa55-9afa855f3a70
# ╠═ec2ed73b-ca2d-4ba2-8a0a-a6d30c9705d7
# ╠═f623dc6f-294b-45fa-8b22-5210d50f3367
# ╠═147c9821-a587-471b-94c2-7c5aca5cf327
# ╠═8242a749-2c59-4a59-afb8-660952a0017e
# ╠═ea5ed506-4462-43e7-beff-0b498eed9817
# ╠═916e97ee-6670-4448-8a84-404a5df47b00
# ╠═ae467e1d-0887-4461-a72c-900997498c56
# ╠═5b0d827d-183d-4c46-8c8a-2131b77cc5f3
# ╠═c1d45ed6-8fac-423a-ac40-296d4e331651
# ╠═cf7fbe90-41a2-47d0-aa6e-ae3e012cd426
# ╠═bc2f6434-e33b-4a07-8692-161cffc9b842
# ╠═91abb2f8-ba0e-4be8-81a3-18203b195d4a
# ╠═c069f520-eb3f-4368-be27-b87bf0dac0e1
# ╠═21f62cfb-d7c8-4dc0-a21e-396601ea54e0
# ╠═1da319f9-17c5-4d6a-8aec-5c9659f631ce
# ╠═82aab5fb-8578-4d32-a66c-2d9dcd966850
# ╠═61801717-f702-4e54-92c7-52bdec020d1b
# ╠═6f9e9cf9-5612-4610-9ebc-729f641e9cee
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
