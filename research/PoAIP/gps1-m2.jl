### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 3c4ee829-c1e9-494b-b989-e02dd140ee1a
using DataStructures

# ╔═╡ 4f1097a7-8912-4a8a-b637-8a83d85fd292
const Term = Union{Symbol, Tuple}

# ╔═╡ 3f74b3dd-0cf1-4b8e-a138-b773df57ba13
@kwdef struct Op 
	action::Term = nothing
	preconds::Set{Term} = Set()
	add_list::Set{Term} = Set()
	del_list::Set{Term} = Set()
end

# ╔═╡ 76863221-93cf-4584-87ed-f26a88d51172
@kwdef mutable struct Problem
	state::Set{Term} = Set{Term}()
	goals::Set{Term} = Set{Term}()
	stack::Stack{Term} = Stack{Term}()
	ops::Set{Op} = Set()
end

# ╔═╡ e4af48a2-199a-11ee-391a-1da131422d10
@kwdef struct Result
	problem::Problem = nothing
	succ::Bool = false
end

# ╔═╡ a355034f-f71b-4134-94e0-724ad39f3766
begin

function GPS(problem::Problem)::Result 
	# (defun GPS (*state* goals *ops*)
	# 	"General Problem Solver: achieve all goals using *ops*."
    #	(if (every #'achieve goals) 'solved))

	result = achieve_goals(problem) 
	if result.succ
		println("Solved")
	else
		println("Not Solved")
  	end
	result
end

function appropriate_p(goal::Term, op::Op)::Bool
	goal in op.add_list
end

function find_all(pred::Function, item::Term, list::Set{Op})::Set{Op}  
	filter((i) -> pred(item, i), list)
end

function appropriated(problem::Problem, goal::Term)::Set{Op}
	find_all(appropriate_p, goal, problem.ops)
end

function apply_op(problem::Problem, goal::Term, op::Op)::Result
	println("Consider: $(op.action)")
	push!(problem.stack, goal)
	#println("Stack: $(problem.stack)")
	result = achieve_preconds(problem, op)
	
	if result.succ 
		println("Action: $(op.action)")
		state = setdiff(result.problem.state, op.del_list)
		result.problem.state = union(state, op.add_list)
		result
	else
		result
	end
end

function achieve_all(problem::Problem, goals::Set{Term})::Result
	current_problem = copy(problem)
	for g in goals
		result = achieve(current_problem, g)
		if !result.succ
			return result
		end
		current_problem.state = result.problem.state
	end
	if !issubset(goals, current_problem.state)
		return Result(problem=current_problem, succ=false)
	end
	Result(problem=current_problem, succ=true)
end

function achieve_goals(problem::Problem)::Result
	achieve_all(problem, problem.goals)
end

function achieve_preconds(problem::Problem, op::Op)::Result
	achieve_all(problem, op.preconds)
end

function achieve(problem::Problem, goal::Term)::Result
	println("Goal: $goal")
	if goal in problem.stack
		Result(problem=problem, succ=false)
	elseif goal in problem.state
		Result(problem=problem, succ=true)
	else 
		for op in appropriated(problem, goal) 
			result = apply_op(problem, goal, op)
			if result.succ
				return result
			end
		end
		Result(problem=problem, succ=false)
	end
end

function Terms(list)::Set{Term}
	Set(list)	
end

function copy(problem::Problem)
	Problem(state=problem.state, goals=problem.goals, stack=problem.stack, ops=problem.ops)
end

end;

# ╔═╡ caf247a9-6365-4200-852f-408253b92dbd


# ╔═╡ 55c13881-e9de-4830-9fa3-7b889f7a2b6e


# ╔═╡ 2a88cbd1-00e3-4ff9-ab69-f5bbcfd2d6f8
school_ops = Set((
	Op(
		action = :drive_son_to_school,
      	preconds = Set((:son_at_home, :car_works)),
      	add_list = Set((:son_at_school,)),
      	del_list = Set((:son_at_home,)),
	),
	Op(
		action = :shop_installs_battery,
      	preconds = Set((:car_needs_battery, :shop_knows_problem, :shop_has_money)),
      	add_list = Set((:car_works,)),
	),
	Op(
		action = :tell_shop_problem,
      	preconds = Set((:in_communication_with_shop,)),
      	add_list = Set((:shop_knows_problem,)),
	),
	Op(
		action = :telephone_shop,
      	preconds = Set((:know_phone_number,)),
      	add_list = Set((:in_communication_with_shop,)),
	),
	Op(
		action = :look_up_number,
      	preconds = Set((:have_phone_book,)),
      	add_list = Set((:know_phone_number,)),
	),
	Op(
		action = :give_shop_money,
      	preconds = Set((:have_money, :shop_knows_problem)),
      	add_list = Set((:shop_has_money,)),
      	del_list = Set((:have_money,)),
	),

))

# ╔═╡ d5447004-adc7-41a8-bc74-37962fa80a39
GPS(
	Problem(
		state = Terms((:son_at_home, :car_needs_battery, :have_money, :have_phone_book)), 
		goals = Terms((:son_at_school,)),
		ops = school_ops
	), 
)

# ╔═╡ 7c244e03-f7a7-445f-bf28-982c207eb030
GPS(
	Problem(
		state = Terms((:son_at_home, :car_needs_battery, :have_money, :have_phone_book)), 
		goals = Terms((:son_at_school, :have_money)),
		ops = school_ops
	), 
)

# ╔═╡ 57aaff0b-8361-4d23-85ec-2a63cf0ef105
GPS(
	Problem(
		state = Terms((:son_at_home, :car_needs_battery, :have_money, :have_phone_book)), 
		goals = Terms((:have_money, :son_at_school)),
		ops = school_ops
	), 
)

# ╔═╡ 0825a457-6721-45f9-b55c-67f15583d507
GPS(
	Problem(
		state = Terms((:son_at_home, :car_needs_battery, :have_money, :know_phone_number)), 
		goals = Terms((:son_at_school,)),
		ops = school_ops), 
)

# ╔═╡ 526add69-9922-433b-ab04-57413f2b0b5b
GPS(
	Problem(
		state = Terms((:son_at_home, :car_works)), 
		goals = Terms((:son_at_school,)),
		ops = school_ops
	), 
)

# ╔═╡ 465c198b-9124-41a8-bac7-b18323acb2ad
banana = Set((
	Op(
		action = :climb_on_chair,
      	preconds = Set((:chair_at_middle_room, :at_middle_room, :on_floor)),
      	add_list = Set((:at_bananas, :on_chair)),
      	del_list = Set((:at_middle_room, :on_floor)),
	),
	Op(
		action = :push_chair_from_door_to_middle_room,
      	preconds = Set((:chair_at_door, :at_door)),
      	add_list = Set((:chair_at_middle_room, :at_middle_room)),
      	del_list = Set((:chair_at_door, :at_door)),
	),
	Op(
		action = :walk_from_door_to_middle_room,
      	preconds = Set((:at_door, :on_floor)),
      	add_list = Set((:at_middle_room,)),
      	del_list = Set((:at_door,)),
	),
	Op(
		action = :grasp_bananas,
      	preconds = Set((:at_bananas, :empty_handed)),
      	add_list = Set((:has_bananas,)),
      	del_list = Set((:empty_handed,)),
	),
	Op(
		action = :drop_ball,
      	preconds = Set((:has_ball,)),
      	add_list = Set((:empty_handed,)),
      	del_list = Set((:has_ball,)),
	),
	Op(
		action = :eat_bananas,
      	preconds = Set((:has_bananas,)),
      	add_list = Set((:empty_handed, :not_hungry)),
      	del_list = Set((:has_bananas, :hungry)),
	),
))

# ╔═╡ 488972d6-1b84-4fd2-affa-16e2b97de2f2
GPS(
	Problem(
		state = Terms((:at_door, :on_floor, :has_ball, :hungry, :chair_at_door)), 
		goals = Terms((:not_hungry,)),
		ops = banana
	), 
)

# ╔═╡ 26a66cff-02c2-42c1-bfc7-425aa50fa3e3


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
# ╠═3c4ee829-c1e9-494b-b989-e02dd140ee1a
# ╠═4f1097a7-8912-4a8a-b637-8a83d85fd292
# ╠═76863221-93cf-4584-87ed-f26a88d51172
# ╠═3f74b3dd-0cf1-4b8e-a138-b773df57ba13
# ╠═e4af48a2-199a-11ee-391a-1da131422d10
# ╠═a355034f-f71b-4134-94e0-724ad39f3766
# ╠═caf247a9-6365-4200-852f-408253b92dbd
# ╠═d5447004-adc7-41a8-bc74-37962fa80a39
# ╠═7c244e03-f7a7-445f-bf28-982c207eb030
# ╠═57aaff0b-8361-4d23-85ec-2a63cf0ef105
# ╠═0825a457-6721-45f9-b55c-67f15583d507
# ╠═526add69-9922-433b-ab04-57413f2b0b5b
# ╠═55c13881-e9de-4830-9fa3-7b889f7a2b6e
# ╠═2a88cbd1-00e3-4ff9-ab69-f5bbcfd2d6f8
# ╠═488972d6-1b84-4fd2-affa-16e2b97de2f2
# ╠═465c198b-9124-41a8-bac7-b18323acb2ad
# ╠═26a66cff-02c2-42c1-bfc7-425aa50fa3e3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
