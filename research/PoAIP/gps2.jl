### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 77cf8f02-6dee-417d-84ec-aa59f5b8f2f5
function member_equal(item, list)
	# (defun member-equal (item list)
  	# 	(member item list :test #'equal))
	
	item in list
end

# ╔═╡ ac1fef40-d242-4106-8479-a493136f5909
function starts_with(list, x)
	# (defun starts-with (list x)
  	# 	"Is this a list whose first element is x?"
  	# 	(and (consp list) (eql (first list) x)))

	list isa Tuple && length(list) > 0 && list[1] == x
end

# ╔═╡ a4866c5e-9159-474b-b99f-11bb8f74f1fc
function executing_p(x)
	# (defun executing-p (x)
  	# 	"Is x of the form: (executing ...) ?"
  	# 	(starts-with x 'executing))

	starts_with(x, :executing)
end

# ╔═╡ b00f1378-3c55-4f0d-914f-ced9c90a0d02
function convert_op(op)
	# (defun convert-op (op)
  	# 	"Make op conform to the (EXECUTING op) convention."
  	# 	(unless (some #'executing-p (op-add-list op))
    # 		(push (list 'executing (op-action op)) (op-add-list op)))
  	# 	op)
	
	if !any(executing_p.(op.add_list))
		op.add_list = ((:executing, op.action), op.add_list...)
	end
	op
end

# ╔═╡ 32d37228-ee6c-4a18-8a68-04cf0161215a
function find_all(pred, item, list)
	filter((i) -> pred(item, i), list)
end

# ╔═╡ fce2907f-b93d-4104-ae7f-80913f2f54e7
function appropriate_p(goal, op)
	# (defun appropriate-p (goal op)
  	# 	"An op is appropriate to a goal if it is in its add list."
  	# 	(member-equal goal (op-add-list op)))

	member_equal(goal, op.add_list)
end

# ╔═╡ 3f93d024-1a47-11ee-22ff-11b35e1745ad
function GPS(state, goals, ops)

	function apply_op(state, goal, op, goal_stack)
		# (defun apply-op (state goal op goal-stack)
  		# 	"Return a new, transformed state if op is applicable."
  		# 	(dbg-indent :gps (length goal-stack) "Consider: ~a" (op-action op))
  		# 	(let ((state2 (achieve-all state (op-preconds op)
        #                      (cons goal goal-stack))))
    	# 		(unless (null state2)
      	# 			;; Return an updated state
      	# 			(dbg-indent :gps (length goal-stack) "Action: ~a" (op-action op))
      	# 			(append (remove-if #'(lambda (x)
        #                      (member-equal x (op-del-list op)))
        #                  state2)
        #       		(op-add-list op)))))
		
		println("apply_op :: len goal_stack: $(length(goal_stack)), Consider: $(op.action)")
		state2 = achieve_all(state,  op.preconds, (goal, goal_stack...))
		if state2 != ()
			println("apply_op :: len goal_stack: $(length(goal_stack)), Action: $(op.action)")
			(filter((x)->!member_equal(x, op.del_list), state2)..., op.add_list...)
		else
			()
		end
	end

	function achieve_all(state, goals, goal_stack)
		# (defun achieve-all (state goals goal-stack)
  		# 	"Achieve each goal, and make sure they still hold at the end."
  		# 	(let ((current-state state))
    	# 		(if (and (every #'(lambda (g)
        #                 (setf current-state
        #                       (achieve current-state g goal-stack)))
        #             goals)
        #      		(subsetp goals current-state :test #'equal))
        # 		current-state)))
		
		println(("achieve_all :: input state: $state"))
		println(("achieve_all :: input goals: $goals"))
		println(("achieve_all :: input goal_stack: $goal_stack"))
		current_state = state
		for g in goals
			current_state = achieve(current_state, g, goal_stack)
			#println(current_state)
			if length(current_state) == 0 || !issubset(goals, current_state)
				break
			end
		end
		
		println(("achieve_all :: return state: $current_state"))
		return current_state
		
		#if all(
		#	((g)->current_state = achieve(current_state, g, goal_stack)).(goals) && #issubset(goals, current_state))

		#	current_state
		#end
	end

	function achieve(state, goal, goal_stack)
		# (defun achieve (state goal goal-stack)
  		# 	"A goal is achieved if it already holds,
  		# 	or if there is an appropriate op for it that is applicable."
  		# 	(dbg-indent :gps (length goal-stack) "Goal: ~a" goal)
  		# 	(cond ((member-equal goal state) state)
        # 		((member-equal goal goal-stack) nil)
        # 		(t (some #'(lambda (op) (apply-op state goal op goal-stack))
        #         	(find-all goal *ops* :test #'appropriate-p)))))

		println("achieve :: len goal_stack: $(length(goal_stack)), goal: $goal")

		if member_equal(goal, state)
			state
		elseif member_equal(goal, goal_stack)
			()
		else
			fn = (op) -> apply_op(state, goal, op, goal_stack) 
			sts = fn.(find_all(appropriate_p, goal, ops))
			#println(fn.(find_all(appropriate_p, goal, ops)))
			ind = findfirst((i)->length(i)>0, sts)
			if !isnothing(ind)
				sts[ind]
			else
				()
			end
		end
		
	end

	finish_state = achieve_all(((:start,), state...), goals, ()) 
	println(("GPS :: finish state: $finish_state"))
	#if achieve_all(((:start,), state...), goals, ()) 
	#	println("Solved")
  	#	:solved
	#else
	#	println("Not Solved")
	#	:not_solved
  	#end
end

# ╔═╡ 561ca87e-efe8-48b9-992b-84b1cc27a992
@kwdef mutable struct Op
	action = nothing
	preconds = ()
	add_list = ()
	del_list = ()
end

# ╔═╡ f9f31ec0-336e-4dbf-942d-69b44594e86f
school_ops = (
	Op(
		action = :drive_son_to_school,
      	preconds = (:son_at_home, :car_works),
      	add_list = (:son_at_school,),
      	del_list = (:son_at_home,),
	),
	Op(
		action = :shop_installs_battery,
      	preconds = (:car_needs_battery, :shop_knows_problem, :shop_has_money),
      	add_list = (:car_works,),
	),
	Op(
		action = :tell_shop_problem,
      	preconds = (:in_communication_with_shop,),
      	add_list = (:shop_knows_problem,),
	),
	Op(
		action = :telephone_shop,
      	preconds = (:know_phone_number,),
      	add_list = (:in_communication_with_shop,),
	),
	Op(
		action = :look_up_number,
      	preconds = (:have_phone_book,),
      	add_list = (:know_phone_number,),
	),
	Op(
		action = :give_shop_money,
      	preconds = (:have_money,),
      	add_list = (:shop_has_money,),
      	del_list = (:have_money,),
	),

)

# ╔═╡ 1b2255cc-bf14-4e78-a2f1-6c5d3bbd2b13
GPS(
	(:son_at_home, :car_needs_battery, :have_money, :have_phone_book), 
	(:son_at_school,), 
	convert_op.(school_ops)
)

# ╔═╡ 08e24f42-d131-4f69-9261-0996e3ca1712
GPS(
	(:son_at_home, :car_needs_battery, :have_money, :have_phone_book), 
	(:son_at_school, :have_money), 
	convert_op.(school_ops)
)

# ╔═╡ f826897d-d404-4fd8-abd1-fcc4038a7968
school_ops

# ╔═╡ Cell order:
# ╠═3f93d024-1a47-11ee-22ff-11b35e1745ad
# ╠═77cf8f02-6dee-417d-84ec-aa59f5b8f2f5
# ╠═b00f1378-3c55-4f0d-914f-ced9c90a0d02
# ╠═a4866c5e-9159-474b-b99f-11bb8f74f1fc
# ╠═ac1fef40-d242-4106-8479-a493136f5909
# ╠═32d37228-ee6c-4a18-8a68-04cf0161215a
# ╠═fce2907f-b93d-4104-ae7f-80913f2f54e7
# ╠═1b2255cc-bf14-4e78-a2f1-6c5d3bbd2b13
# ╠═08e24f42-d131-4f69-9261-0996e3ca1712
# ╠═f826897d-d404-4fd8-abd1-fcc4038a7968
# ╠═561ca87e-efe8-48b9-992b-84b1cc27a992
# ╠═f9f31ec0-336e-4dbf-942d-69b44594e86f
