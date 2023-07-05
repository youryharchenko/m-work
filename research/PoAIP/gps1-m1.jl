### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 4f1097a7-8912-4a8a-b637-8a83d85fd292
const Term = Union{Symbol, Tuple}

# ╔═╡ 929d406e-37a2-4841-93ad-847c915309f6
function Terms(list)::Set{Term}
	Set(list)	
end

# ╔═╡ 60f4de23-7e89-4982-a766-495333744a6e


# ╔═╡ 55c13881-e9de-4830-9fa3-7b889f7a2b6e
@kwdef struct Op 
	action::Term = nothing
	preconds::Set{Term} = Set()
	add_list::Set{Term} = Set()
	del_list::Set{Term} = Set()
end

# ╔═╡ e4859ce6-b5c5-4cc5-8018-d6639ee0f5ec
function appropriate_p(goal::Term, op::Op)::Bool  #where {T<:Term}
	# (defun appropriate-p (goal op)
  	# 	"An op is appropriate to a goal if it is in its add list."
  	# 	(member goal (op-add-list op)))

	goal in op.add_list
end

# ╔═╡ 336d52f9-a2fa-47bb-91ab-051d96e556f9
function find_all(pred::Function, item::Term, list::Set{Op})::Set{Op}  #where {T<:Term}
	filter((i) -> pred(item, i), list)
end

# ╔═╡ 9b10906d-6244-43b9-846f-484a25045c33
@kwdef mutable struct Problem
	state::Set{Term} = Set()
	goals::Set{Term} = Set()
	ops::Set{Op} = Set()
end

# ╔═╡ caf247a9-6365-4200-852f-408253b92dbd
function achieve(problem::Problem, goal::Term)::Bool #where {T<:Term}
	# (defun achieve (goal)
	#	"A goal is achieved if it already holds,
	#	or if there is an appropriate op for it that is applicable."
	#	(or (member goal *state*)
   	#		(some #'apply-op
    #    		(find-all goal *ops* :test #'appropriate-p))))

	# goal in state || 
	#	any(apply_op.(find_all(appropriate_p, goal, ops)))

	if goal in problem.state
		true
	else 
		#any(apply_op.(find_all(appropriate_p, goal, ops)))
		for op in find_all(appropriate_p, goal, problem.ops)
			if apply_op(problem, op)
				return true
			end
		end
		false
	end
end

# ╔═╡ 68656793-5d16-41ad-ad58-ec4ae957f09b
function achieve_all(state::Set{Term}, goals::Set{Term}, ops::Set{Op})::Bool #where {T<:Term}
	for g in goals
		if !achieve(state, g, ops)
			return false
		end
	end
	true
	#all(achieve.(state, goals)) 
end

# ╔═╡ e4af48a2-199a-11ee-391a-1da131422d10
function GPS(state::Set{Term}, goals::Set{Term}, ops::Set{Op})::Term #where{T<:Term}
	# (defun GPS (*state* goals *ops*)
	# 	"General Problem Solver: achieve all goals using *ops*."
    #	(if (every #'achieve goals) 'solved))
	
	if achieve_all(state, goals, ops) #all(achieve.(goals)) 
		println("Solved")
  		:solved
	else
		println("Not Solved")
		:not_solved
  	end
end

# ╔═╡ 3cac5cb8-8ff2-42ff-b9d3-7b436b3fd98d
function apply_op(state::Set{Term}, op::Op, ops::Set{Op})::Bool #where {T<:Term}
		# (defun apply-op (op)
  		# 	"Print a message and update *state* if op is applicable."
  		# 	(when (every #'achieve (op-preconds op))
    	# 		(print (list 'executing (op-action op)))
    	# 		(setf *state* (set-difference *state* (op-del-list op)))
    	# 		(setf *state* (union *state* (op-add-list op)))
    	# 		t))

		if achieve_all(state, op.preconds, ops) # all(achieve.(op.preconds))
			println("Executing: $(op.action)")
			state = setdiff(state, op.del_list)
			state = union(state, op.add_list)
			true
		else
			false
		end
	end

# ╔═╡ 9f552ba6-0466-4824-a53d-1df4e78cffd8
function achieve(state::Set{Term}, goal::Term, ops::Set{Op})::Bool #where {T<:Term}
	# (defun achieve (goal)
	#	"A goal is achieved if it already holds,
	#	or if there is an appropriate op for it that is applicable."
	#	(or (member goal *state*)
   	#		(some #'apply-op
    #    		(find-all goal *ops* :test #'appropriate-p))))

	# goal in state || 
	#	any(apply_op.(find_all(appropriate_p, goal, ops)))

	if goal in state
		true
	else 
		#any(apply_op.(find_all(appropriate_p, goal, ops)))
		for op in find_all(appropriate_p, goal, ops)
			if apply_op(state, op, ops)
				return true
			end
		end
		false
	end
end

# ╔═╡ 49e06ed9-a282-47ea-85a3-e491c6276240
function achieve_goals(problem::Problem)::Bool #where {T<:Term}
	for g in problem.goals
		if !achieve(problem, g)
			return false
		end
	end
	true
	#all(achieve.(state, goals)) 
end

# ╔═╡ a355034f-f71b-4134-94e0-724ad39f3766
function GPS(problem::Problem)::Term #where{T<:Term}
	# (defun GPS (*state* goals *ops*)
	# 	"General Problem Solver: achieve all goals using *ops*."
    #	(if (every #'achieve goals) 'solved))
	
	if achieve_goals(problem) #all(achieve.(goals)) 
		println("Solved")
  		:solved
	else
		println("Not Solved")
		:not_solved
  	end
end

# ╔═╡ a47d5d7b-2d70-43a1-aec3-95000b030b0b
function achieve_preconds(problem::Problem, op::Op)::Bool #where {T<:Term}
	for g in op.preconds
		if !achieve(problem, g)
			return false
		end
	end
	true
	#all(achieve.(state, goals)) 
end

# ╔═╡ d77d61b4-bd21-410b-83d7-f7bd2a63c70b
function apply_op(problem::Problem, op::Op)::Bool #where {T<:Term}
		# (defun apply-op (op)
  		# 	"Print a message and update *state* if op is applicable."
  		# 	(when (every #'achieve (op-preconds op))
    	# 		(print (list 'executing (op-action op)))
    	# 		(setf *state* (set-difference *state* (op-del-list op)))
    	# 		(setf *state* (union *state* (op-add-list op)))
    	# 		t))

		if achieve_preconds(problem, op) # all(achieve.(op.preconds))
			println("Executing: $(op.action)")
			problem.state = setdiff(problem.state, op.del_list)
			problem.state = union(problem.state, op.add_list)
			true
		else
			false
		end
	end

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

# ╔═╡ 7eb36805-799c-4bb3-8e95-880857b4c00e
GPS(
	Terms((:son_at_home, :car_needs_battery, :have_money, :have_phone_book)), 
	Terms((:son_at_school,)), 
	school_ops
)

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

# ╔═╡ 83cbeea6-2f11-43f6-9770-c3372905e715
(union((:a,:b),(:b,))...,)

# ╔═╡ Cell order:
# ╠═4f1097a7-8912-4a8a-b637-8a83d85fd292
# ╠═e4af48a2-199a-11ee-391a-1da131422d10
# ╠═a355034f-f71b-4134-94e0-724ad39f3766
# ╠═e4859ce6-b5c5-4cc5-8018-d6639ee0f5ec
# ╠═336d52f9-a2fa-47bb-91ab-051d96e556f9
# ╠═3cac5cb8-8ff2-42ff-b9d3-7b436b3fd98d
# ╠═d77d61b4-bd21-410b-83d7-f7bd2a63c70b
# ╠═49e06ed9-a282-47ea-85a3-e491c6276240
# ╠═a47d5d7b-2d70-43a1-aec3-95000b030b0b
# ╠═68656793-5d16-41ad-ad58-ec4ae957f09b
# ╠═9f552ba6-0466-4824-a53d-1df4e78cffd8
# ╠═caf247a9-6365-4200-852f-408253b92dbd
# ╠═929d406e-37a2-4841-93ad-847c915309f6
# ╠═7eb36805-799c-4bb3-8e95-880857b4c00e
# ╠═d5447004-adc7-41a8-bc74-37962fa80a39
# ╠═7c244e03-f7a7-445f-bf28-982c207eb030
# ╠═57aaff0b-8361-4d23-85ec-2a63cf0ef105
# ╠═0825a457-6721-45f9-b55c-67f15583d507
# ╠═526add69-9922-433b-ab04-57413f2b0b5b
# ╠═60f4de23-7e89-4982-a766-495333744a6e
# ╠═9b10906d-6244-43b9-846f-484a25045c33
# ╠═55c13881-e9de-4830-9fa3-7b889f7a2b6e
# ╠═2a88cbd1-00e3-4ff9-ab69-f5bbcfd2d6f8
# ╠═83cbeea6-2f11-43f6-9770-c3372905e715
