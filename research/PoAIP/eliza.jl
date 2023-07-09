### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 241370aa-7ebd-4a49-b036-ddaa3d316324
mutable struct Result
	vars::Dict{Symbol, Any}
	succ::Bool
end

# ╔═╡ 2fda8f26-1d74-11ee-144e-eb6252bd077a
function variable_p(x)
	# (defun variable-p (x)
  	# 	"Is x a variable (a symbol beginning with `?')?"
  	# 	(and (symbolp x) (equal (elt (symbol-name x) 0) #\?)))

	x isa Symbol && String(x)[1] == '?'
end

# ╔═╡ 80d592b1-fea7-4fb9-9b34-7e391f266d2a
function var(s)
	Symbol("?$s")
end

# ╔═╡ a8f1af56-8ba7-43d3-aeee-0237e81a5cbf
function seg(var)
	((Symbol("?*"), var))
end

# ╔═╡ 4c80dc9c-2786-4b66-8e26-eb0944ced0ff
function iterable_p(x)
	applicable(length, x)
end

# ╔═╡ d3da6eee-6002-46f0-9f57-cc697faa87e0
function match_variable(var, input, bindings)
	# (defun match-variable (var input bindings)
  	# 	"Does VAR match input?  Uses (or updates) and returns bindings."
  	# 	(let ((binding (get-binding var bindings)))
    # 		(cond ((not binding) (extend-bindings var input bindings))
    #       		((equal input (binding-val binding)) bindings)
    #       		(t fail))))

	if haskey(bindings.vars, var)
		if bindings.vars[var] != input
			bindings.succ = false
		end
	else
		bindings.vars[var] = input
	end
	bindings
end

# ╔═╡ 6fda8747-f5de-45f6-bb4d-ddc2fc7fa817
function segment_pattern_p(pattern)
	# (defun segment-pattern-p (pattern)
  	# 	"Is this a segment matching pattern: ((?* var) . pat)"
  	# 	(and (consp pattern)
    #    		(starts-with (first pattern) '?*)))
	if iterable_p(pattern) && length(pattern) == 2 
		x = pattern[1]
		x isa Symbol && startswith(String(x), "?*") && variable_p(pattern[2])
	else
		false
	end

end

# ╔═╡ 0d452a5d-186f-42aa-a797-c00556124b5d
function segment_match(pattern, input, bindings, start=1)
	# (defun segment-match (pattern input bindings &optional (start 0))
  	# 	"Match the segment pattern ((?* var) . pat) against input."
  	# 	(let ((var (second (first pattern))) (pat (rest pattern)))
    # 		(if (null pat)
    #     		(match-variable var input bindings)
    #     		;; We assume that pat starts with a constant
    #     		;; In other words, a pattern can't have 2 consecutive vars
    #     		(let ((pos (position (first pat) input
    #                          :start start :test #'equal)))
    #       			(if (null pos)
    #           			fail
    #           			(let ((b2 (pat-match pat (subseq input pos) bindings)))
    #            				;; If this match failed, try another longer one
    #             				;; If it worked, check that the variables match
    #             				(if (eq b2 fail)
    #                 				(segment-match pattern input bindings (+ pos 1))
    #                 				(match-variable var (subseq input 0 pos) 			# 									b2))))))))

	if length(pattern) == 0
		return bindings 
	end
	
	var = pattern[1][2]
	pat = pattern[2:end]
	
	if length(pat) == 0
		println("segment_match :: pat: $pat is empty -> match_variable")
		match_variable(var, input, bindings)
	else
		subseq = input[start:end]
		println("segment_match :: pat: $pat, input: $subseq")
		pos = findfirst(isequal(pat[1]), subseq)
		if isnothing(pos)
			println("segment_match :: isnothing(pos) == true")
			if variable_p(pat[1])
				println("segment_match :: isnothing(pos) variable_p(pat[1]) == true -> return segment_match")
				
				segment_match(pat[2:end], subseq[2:end], match_variable(pat[1], subseq[1], bindings), start+1)
			else
				println("segment_match :: isnothing(pos) else -> return fail")
				bindings.succ = false
				bindings
			end
		else
			println("segment_match :: pos: $pos  -> pat_match")
			b2 = pat_match(pat, input[pos:end], bindings)
			if b2.succ
				println("segment_match :: b2.succ: $(b2.succ)  -> match_variable")
				match_variable(var, input[1:pos-1], b2)
			else
				println("segment_match :: b2.succ: $(b2.succ)  -> segment_match")
				segment_match(pattern, input, bindings, pos+1)
			end
		end
	end
	
end

# ╔═╡ e7ef52f3-44a4-449b-9ddb-c3ae6c83208d
function pat_match(pattern, input, bindings=Result(Dict{Symbol, Any}(), true))
	# (defun pat-match (pattern input &optional (bindings no-bindings))
  	# 	"Match pattern against input in the context of the bindings"
  	# 	(cond ((eq bindings fail) fail)
    #     	((variable-p pattern)
    #      		(match-variable pattern input bindings))
    #     	((eql pattern input) bindings)
    #     	((segment-pattern-p pattern)                ; ***
    #      		(segment-match pattern input bindings))    ; ***
    #     	((and (consp pattern) (consp input))
    #      		(pat-match (rest pattern) (rest input)
    #                 (pat-match (first pattern) (first input)
    #                            bindings)))
    #     	(t fail)))

	if !bindings.succ
		println("pat_match :: succ: $(bindings.succ)  -> return")
		bindings
	elseif variable_p(pattern)
		println("pat_match :: variable_p(pattern) == true   -> match_variable")
		match_variable(pattern, input, bindings)
	elseif pattern == input
		bindings
	#elseif segment_pattern_p(pattern)
	#	println("pat_match :: segment_pattern_p(pattern) == true   -> segment_match")
	#	segment_match(pattern, input, bindings)
	elseif iterable_p(pattern) && iterable_p(input) && 
		length(pattern) > 0 && length(input) > 0
		
		println("pat_match :: iterable == true (pattern[1]: $(pattern[1]))")
		if segment_pattern_p(pattern[1])
			println("pat_match :: segment_pattern_p == true -> segment_match")
			segment_match(pattern, input, bindings)
		else
			println("pat_match :: else -> iterate pat_match")
			pat_match(pattern[2:end], input[2:end],
				pat_match(pattern[1], input[1], bindings))
		end
	else
		println("pat_match :: else (pattern: $pattern, input: $input)  -> return fail")
		bindings.succ = false
		bindings
	end
	
end

# ╔═╡ ac2fc16e-7ee0-4b9a-8510-b3dd146486f5


# ╔═╡ 637a7d2c-5725-4839-9c3f-2dcb36367114
let
	all((
		pat_match(1, 1).succ,
		pat_match(:a, :a).succ,
		pat_match([], []).succ,
		let
			env = pat_match(var(:a), :b)
			all((
				env.succ,
				pat_match(var(:a), :b, env).succ,
				!pat_match(var(:a), :c, env).succ,
			))
		end,
		let
			env = pat_match((seg(var(:a)),), (:c,))
			all((
				env.succ,
				pat_match((seg(var(:a)),), (:c,), env).succ,
				!pat_match((seg(var(:a)),), (:d,), env).succ,
			))
		end,
		pat_match((seg(var(:a)),), (:c, :d)).succ,
		pat_match((seg(var(:p)), :need, seg(var(:x))),
			(:Mr, :Hulot, :and, :I, :need, :a, :vacation)).succ,
		pat_match((:what, :he, :is, :a, :fool, :(!)),
			(:what, :he, :is, :a, :fool, :(!))).succ,
		pat_match((:what, :he, :is, :a, :fool, var(:x)),
			(:what, :he, :is, :a, :fool, :(!))).succ,
		pat_match((var(:x), :he, :is, :a, :fool, var(:y)),
			(:what, :he, :is, :a, :fool, :(!))).succ,
		pat_match((var(:x), :b, :c, :b, var(:x)),
			(:a, :b, :c, :b, :a)).succ,
		pat_match((var(:x), var(:y), :c, var(:y), var(:x)),
			(:a, :b, :c, :b, :a)).succ,
		pat_match((seg(var(:x)), :c, seg(var(:x))),
			(:a, :b, :c, :a, :b)).succ,
		pat_match((seg(var(:x)),),
			(:a, :b, :a, :b)).succ,
		pat_match((:what, seg(var(:x)), :is, seg(var(:y)), :fool, seg(var(:z))), 
			(:what, :he, :is, :a, :fool, :(!))).succ,
	
	))
end

# ╔═╡ 64972166-4a00-4817-b0c9-6ded4706dffd
(seg(var(:a)),)

# ╔═╡ d111e474-df3a-4eb7-8ba6-b61b5e24b6f3
(seg(var(:p)), :need, seg(var(:x)))

# ╔═╡ 24fe221f-dd12-470b-8121-2b0f0bc267d3
pat_match((seg(var(:x)), var(:y)), 
	(:a, :b, :a, :b))

# ╔═╡ 16f75817-a5e7-4f00-880d-b35236adcdf0
pat_match((seg(var(:x)), seg(var(:y))), 
	(:a, :b, :a, :b))

# ╔═╡ 05b8c7b4-201c-4332-b457-b0744038a187
variable_p(var(:a))

# ╔═╡ 5e6ab8c2-9a37-4049-b134-8b1f1e4899aa
var(:a)

# ╔═╡ 20920cdb-4046-42fb-99b2-1ac1e293a1c1
variable_p(var("a"))

# ╔═╡ a2f4b0ea-bf59-413f-b3d8-00bde606613e
var(Symbol("?a"))

# ╔═╡ c948a01c-bb1f-4165-8653-b7689454ab36
segment_pattern_p(:a)

# ╔═╡ 77e7042c-623f-4784-a597-4df0fe808ae3
seg(var(:a))

# ╔═╡ c2b75e63-2c64-451e-9566-99524b12b50d
seg(var(:a))[2:end]

# ╔═╡ 980fc9fc-203f-4787-a0fd-99f0d32a1527
seg(var(:a))

# ╔═╡ c245129c-cc94-4035-8901-26676c4bf7e6
seg(var(:a))[2:end]

# ╔═╡ 55f32ab1-9064-4fda-a380-86b19fb76344
segment_pattern_p(seg(var(:a)))

# ╔═╡ 55401198-7e26-4951-9d58-c57fb16245da
segment_pattern_p(seg(var(:a)))

# ╔═╡ 8e47a83d-3973-4200-8c0e-c700d6548779
segment_pattern_p((seg(:a)))

# ╔═╡ c3cefcd1-8a47-4f17-9a7f-07be367bcb25
findfirst(isequal(:c), (:a, :b))

# ╔═╡ Cell order:
# ╠═241370aa-7ebd-4a49-b036-ddaa3d316324
# ╠═2fda8f26-1d74-11ee-144e-eb6252bd077a
# ╠═80d592b1-fea7-4fb9-9b34-7e391f266d2a
# ╠═a8f1af56-8ba7-43d3-aeee-0237e81a5cbf
# ╠═4c80dc9c-2786-4b66-8e26-eb0944ced0ff
# ╠═e7ef52f3-44a4-449b-9ddb-c3ae6c83208d
# ╠═d3da6eee-6002-46f0-9f57-cc697faa87e0
# ╠═6fda8747-f5de-45f6-bb4d-ddc2fc7fa817
# ╠═0d452a5d-186f-42aa-a797-c00556124b5d
# ╠═ac2fc16e-7ee0-4b9a-8510-b3dd146486f5
# ╠═637a7d2c-5725-4839-9c3f-2dcb36367114
# ╠═64972166-4a00-4817-b0c9-6ded4706dffd
# ╠═d111e474-df3a-4eb7-8ba6-b61b5e24b6f3
# ╠═24fe221f-dd12-470b-8121-2b0f0bc267d3
# ╠═16f75817-a5e7-4f00-880d-b35236adcdf0
# ╠═05b8c7b4-201c-4332-b457-b0744038a187
# ╠═5e6ab8c2-9a37-4049-b134-8b1f1e4899aa
# ╠═20920cdb-4046-42fb-99b2-1ac1e293a1c1
# ╠═a2f4b0ea-bf59-413f-b3d8-00bde606613e
# ╠═c948a01c-bb1f-4165-8653-b7689454ab36
# ╠═77e7042c-623f-4784-a597-4df0fe808ae3
# ╠═c2b75e63-2c64-451e-9566-99524b12b50d
# ╠═980fc9fc-203f-4787-a0fd-99f0d32a1527
# ╠═c245129c-cc94-4035-8901-26676c4bf7e6
# ╠═55f32ab1-9064-4fda-a380-86b19fb76344
# ╠═55401198-7e26-4951-9d58-c57fb16245da
# ╠═8e47a83d-3973-4200-8c0e-c700d6548779
# ╠═c3cefcd1-8a47-4f17-9a7f-07be367bcb25
