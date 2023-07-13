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

# ╔═╡ 7811a736-4116-40ec-a47d-539bc4659678
const ID = Union{Symbol, String, Int}

# ╔═╡ 0e3e7536-da59-429c-8b5a-9f991251b844
struct Var
	id::Symbol
end

# ╔═╡ 21cc727a-1e58-11ee-1a11-f34307c928bf
@kwdef struct StateAtom <: AbstractState
	succ::Bool = false
	pos::Int = 1
	len::Int = 1
	env = Dict()
end

# ╔═╡ ef1c2954-a130-48e6-887a-5320fc3afb67
@kwdef struct StateIter <: AbstractState
	succ::Bool = false
	pos::Int = 0
	len::Int = 0
	env = Dict()
end

# ╔═╡ 700aff0b-904e-4a34-883f-eba2249e80cb
#isequal(in1::State, in2::In)::Bool = in1.id == in2.id


# ╔═╡ daa8c017-2170-421b-b4b0-46f6712a449a
@kwdef struct MatchAtom <: AbstractAction
	pattern = nothing
	input = nothing
	pos_pat::Int = 1
	pos_inp::Int = 1
end

# ╔═╡ 85881b65-3159-409c-9bb9-40507eda9bd3
@kwdef struct MatchIter <: AbstractAction
	pattern = nothing
	input = nothing
	pos_pat::Int = 1
	pos_inp::Int = 1
end

# ╔═╡ 94f38634-78b0-4579-ac31-23cd27f293e7
@kwdef mutable struct Node <: AbstractNode 
	state::Union{AbstractState, Nothing} = nothing
	parent::Union{AbstractNode, Nothing} = nothing
	action::Union{AbstractAction, Nothing} = nothing
	children::Array{Node} = Node[]
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
	[[n.state for n in s] for s in result.solution])
end

# ╔═╡ 176506d8-fa09-4511-8ab3-f19c350ae885
@kwdef struct Problem
	#initial_state::AbstractState = nothing
	pattern = nothing
	input = nothing
	initial_action::AbstractAction = nothing
	#goal_test::AbstractState = nothing
	#graph::Dict = nothing
end

# ╔═╡ b51516db-a317-4b17-ac61-b22f2f8a9e96
function goal_test(problem, state)
	state.succ && state.pos == state.len
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

# ╔═╡ e73af586-c7a8-4477-8b36-d07464176c32
isiterable(x) = applicable(length, x)

# ╔═╡ 58ff17d7-d5ee-4bce-a94a-2ac45da07ad3
function expand(problem, node)
	nodes = Node[]
	if node.state isa StateIter
		pattern = node.action.pattern
		input = node.action.input
		for i in eachindex(node.action.pattern)
			pat = pattern[i]
			inp = (i > length(input)) ? nothing : input[i]
			println("$pat, $inp")
			if isiterable(pat) 
				push!(nodes, Node(action=MatchIter(pattern=pat, input=inp)))
			else
				push!(nodes, Node(action=MatchAtom(pattern=pat, input=inp)))
			end
			
		end
	end
	node.children = nodes
	nodes
end

# ╔═╡ 891d8023-bab0-4c22-a607-66c0b69707eb
function var_match!(var, input, env)
	if haskey(env, var.id)
		env[var.id] == input
	else
		env[var.id] = input
		true
	end
end

# ╔═╡ db4e5c32-95c3-4a05-84f4-a1d39ce9ca9b
function apply_action!(node)
	action = node.action
	env = isnothing(node.parent) ? Dict() : node.parent.state.env

	 
	if action isa MatchAtom
		succ = if action.pattern isa Var
			var_match!(action.pattern, action.input, env)
		elseif action.pattern == action.input
			true
		else
			false
		end
		node.state = StateAtom(succ=succ, env=env)
	elseif action isa MatchIter
		succ, pos, len = if length(action.pattern) == 0 && length(action.input) == 0
			(true, 1, 1)
		else
			(false, 0, 0)	
		end
		node.state = StateIter(succ=succ, pos=pos, len=len, env=env)
	else 
		node.state = StateAtom(succ=false, env=env)
	end

	
	node
end

# ╔═╡ f15d6a76-637d-451f-b20e-fab74183de57
function tree_search(problem, n=1)
	fringe = Queue{Node}()
	#visited = []
	node = Node(
		action=problem.initial_action,
	)
	enqueue!(fringe, node)
	solutions = []
	succ = false
	count = 1
	k = 0
	while !isempty(fringe) && k < 100
		k += 1 
		node = apply_action!(dequeue!(fringe))

		println(node)
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

# ╔═╡ 30cbb93f-89b7-4454-a3e2-87106ff05c1e
function pat_match(pattern, input)
	problem = Problem(
		pattern=pattern, input=input, 
		initial_action=isiterable(pattern) ? 
			MatchIter(pattern=pattern, input=input) : 
			MatchAtom(pattern=pattern, input=input)
	)  

	tree_search(problem, 20)
end

# ╔═╡ e0df6b04-d8b1-42cd-88bd-5924e93222d8
pat_match(Var(:x), :b) |> summary

# ╔═╡ df1f1b1b-e675-4530-8dea-3c3fb4237717
pat_match(Var(:x), :a) |> summary

# ╔═╡ a9958620-13a1-4bc1-afea-723f2434de91
pat_match(:a, :a) |> summary

# ╔═╡ 284efdf3-6413-49df-a947-b7e0ee9d1482
pat_match(:a, 1) |> summary

# ╔═╡ 9aa2df82-d2e9-456f-9343-f17043b7e28e
pat_match(:a, :b) |> summary

# ╔═╡ 5ba01bbc-2894-4804-97f8-b36f6c18b101
pat_match([], []) |> summary

# ╔═╡ e6e29636-1b74-4028-9407-d47a993780d9
pat_match([:a, :b], [:a, :b]) |> summary

# ╔═╡ 405cc43c-5803-43f1-bef9-7f3c5dd0db0d
pat_match([:a, :b], [:a, :c]) |> summary

# ╔═╡ 41c9a86b-f1c2-47e6-9fa4-aff25f228a5d
isiterable(:a) 

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
# ╠═7811a736-4116-40ec-a47d-539bc4659678
# ╠═0e3e7536-da59-429c-8b5a-9f991251b844
# ╠═21cc727a-1e58-11ee-1a11-f34307c928bf
# ╠═ef1c2954-a130-48e6-887a-5320fc3afb67
# ╠═700aff0b-904e-4a34-883f-eba2249e80cb
# ╠═daa8c017-2170-421b-b4b0-46f6712a449a
# ╠═85881b65-3159-409c-9bb9-40507eda9bd3
# ╠═94f38634-78b0-4579-ac31-23cd27f293e7
# ╠═1bdfa350-4c08-4fa9-be8a-a92cb3c3f5f5
# ╠═989946aa-106d-44a5-a674-05b6d3b36b85
# ╠═bfc8d89b-db80-4ba6-94c4-4491b54f8c6a
# ╠═176506d8-fa09-4511-8ab3-f19c350ae885
# ╠═30cbb93f-89b7-4454-a3e2-87106ff05c1e
# ╠═b51516db-a317-4b17-ac61-b22f2f8a9e96
# ╠═58ff17d7-d5ee-4bce-a94a-2ac45da07ad3
# ╠═815acc89-6590-4153-92ac-82dde80653c5
# ╠═ee04e931-26cf-4ec7-a403-db6983984e61
# ╠═b2e140e7-8a3e-4765-8756-54962d16ca13
# ╠═e73af586-c7a8-4477-8b36-d07464176c32
# ╠═db4e5c32-95c3-4a05-84f4-a1d39ce9ca9b
# ╠═891d8023-bab0-4c22-a607-66c0b69707eb
# ╠═f15d6a76-637d-451f-b20e-fab74183de57
# ╠═e0df6b04-d8b1-42cd-88bd-5924e93222d8
# ╠═df1f1b1b-e675-4530-8dea-3c3fb4237717
# ╠═a9958620-13a1-4bc1-afea-723f2434de91
# ╠═284efdf3-6413-49df-a947-b7e0ee9d1482
# ╠═9aa2df82-d2e9-456f-9343-f17043b7e28e
# ╠═5ba01bbc-2894-4804-97f8-b36f6c18b101
# ╠═e6e29636-1b74-4028-9407-d47a993780d9
# ╠═405cc43c-5803-43f1-bef9-7f3c5dd0db0d
# ╠═41c9a86b-f1c2-47e6-9fa4-aff25f228a5d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
