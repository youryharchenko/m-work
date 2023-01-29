
using GraphPlot, Graphs, Colors

function meta_to_graph(kb::KBs.KBase)
		
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

	g = Graphs.DiGraph(length(vks))

	
	edgc = Dict()
	edgl = Dict()
		
	
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