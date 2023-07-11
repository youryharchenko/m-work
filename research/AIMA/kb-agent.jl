### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 8093b436-ab84-4c27-bf04-55ad0078db94
@kwdef mutable struct Env
	KB = nothing
	t = 0
end

# ╔═╡ 3f20295a-1fd1-11ee-2368-13737d89983d
function KB_agent(env, percept)
	tell(env.KB, make_percept_sentence(percept, env.t))
	action = ask(env.KB, make_action_query(env.t))
	tell(env.KB, make_action_sentence(action, env.t))
	action
end

# ╔═╡ Cell order:
# ╠═8093b436-ab84-4c27-bf04-55ad0078db94
# ╠═3f20295a-1fd1-11ee-2368-13737d89983d
