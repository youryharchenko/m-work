### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 764c2d2c-9f00-11ed-1552-bfa8b0311eed
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	Pkg.instantiate()
	#Pkg.add("Revise")
	Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ e9334917-b750-4dd4-a24c-e39ed646abab
using KBs, GraphPlot, Graphs, Colors

# ╔═╡ 29b46826-cdff-407f-b341-484be5241052
dir = "mwork08/save"

# ╔═╡ 28be0d34-6920-4ade-8444-f06e09f44d4c
kb = load(dir)

# ╔═╡ 4f1cbe08-0eca-42be-81ff-b2d0a2f9beb2
begin

@c! kb :test_cat (
	ac=[(a=:test_attr_1, v=true), (a=:test_attr_2, v=false)],
	rct=[(r=:test_rel, ct=:test_cat_to)],
	rcf=[(r=:test_rel, cf=:test_cat_from)],
	arct=[(r=:test_rel, ct=:test_cat_to, a=:test_attr_3, v=0)],
	arcf=[(r=:test_rel, cf=:test_cat_from, a=:test_attr_3, v=0)],
)

@r! kb :test_rel (
	ar=[(a=:test_attr_3, v=nothing)],
	rc=[(cf=:test_cat, ct=:test_cat_to)],
	arc=[(cf=:test_cat, ct=:test_cat_to, a=:test_attr_3, v=1)],
)

@o! kb :test_obj_1 (
	co=[(c=:test_cat,)],
	aco=[(c=:test_cat, a=:test_attr_1, v=2)],
	rcof=[(c=:test_cat, r=:test_rel, cf=:test_cat_from, of=:test_obj_2)],
	arcof=[(c=:test_cat, r=:test_rel, cf=:test_cat_from, of=:test_obj_2, a=:test_attr_3, v=3)],
)

@o! kb :test_obj_2 (
	co=[(c=:test_cat,)],
	aco=[(c=:test_cat, a=:test_attr_3, v=5)],
	rcot=[(c=:test_cat, r=:test_rel, ct=:test_cat_to, ot=:test_obj_3)],
	arcot=[(c=:test_cat, r=:test_rel, ct=:test_cat_to, ot=:test_obj_3, a=:test_attr_3, v=5)],
)
	
end;

# ╔═╡ 5da5f401-c0e5-4c6e-8db3-84e625e986d9
select(CO, kb)

# ╔═╡ 9f24c761-c0ed-4156-aa2d-84ce6aa9ebd3
select(RC, kb)

# ╔═╡ fe187811-8d04-43d3-8ebc-4375c66ecefd
function meta_to_graph_(kb::KBs.KBase)
		
	c_keys = collect(keys(kb.c))
	r_keys = collect(keys(kb.r))
	rc_keys = collect(keys(kb.rc))
	a_keys = collect(keys(kb.a))
	ac_keys = collect(keys(kb.ac))
	ar_keys = collect(keys(kb.ar))
	arc_keys = collect(keys(kb.arc))

	vks = vcat(c_keys, r_keys, rc_keys, a_keys, ac_keys, ar_keys, arc_keys)

	dg = Dict()
	nodelabel = fill("", length(vks))
	nodefillc = fill(colorant"white", length(vks))
	
	for (i, k)  in enumerate(vks)
		dg[k]=i
	end

	for k in c_keys
		nodelabel[dg[k]] = "$(value(kb, value(kb, k).v).value)"
		nodefillc[dg[k]] = colorant"lightblue"
	end

	for k in r_keys
		nodelabel[dg[k]] = "$(value(kb, value(kb, k).v).value)"
		nodefillc[dg[k]] = colorant"lightcoral"
	end
	
	for k in rc_keys
		#nodelabel[dg[k]] = "$(value(kb, value(kb, value(kb, k).o).v).value)::$(value(kb, value(kb, value(kb, k).c).v).value)"
		nodelabel[dg[k]] = "RC"
		nodefillc[dg[k]] = colorant"lightcyan"
	end

	for k in a_keys
		nodelabel[dg[k]] = "$(value(kb, value(kb, k).v).value)"
		nodefillc[dg[k]] = colorant"lightyellow"
	end

	for k in ac_keys
		nodelabel[dg[k]] = "AC($(value(kb, value(kb, k).v).value))"
		nodefillc[dg[k]] = colorant"lightgoldenrod"
	end

	for k in ar_keys
		nodelabel[dg[k]] = "AR($(value(kb, value(kb, k).v).value))"
		nodefillc[dg[k]] = colorant"lightgoldenrod3"
	end

	for k in arc_keys
		nodelabel[dg[k]] = "ARC($(value(kb, value(kb, k).v).value))"
		nodefillc[dg[k]] = colorant"lightgoldenrod1"
	end

	#dg

	g = Graphs.DiGraph(length(vks))

	#co_keys = collect(keys(kb.co))
	#rc_keys = collect(keys(kb.rc))

	#eks = vcat(co_keys, rc_keys)

	edgc = Dict()
	edgl = Dict()
		
	#for (i, k) in enumerate(co_keys)
	#	add_edge!(g, dg[kb.co[k].o], dg[kb.co[k].c])
	#	edgc[(dg[kb.co[k].o], dg[kb.co[k].c])] = colorant"blue"
	#end

	for (i, k) in enumerate(rc_keys)
		add_edge!(g, dg[k], dg[kb.rc[k].r])
		edgc[(dg[k], dg[kb.rc[k].r])] = colorant"red"
		edgl[(dg[k], dg[kb.rc[k].r])] = "rel"
		
		add_edge!(g, dg[k], dg[kb.rc[k].cf])
		edgc[(dg[k], dg[kb.rc[k].cf])] = colorant"cyan"
		edgl[(dg[k], dg[kb.rc[k].cf])] = "from"
		
		add_edge!(g, dg[k], dg[kb.rc[k].ct])
		edgc[(dg[k], dg[kb.rc[k].ct])] = colorant"magenta"
		edgl[(dg[k], dg[kb.rc[k].ct])] = "to"
	end

	for (i, k) in enumerate(ac_keys)
		add_edge!(g, dg[k], dg[kb.ac[k].c])
		edgc[(dg[k], dg[kb.ac[k].c])] = colorant"orange"
		edgl[(dg[k], dg[kb.ac[k].c])] = "cat"
		
		add_edge!(g, dg[k], dg[kb.ac[k].a])
		edgc[(dg[k], dg[kb.ac[k].a])] = colorant"lime"
		edgl[(dg[k], dg[kb.ac[k].a])] = "attr"
	end

	for (i, k) in enumerate(ar_keys)
		add_edge!(g, dg[k], dg[kb.ar[k].r])
		edgc[(dg[k], dg[kb.ar[k].r])] = colorant"orange"
		edgl[(dg[k], dg[kb.ar[k].r])] = "rel"
		
		add_edge!(g, dg[k], dg[kb.ar[k].a])
		edgc[(dg[k], dg[kb.ar[k].a])] = colorant"lime"
		edgl[(dg[k], dg[kb.ar[k].a])] = "attr"
	end

	for (i, k) in enumerate(arc_keys)
		add_edge!(g, dg[k], dg[kb.arc[k].rc])
		edgc[(dg[k], dg[kb.arc[k].rc])] = colorant"orange"
		edgl[(dg[k], dg[kb.arc[k].rc])] = "rel"
		
		add_edge!(g, dg[k], dg[kb.arc[k].ar])
		edgc[(dg[k], dg[kb.arc[k].ar])] = colorant"lime"
		edgl[(dg[k], dg[kb.arc[k].ar])] = "attr"
	end

	edgestrokec = fill(colorant"grey", ne(g))
	edgelabel = fill("", ne(g))
	for (i, e) in enumerate(edges(g))
		edgestrokec[i] = edgc[(src(e), dst(e))]
		edgelabel[i] = edgl[(src(e), dst(e))]
	end
	
		
	(
		g = g, 
		nodelabel=nodelabel,
		nodefillc=nodefillc,
		edgelabel=edgelabel,
		edgestrokec=edgestrokec,
	)
end

# ╔═╡ 65ae5537-aca1-4f8e-8ec5-1c5c0b27cff3
g = meta_to_graph(kb)

# ╔═╡ 817d6e03-ee61-4770-b227-e14a4a2c059a
collect(edges(g.g))

# ╔═╡ 24b64e25-f30d-41fb-9673-7cff3c2c8b0c
collect(vertices(g.g))

# ╔═╡ d9ed566f-9522-43e4-97a7-8dfff86040b0
gplot(g.g; 
	nodelabel=g.nodelabel, 
	nodefillc=g.nodefillc,  
	edgelabel=g.edgelabel, 
	edgestrokec=g.edgestrokec, 
	#layout = (args...)->spring_layout(args...; C=20)
	layout = circular_layout
	
) 

# ╔═╡ 21fadee0-5a97-456f-8e4f-65ce6c14df2a
function to_graph(kb::KBs.KBase)
		
	c_keys = collect(keys(kb.c))
	o_keys = collect(keys(kb.o))
	r_keys = collect(keys(kb.r))
	
	

	vks = vcat(c_keys, o_keys)

	dg = Dict()
	nodelabel = fill("", length(vks))
	nodefillc = fill(colorant"white", length(vks))
	
	for (i, k)  in enumerate(vks)
		dg[k]=i
	end

	for k in c_keys
		nodelabel[dg[k]] = "$(value(kb, value(kb, k).v).value)"
		nodefillc[dg[k]] = colorant"lightblue"
	end

	for k in o_keys
		nodelabel[dg[k]] = "$(value(kb, value(kb, k).v).value)"
		nodefillc[dg[k]] = colorant"lightgrey"
	end
	
	#for k in co_keys
		#nodelabel[dg[k]] = "$(value(kb, value(kb, value(kb, k).o).v).value)::$(value(kb, value(kb, value(kb, k).c).v).value)"
		#nodelabel[dg[k]] = "CO"
	#end

	#dg

	g = Graphs.DiGraph(length(vks))

	co_keys = collect(keys(kb.co))
	rc_keys = collect(keys(kb.rc))

	eks = vcat(co_keys, rc_keys)

	edgc = Dict()
	edgestrokec = fill(colorant"grey", length(eks))
	edgelabel = fill("", length(eks))
	
	for (i, k) in enumerate(co_keys)
		add_edge!(g, dg[kb.co[k].o], dg[kb.co[k].c])
		edgc[(dg[kb.co[k].o], dg[kb.co[k].c])] = colorant"blue"
	end

	for (i, k) in enumerate(rc_keys)
		add_edge!(g, dg[kb.rc[k].cf], dg[kb.rc[k].ct])
		edgc[(dg[kb.rc[k].cf], dg[kb.rc[k].ct])] = colorant"red"
	end

	for (i, e) in enumerate(edges(g))
		edgestrokec[i] = edgc[(src(e), dst(e))]
		#edgelabel[i] = "$i($e)"
	end
	
		
	(
		g = g, 
		nodelabel=nodelabel,
		nodefillc=nodefillc,
		#edgelabel=edgelabel,
		edgestrokec=edgestrokec,
	)
end

# ╔═╡ af6af214-29b3-40d4-ae34-e30c5257a3a0
colorant"lightmagenta"

# ╔═╡ Cell order:
# ╠═764c2d2c-9f00-11ed-1552-bfa8b0311eed
# ╠═e9334917-b750-4dd4-a24c-e39ed646abab
# ╠═29b46826-cdff-407f-b341-484be5241052
# ╠═28be0d34-6920-4ade-8444-f06e09f44d4c
# ╠═4f1cbe08-0eca-42be-81ff-b2d0a2f9beb2
# ╠═5da5f401-c0e5-4c6e-8db3-84e625e986d9
# ╠═9f24c761-c0ed-4156-aa2d-84ce6aa9ebd3
# ╠═fe187811-8d04-43d3-8ebc-4375c66ecefd
# ╠═65ae5537-aca1-4f8e-8ec5-1c5c0b27cff3
# ╠═817d6e03-ee61-4770-b227-e14a4a2c059a
# ╠═24b64e25-f30d-41fb-9673-7cff3c2c8b0c
# ╠═d9ed566f-9522-43e4-97a7-8dfff86040b0
# ╠═21fadee0-5a97-456f-8e4f-65ce6c14df2a
# ╠═af6af214-29b3-40d4-ae34-e30c5257a3a0
