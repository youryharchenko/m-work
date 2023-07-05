### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ e4af48a2-199a-11ee-391a-1da131422d10
function GPS(state, goals, ops)
	# (defun GPS (*state* goals *ops*)
	# 	"General Problem Solver: achieve all goals using *ops*."
    #	(if (every #'achieve goals) 'solved))

	function apply_op(op)
		# (defun apply-op (op)
  		# 	"Print a message and update *state* if op is applicable."
  		# 	(when (every #'achieve (op-preconds op))
    	# 		(print (list 'executing (op-action op)))
    	# 		(setf *state* (set-difference *state* (op-del-list op)))
    	# 		(setf *state* (union *state* (op-add-list op)))
    	# 		t))

		if all(achieve.(op.preconds))
			println("Executing: $(op.action)")
			state = (setdiff(state, op.del_list)...,)
			state = (union(state, op.add_list)...,)
			true
		else
			false
		end
	end

	function appropriate_p(goal, op)
		# (defun appropriate-p (goal op)
  		# 	"An op is appropriate to a goal if it is in its add list."
  		# 	(member goal (op-add-list op)))

		goal in op.add_list
	end

	function find_all(pred, item, list)
		filter((i) -> pred(item, i), list)
	end
	
	function achieve(goal)
		# (defun achieve (goal)
  		#	"A goal is achieved if it already holds,
  		#	or if there is an appropriate op for it that is applicable."
  		#	(or (member goal *state*)
      	#		(some #'apply-op
        #    		(find-all goal *ops* :test #'appropriate-p))))

		goal in state || 
			any(apply_op.(find_all(appropriate_p, goal, ops)))
	end
	
	if all(achieve.(goals)) 
		println("Solved")
  		:solved
	else
		println("Not Solved")
		:not_solved
  	end
end

# ╔═╡ 55c13881-e9de-4830-9fa3-7b889f7a2b6e
@kwdef struct Op
	action = nothing
	preconds = ()
	add_list = ()
	del_list = ()
end

# ╔═╡ 2a88cbd1-00e3-4ff9-ab69-f5bbcfd2d6f8
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

# ╔═╡ 7eb36805-799c-4bb3-8e95-880857b4c00e
GPS(
	(:son_at_home, :car_needs_battery, :have_money, :have_phone_book), 
	(:son_at_school), 
	school_ops
)

# ╔═╡ 0825a457-6721-45f9-b55c-67f15583d507
GPS(
	(:son_at_home, :car_needs_battery, :have_money, :know_phone_number), 
	(:son_at_school), 
	school_ops
)

# ╔═╡ 526add69-9922-433b-ab04-57413f2b0b5b
GPS(
	(:son_at_home, :car_works), 
	(:son_at_school), 
	school_ops
)

# ╔═╡ 83cbeea6-2f11-43f6-9770-c3372905e715
(union((:a,:b),(:b,))...,)

# ╔═╡ Cell order:
# ╠═e4af48a2-199a-11ee-391a-1da131422d10
# ╠═7eb36805-799c-4bb3-8e95-880857b4c00e
# ╠═0825a457-6721-45f9-b55c-67f15583d507
# ╠═526add69-9922-433b-ab04-57413f2b0b5b
# ╠═55c13881-e9de-4830-9fa3-7b889f7a2b6e
# ╠═2a88cbd1-00e3-4ff9-ab69-f5bbcfd2d6f8
# ╠═83cbeea6-2f11-43f6-9770-c3372905e715
