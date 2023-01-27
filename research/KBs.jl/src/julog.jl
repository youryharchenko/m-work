using Julog

function to_clauses(kb::KBase)
    sets = (V, C, O, CO, R, RC, RCO, A, AC,  AR, ACO, ARC, ARCO)
    clauses = Clause[]
	for s in sets
		clauses = vcat(clauses, set2clauses(kb, s))
	end
    clauses
end

function set2clauses(kb, s)
    sym = Symbol(lowercase(replace(string(s), "KBs."=>"")))
    flds = fieldnames(s)
    d = getfield(kb, sym)
    ks = keys(d)
	clauses = Vector{Julog.Clause}(undef, length(ks))
	i = 0
	for k in ks
		i+=1
		clauses[i] = Clause(
			Compound(sym, vcat(Const(k), [Const(getfield(d[k], f)) for f in flds])), [])
	end
	clauses
end