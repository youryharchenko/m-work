### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 9c8becae-9f28-411b-b351-73bdfc586a07
using DataStructures

# ╔═╡ 1c90223e-72ba-4054-8512-6e37e22da767
abstract type AbstractState end

# ╔═╡ 6df51de2-5a01-449a-ada9-3adb64b2813b
abstract type AbstractNode end

# ╔═╡ 5fb611fe-b9ea-4d3e-b0f8-eddb4e0f9b69
abstract type AbstractAction end

# ╔═╡ 21cc727a-1e58-11ee-1a11-f34307c928bf
@kwdef struct In <: AbstractState
	name::Symbol = nothing
end

# ╔═╡ 700aff0b-904e-4a34-883f-eba2249e80cb
isequal(in1::AbstractState, in2::AbstractState)::Bool = in1.name == in2.name


# ╔═╡ daa8c017-2170-421b-b4b0-46f6712a449a
@kwdef struct Go <: AbstractAction
	name = nothing
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
	[[n.action.name for n in s] for s in result.solution])
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
	[(Go(name=s), In(name=s)) 
		for s in keys(problem.graph[state.name])]
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
	Problem(initial_state=In(name=:A), initial_action=Go(name=:A), goal=In(name=:B), graph=romania),
	20
) |> summary

# ╔═╡ d640649c-5fd3-413f-a0a1-b013587beddc
tree_search(
	Problem(initial_state=In(name=:L), initial_action=Go(name=:L), goal=In(name=:F), graph=romania),
	20
) |> summary

# ╔═╡ 8626f57e-73d9-451e-945b-3573ec13c412
tree_search(
	Problem(initial_state=In(name=:L), initial_action=Go(name=:L), goal=In(name=:B), graph=romania),
	20
) |> summary

# ╔═╡ b0872b58-a70a-4806-a8cb-bab1f8efdff7
tree_search(
	Problem(initial_state=In(name=:C), initial_action=Go(name=:C), goal=In(name=:F), graph=romania),
	20
) |> summary

# ╔═╡ 569fa42c-ad77-468d-9a67-0d84db6ff1ee
tree_search(
	Problem(initial_state=In(name=:O), initial_action=Go(name=:O), goal=In(name=:U), graph=romania),
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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"

[compat]
DataStructures = "~0.18.14"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.1"
manifest_format = "2.0"
project_hash = "e3a8422b0e28175696b10e5286e7a9c342411687"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "4e88377ae7ebeaf29a047aa1ee40826e0b708a5d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.7.0"

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

    [deps.Compat.weakdeps]
    Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "cf25ccb972fec4e4817764d01c82386ae94f77b4"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.14"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
"""

# ╔═╡ Cell order:
# ╠═9c8becae-9f28-411b-b351-73bdfc586a07
# ╠═1c90223e-72ba-4054-8512-6e37e22da767
# ╠═6df51de2-5a01-449a-ada9-3adb64b2813b
# ╠═5fb611fe-b9ea-4d3e-b0f8-eddb4e0f9b69
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
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
