### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 2365c12c-769f-4d6e-81f9-fd1cd71121da
using Dates, Parameters

# ╔═╡ 7e001dad-2e72-410e-941c-167979124f14
const ValueTypes = Union{Symbol, Number, Bool, String, Date, Time, DateTime, Nothing}

# ╔═╡ db2ad794-6cd1-4ea6-9fa3-4771942a677e
abstract type AbstractPattern end

# ╔═╡ e06a0e61-b20c-4e1d-969e-81b23d67ae24
struct D <: AbstractPattern
	s::Symbol
end

# ╔═╡ 8b639028-7290-40e4-8188-2f415061f906
struct S <: AbstractPattern
	s::Symbol
end

# ╔═╡ fd82fe3a-6bb3-4b43-8f44-b8629e55ea20
struct G <: AbstractPattern
	s::Any
end

# ╔═╡ 0ee61112-c5e4-4d64-a90d-815994be5c67
function evalenv(expr::Expr, env::Dict{Symbol, Any})
	m = Module(:anonymous, true, true)
	map(x->Base.eval(m, x), [:($k=$(env[k])) for k in keys(env)])
	Base.eval(m, expr)
end

# ╔═╡ 4cbd05ac-b3ee-48ef-9f34-3e0c570890c0
evalenv(:(b+a), Dict{Symbol, Any}(:a => 1, :b => 2))

# ╔═╡ 5d07a077-e490-456e-9422-b89bb784464b
Module()

# ╔═╡ f1dbeb92-e4f3-11ed-07c2-bf355ebf99f7
@generated function match(pat::P, expr::T, env::Dict{Symbol, Any} = Dict{Symbol, Any}()) 	where {P<:Union{ValueTypes, AbstractVector, AbstractDict, Expr, AbstractPattern}, T<:Any}
	
	if pat <: ValueTypes
		return :((pat == expr, env))
	elseif pat <: AbstractPattern
		if pat == D
			return quote
				if haskey(env, pat.s)
					cenv = copy(env)
					c, env = match(env[pat.s], expr, env)
					if c 
						(true, env)
					else
						(false, cenv)
					end
				else
					env[pat.s] = expr
					(true, env)
				end
			end
		elseif pat == S
			return quote
				env[pat.s] = expr
				(true, env)
			end
		end
	elseif pat <: AbstractVector && expr <: AbstractVector
		return quote
			m = length(pat)  
			n = length(expr)
			i = 1
			j = 1
			cenv = copy(env)
			while i <= m 
				if j > n
					return (false, cenv)
				end
				p = pat[i]
				e = expr[j]
				if isa(p, G)
					c, env, l = match_seg(p, expr[j:end])
					if !c 
						return (false, cenv)
					end
					j += l
				else
					c, env = match(p, e, env)
					if !c 
						return (false, cenv)
					end
					j +=1
				end
				i += 1
			end
			
			(true, env)
		end
	elseif pat <: AbstractDict && expr <: AbstractDict
		return quote
			cenv = copy(env)
			for k in keys(pat)
				if !haskey(pat, k)
					return (false, cenv)
				end
				if !haskey(expr, k)
					return (false, cenv)
				end
				c, env = match(pat[k], expr[k], env)
				if !c 
					return (false, cenv)
				end
			end
			(true, env)
		end
	elseif pat == Expr
		return quote
			cenv = copy(env)
			c, env = match(evalenv(pat, env), expr, env)
			if c 
				(true, env)
			else
				(false, cenv)
			end
		end
	else
		return :((false, env))
	end
end

# ╔═╡ 16cc1c61-8587-4115-bc5d-1c3f2106cd37
methods(match)

# ╔═╡ 5c4f2931-3063-45dc-ab09-5abac962645e
function match_seg(pat::G, expr::T, env::Dict{Symbol, Any}) where {T<:AbstractVector}
	if pat.s <: ValueTypes
		return (pat == expr[1], env, 1)
	elseif pat.s <: AbstractVector
		l = length(pat.s) 
		if l <= length(expr)
			c, env = match(pat.s, expr[1:l])
			
		else
			return (false, env, 0)
		end
	else
		for i in eachindex(expr)
		
		end
	end
end

# ╔═╡ 3f0e6a7a-83d6-4945-a10b-62cfb59070a0
### 

# ╔═╡ 8fb7954c-cc46-42a6-b381-f595be254736
### Dict

# ╔═╡ edb92d1b-6a55-401f-a4f2-b4b8af46444e
match(Dict(), Dict())

# ╔═╡ 9d49b6fe-017c-47af-b50a-97673059fefb
match(Dict("a" => 0), Dict())

# ╔═╡ 59fdf08c-9f6c-4145-868f-b636b427ae23
match(Dict("a" => 0), Dict("a" => 0, "b" => 1))

# ╔═╡ 4b229f6e-cd57-44f0-8d59-07f8c40cb0a9
match(Dict("a" => 0, "b" => 2), Dict("a" => 0, "b" => 1))

# ╔═╡ d20b7b49-5fb7-4c08-a381-c37bb6641c30
### Expr

# ╔═╡ b27b3bd1-8409-47ab-9293-e4aa0702a66d
match(:(a+b), 4, Dict{Symbol, Any}(:a => 2, :b => 2))

# ╔═╡ 09b27461-0ca6-4488-a717-479ff5f4504b
match([:(a+b), D(:a)], [4, 2], Dict{Symbol, Any}(:a => 2, :b => 2))

# ╔═╡ 454683d2-6cf6-4aa9-bbe5-acb2b3952550
match([D(:a), D(:b), :(a+b),], [2, 2, 4], Dict{Symbol, Any}())

# ╔═╡ 7c09b942-2435-4e56-a16d-246ace33e29f
### Arrays

# ╔═╡ 202acd4e-96ac-48e2-b8ad-91934917f32f
match([], [])

# ╔═╡ 244c2fa8-1352-4b39-8db2-1b53a3148300
match([:a], [])

# ╔═╡ 0b3f7cc8-ef3f-46df-b556-b0111657826b
match([D(:a)], ["abc"])

# ╔═╡ fc38beec-7faf-43ab-8d03-d5060a4b73ee
match([D(:a), D(:a)], ["abc", "abc"])

# ╔═╡ 9a5671f3-68b5-42b6-b4b2-a011a7935650
match([D(:a), D(:a)], ["abc", "abcd"])

# ╔═╡ 71472dc5-7f11-4b7f-8503-554dffb7fbc7
match([[D(:a), D(:a)]], [["abc", "abc"]])

# ╔═╡ 57239375-c9d7-4eed-9eac-efd10f75e4f5
match([D(:a), S(:a)], ["abc", "abcd"])

# ╔═╡ ee181a5a-d074-4954-a42d-ea1e0493a776
match([D(:a), S(:a), D(:a)], ["abc", "abcd", "abcd"], Dict{Symbol,Any}(:a => "abc"))

# ╔═╡ b6756b9f-34d5-43c1-b98f-fa1bc8cae80a
match([D(:a), S(:a), D(:a)], ["abc", "abcd", ""], Dict{Symbol,Any}(:a => "abc"))

# ╔═╡ 551f878d-8f6e-4187-9205-a0952c3b60c3
### Vars

# ╔═╡ 55bea6d8-185a-4cd5-9065-132f8861de25
match(S(:a), 1)

# ╔═╡ 0d956fc3-c1d7-4dac-9a7b-2662b89a8c7a
match(S(:a), 1, Dict{Symbol,Any}(:a => 1))

# ╔═╡ e4afb970-7f29-40de-956e-e13275db2a13
match(S(:a), 1, Dict{Symbol,Any}(:a => 2))

# ╔═╡ 8a45015a-fdbe-476e-b1de-2d8c6366d741
match(D(:a), 1)

# ╔═╡ 2d7cbdaf-8a07-44af-aee4-6cb6bc513685
match(D(:a), 1, Dict{Symbol,Any}(:a => 1))

# ╔═╡ 63963634-c0ca-4a85-8c3a-72fe2eb466b2
match(D(:a), 1, Dict{Symbol,Any}(:a => 2))

# ╔═╡ 27da2722-66f1-4815-9c23-393ede4d3d71
all([x[1] for x in [
	match(:x, :x),
	match(1, 1),
	match(false, false),
	match("abc", "abc"),
	match(Date("2023-01-01"), Date("2023-01-01")),
	match(Time("12:00:00"), Time("12:00:00")),
	match(DateTime("2023-01-01T12:00:00"), DateTime("2023-01-01T12:00:00")),
	match(nothing, nothing),
]])

# ╔═╡ 5a1d7cf6-27ee-4b94-abdd-7e7467ce63ad
all([!x[1] for x in [
	match(:x, :y),
	match(1, 2),
	match(true, false),
	match("abc", "def"),
	match(Date("2023-01-01"), Date("2023-01-02")),
	match(Time("12:00:00"), Time("12:00:01")),
	match(DateTime("2023-01-01T12:00:00"), DateTime("2023-01-01T12:00:01")),
	match(nothing, 0),
	match(1, 2.0),
]])

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Parameters = "d96e819e-fc66-5662-9728-84c9c7592b0a"

[compat]
Parameters = "~0.12.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "f10e9e598f8fb8734382facd2815549f93c3145e"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
"""

# ╔═╡ Cell order:
# ╠═2365c12c-769f-4d6e-81f9-fd1cd71121da
# ╠═7e001dad-2e72-410e-941c-167979124f14
# ╠═db2ad794-6cd1-4ea6-9fa3-4771942a677e
# ╠═e06a0e61-b20c-4e1d-969e-81b23d67ae24
# ╠═8b639028-7290-40e4-8188-2f415061f906
# ╠═fd82fe3a-6bb3-4b43-8f44-b8629e55ea20
# ╠═0ee61112-c5e4-4d64-a90d-815994be5c67
# ╠═4cbd05ac-b3ee-48ef-9f34-3e0c570890c0
# ╠═5d07a077-e490-456e-9422-b89bb784464b
# ╠═f1dbeb92-e4f3-11ed-07c2-bf355ebf99f7
# ╠═16cc1c61-8587-4115-bc5d-1c3f2106cd37
# ╠═5c4f2931-3063-45dc-ab09-5abac962645e
# ╠═3f0e6a7a-83d6-4945-a10b-62cfb59070a0
# ╠═8fb7954c-cc46-42a6-b381-f595be254736
# ╠═edb92d1b-6a55-401f-a4f2-b4b8af46444e
# ╠═9d49b6fe-017c-47af-b50a-97673059fefb
# ╠═59fdf08c-9f6c-4145-868f-b636b427ae23
# ╠═4b229f6e-cd57-44f0-8d59-07f8c40cb0a9
# ╠═d20b7b49-5fb7-4c08-a381-c37bb6641c30
# ╠═b27b3bd1-8409-47ab-9293-e4aa0702a66d
# ╠═09b27461-0ca6-4488-a717-479ff5f4504b
# ╠═454683d2-6cf6-4aa9-bbe5-acb2b3952550
# ╠═7c09b942-2435-4e56-a16d-246ace33e29f
# ╠═202acd4e-96ac-48e2-b8ad-91934917f32f
# ╠═244c2fa8-1352-4b39-8db2-1b53a3148300
# ╠═0b3f7cc8-ef3f-46df-b556-b0111657826b
# ╠═fc38beec-7faf-43ab-8d03-d5060a4b73ee
# ╠═9a5671f3-68b5-42b6-b4b2-a011a7935650
# ╠═71472dc5-7f11-4b7f-8503-554dffb7fbc7
# ╠═57239375-c9d7-4eed-9eac-efd10f75e4f5
# ╠═ee181a5a-d074-4954-a42d-ea1e0493a776
# ╠═b6756b9f-34d5-43c1-b98f-fa1bc8cae80a
# ╠═551f878d-8f6e-4187-9205-a0952c3b60c3
# ╠═55bea6d8-185a-4cd5-9065-132f8861de25
# ╠═0d956fc3-c1d7-4dac-9a7b-2662b89a8c7a
# ╠═e4afb970-7f29-40de-956e-e13275db2a13
# ╠═8a45015a-fdbe-476e-b1de-2d8c6366d741
# ╠═2d7cbdaf-8a07-44af-aee4-6cb6bc513685
# ╠═63963634-c0ca-4a85-8c3a-72fe2eb466b2
# ╠═27da2722-66f1-4815-9c23-393ede4d3d71
# ╠═5a1d7cf6-27ee-4b94-abdd-7e7467ce63ad
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
