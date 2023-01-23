
function _g(args, ind)
	for a in args
		if a.args[1] == ind 
			return (a.args[2] isa QuoteNode) ? a.args[2].value : a.args[2]
		end
	end
end

function _av(a, v)
	#dump(t)
	a => v
end

function _arg1(a)
	if a isa Symbol
		esc(a)
	else
		a
	end
end

macro c!(kb, args...)
    la = length(args)
    kb = esc(kb)
	#dump(args[1])
	if la == 1
		#c = args[1]
		c = _arg1(args[1])
		#dump(c)
    	:(make!(C, $(kb), $c))
	elseif la == 2
		#c = args[1]
		c = _arg1(args[1])
		#dump(c)
		#dump(args[2])
		ks = [arg.args[1] for arg in args[2].args]
		#dump(ks)
		vs = [arg.args[2].args for arg in args[2].args]
		#dump(vs)
		quote
			cid = make!(C, $(kb), $c)
			tps = [$(ks)...]
			#dump(tps)
			llst = [$(vs)...]
			#dump(llst)
			for i in eachindex(tps)
				if tps[i] == :ac
					for v in llst[i]
						#dump(v.args)
						a = make!(A, $(kb), _g(v.args, :a))
						make!(AC, $(kb), cid, a, _g(v.args, :v))
					end
				end
				if tps[i] == :rct
					for v in llst[i]
                        r = make!(R, $(kb), _g(v.args, :r))
						ct = make!(C, $(kb), _g(v.args, :ct))
						make!(RC, $(kb), r, cid, ct)
					end
				end
                if tps[i] == :rcf
					for v in llst[i]
                        r = make!(R, $(kb), _g(v.args, :r))
						cf = make!(C, $(kb), _g(v.args, :cf))
						make!(RC, $(kb), r, cf, cid)
					end
				end
                if tps[i] == :arct
					for v in llst[i]
                        r = make!(R, $(kb), _g(v.args, :r))
						ct = make!(C, $(kb), _g(v.args, :ct))
						rc = make!(RC, $(kb), r, cid, ct)
                        a = make!(A, $(kb), _g(v.args, :a))
						ar = make!(AR, $(kb), r, a, _g(v.args, :v))
                        make!(ARC, $(kb), rc, ar, _g(v.args, :v))
					end
				end
                if tps[i] == :arcf
					for v in llst[i]
                        r = make!(R, $(kb), _g(v.args, :r))
						cf = make!(C, $(kb), _g(v.args, :cf))
						rc = make!(RC, $(kb), r, cf, cid)
                        a = make!(A, $(kb), _g(v.args, :a))
						ar = make!(AR, $(kb), r, a, _g(v.args, :v))
                        make!(ARC, $(kb), rc, ar, _g(v.args, :v))
					end
				end
			end
            cid
		end
    else
        error("must be 2 or 3 arguments")
	end
end

macro c(kb, args...)
	la = length(args)
    kb = esc(kb)
	if la == 1
		#c = args[1]
		c = _arg1(args[1])
		#dump(c)
    	quote 
			vid = id($(kb), $c)
			cid = id($(kb), C(vid))
			c = value($(kb), cid)
			ac = (;[_av((a=value($(kb), value($(kb), k.a).v).value,
				v=value($(kb), value($(kb), id($(kb), k)).v).value,)...) 
				for k in keys($(kb).aci) if k.c == cid]...)
			#co = tuple([(o=value($(kb), value($(kb), k.o).v).value,) for k in keys($(kb).coi) if k.c == cid]...)
			rct = tuple([(r=value($(kb), value($(kb), k.r).v).value, ct=value($(kb), value($(kb), k.ct).v).value) 
				for k in keys($(kb).rci) if k.cf == cid]...)
			rcf = tuple([(r=value($(kb), value($(kb), k.r).v).value, ct=value($(kb), value($(kb), k.cf).v).value) 
				for k in keys($(kb).rci) if k.ct == cid]...) 
			(c=$c, ac=ac, rct=rct, rcf=rcf)
		end
	else
        error("must be 2 arguments")
	end
end

macro co(kb, args...)
	la = length(args)
    kb = esc(kb)
	if la == 1
		#c = args[1]
		c = _arg1(args[1])
    	quote 
			vid = id($(kb), $c)
			cid = id($(kb), C(vid))
			c = value($(kb), cid)
			co = tuple([(o=value($(kb), value($(kb), k.o).v).value,
				aco = (; [_av((a=value($(kb), value($(kb), value($(kb), kco.ac).a).v).value,
					v=value($(kb), value($(kb), id($(kb), kco)).v).value,)...) 
					for kco in keys($(kb).acoi) if kco.co == id($(kb), CO(cid, k.o))]...),
				) for k in keys($(kb).coi) if k.c == cid]...)
			(c=$c, co=co)
		end
	else
        error("must be 2 arguments")
	end
end

macro r!(kb, args...)
    la = length(args)
    kb = esc(kb)
	if la == 1
		#r = args[1]
		r = _arg1(args[1])
    	:(make!(R, $(kb), $r))
	elseif la == 2
		#r = args[1]
		r = _arg1(args[1])
		#dump(args[2])
		ks = [arg.args[1] for arg in args[2].args]
		#dump(ks)
		vs = [arg.args[2].args for arg in args[2].args]
		#dump(vs)
		quote
			rid = make!(R, $(kb), $r)
			tps = [$(ks)...]
			#dump(tps)
			llst = [$(vs)...]
			#dump(llst)
			for i in eachindex(tps)
				if tps[i] == :ar
					for v in llst[i]
						a = make!(A, $(kb), _g(v.args, :a))
						make!(AR, $(kb), rid, a, _g(v.args, :v))
					end
				end
                if tps[i] == :rc
					for v in llst[i]
						cf = make!(C, $(kb), _g(v.args, :cf))
                        ct = make!(C, $(kb), _g(v.args, :ct))
						make!(RC, $(kb), rid, cf, ct)
					end
				end
                if tps[i] == :arc
					for v in llst[i]
						cf = make!(C, $(kb), _g(v.args, :cf))
                        ct = make!(C, $(kb), _g(v.args, :ct))
                        rc = make!(RC, $(kb), rid, cf, ct)
                        a = make!(A, $(kb), _g(v.args, :a))
                        ar = make!(AR, $(kb), rid, a, _g(v.args, :v))
                        make!(ARC, $(kb), rc, ar, _g(v.args, :v))
					end
				end
			end
            rid
		end
    else
        error("must be 2 or 3 arguments")
	end
end

macro r(kb, args...)
	la = length(args)
    kb = esc(kb)
	if la == 1
		#r = args[1]
		r = _arg1(args[1])
    	quote 
			vid = id($(kb), $r)
			rid = id($(kb), R(vid))
			r = value($(kb), rid)
			ar = (;[_av((a=value($(kb), value($(kb), k.a).v).value,
				v=value($(kb), value($(kb), id($(kb), k)).v).value,)...) 
				for k in keys($(kb).ari) if k.r == rid]...)
			rc = tuple([(cf=value($(kb), value($(kb), k.cf).v).value, 
				ct=value($(kb), value($(kb), k.ct).v).value) 
				for k in keys($(kb).rci) if k.r == rid]...)
			(r=$r, ar=ar, rc=rc)
		end
	else
        error("must be 2 arguments")
	end
end


macro o!(kb, args...)
    la = length(args)
    kb = esc(kb)
	if la == 1
		#o = args[1]
		o = _arg1(args[1])
    	:(make!(O, $(kb), $o))
	elseif la == 2
		#o = args[1]
		o = _arg1(args[1])
		#dump(args[2])
		ks = [arg.args[1] for arg in args[2].args]
		#dump(ks)
		vs = [arg.args[2].args for arg in args[2].args]
		#dump(vs)
		quote
			oid = make!(O, $(kb), $o)
			tps = [$(ks)...]
			#dump(tps)
			llst = [$(vs)...]
			#dump(llst)
			for i in eachindex(tps)
				if tps[i] == :co
					for v in llst[i]
						c = make!(C, $(kb), _g(v.args, :c))
						make!(CO, $(kb), c, oid)
					end
				end
				if tps[i] == :aco
					for v in llst[i]
                        c = make!(C, $(kb), _g(v.args, :c))
                        co = make!(CO, $(kb), c, oid)
                        a = make!(A, $(kb), _g(v.args, :a))
                        ac = make!(AC, $(kb), c, a, _g(v.args, :v))
						make!(ACO, $(kb), co, ac, _g(v.args, :v))
					end
				end
                if tps[i] == :rcot
					for v in llst[i]
                        c = make!(C, $(kb), _g(v.args, :c))
                        co = make!(CO, $(kb), c, oid)
                        r = make!(R, $(kb), _g(v.args, :r))
						ct = make!(C, $(kb), _g(v.args, :ct))
                        ot = make!(O, $(kb), _g(v.args, :ot))
                        cot = make!(CO, $(kb), ct, ot)
						rc = make!(RC, $(kb), r, c, ct)
                        make!(RCO, $(kb), rc, co, cot)
					end
				end
                if tps[i] == :rcof
					for v in llst[i]
                        c = make!(C, $(kb), _g(v.args, :c))
                        co = make!(CO, $(kb), c, oid)
                        r = make!(R, $(kb), _g(v.args, :r))
						cf = make!(C, $(kb), _g(v.args, :cf))
                        of = make!(O, $(kb), _g(v.args, :of))
                        cof = make!(CO, $(kb), cf, of)
						rc = make!(RC, $(kb), r, cf, c)
                        make!(RCO, $(kb), rc, cof, co)
					end
				end
				if tps[i] == :arcot
					for v in llst[i]
                        c = make!(C, $(kb), _g(v.args, :c))
                        co = make!(CO, $(kb), c, oid)
                        r = make!(R, $(kb), _g(v.args, :r))
						ct = make!(C, $(kb), _g(v.args, :ct))
                        ot = make!(O, $(kb), _g(v.args, :ot))
                        cot = make!(CO, $(kb), ct, ot)
						rc = make!(RC, $(kb), r, c, ct)
                        rco = make!(RCO, $(kb), rc, co, cot)
						a = make!(A, $(kb), _g(v.args, :a))
						ar = make!(AR, $(kb), r, a, _g(v.args, :v))
                        arc = make!(ARC, $(kb), rc, ar, _g(v.args, :v))
						make!(ARCO, $(kb), rco, arc, _g(v.args, :v))
					end
				end
                if tps[i] == :arcof
					for v in llst[i]
                        c = make!(C, $(kb), _g(v.args, :c))
                        co = make!(CO, $(kb), c, oid)
                        r = make!(R, $(kb), _g(v.args, :r))
						cf = make!(C, $(kb), _g(v.args, :cf))
                        of = make!(O, $(kb), _g(v.args, :of))
                        cof = make!(CO, $(kb), cf, of)
						rc = make!(RC, $(kb), r, cf, c)
                        rco = make!(RCO, $(kb), rc, cof, co)
						a = make!(A, $(kb), _g(v.args, :a))
						ar = make!(AR, $(kb), r, a, _g(v.args, :v))
                        arc = make!(ARC, $(kb), rc, ar, _g(v.args, :v))
						make!(ARCO, $(kb), rco, arc, _g(v.args, :v))
					end
				end
			end
            oid
		end
    else
        error("must be 2 or 3 arguments")
	end
end

@generated function id!(kb::KBase, n::T) where {T<:Union{ValueTypes, AbstractNode}}
    
    if n <: Union{V, C, O, CO, R, RC, RCO, A}
        di = Dict(V => :vi, C => :ci, O => :oi, CO => :coi, R => :ri, RC => :rci, RCO => :rcoi, A => :ai)
        d = Dict(V => :v, C => :c, O => :o, CO => :co, R => :r, RC => :rc, RCO => :rco, A => :a)
        dt = Dict(V => :VID, C => :CID, O => :OID, CO => :COID, R => :RID, RC => :RCID, RCO => :RCOID, A => :AID)
        return quote
            if haskey(kb.$(di[T]), n)
                kb.$(di[T])[n]
            else
                i = $(dt[T])(UUIDs.uuid4())
                kb.$(d[T])[i] = n
                kb.$(di[T])[n] = i
                i
            end
        end
    elseif n <: Union{AC, AR, ACO, ARC, ARCO}
        di = Dict(AC => :aci,  AR => :ari, ACO => :acoi, ARC => :arci, ARCO => :arcoi)
        d = Dict(AC => :ac,  AR => :ar, ACO => :aco, ARC => :arc, ARCO => :arco)
        dt = Dict(AC => :ACID,  AR => :ARID, ACO => :ACOID, ARC => :ARCID, ARCO => :ARCOID)
        dk = Dict(AC => :ACKey,  AR => :ARKey, ACO => :ACOKey, ARC => :ARCKey, ARCO => :ARCOKey)
        flds = fieldnames(T)[1:end-1]
        args = [:(n.$fld) for fld in flds]
        return quote
            k = $(dk[T])($(args...))
            if haskey(kb.$(di[T]), k)
                kb.$(di[T])[k]
            else
                i = $(dt[T])(UUIDs.uuid4())
                kb.$(d[T])[i] = n
                kb.$(di[T])[k] = i
                i
            end
        end
    else
        return quote
            v = V(n)
            if haskey(kb.vi, v)
                kb.vi[v]
            else
                i = VID(UUIDs.uuid4())
                kb.v[i] = v
                kb.vi[v] = i
                i
            end
        end
    end

end

@generated function id(kb::KBase, n::T) where {T<:Union{ValueTypes, AbstractNode, AbstractANodeKey}}
    if n <: ValueTypes
        return :(get(kb.vi, V(n), nothing))
    else
        d = Dict(V => :vi, C => :ci, O => :oi, CO => :coi, R => :ri, RC => :rci, RCO => :rcoi, A => :ai,
        ACKey => :aci,  ARKey => :ari, ACOKey => :acoi, ARCKey => :arci, ARCOKey => :arcoi)
        return :(get(kb.$(d[T]), n, nothing))
    end
end

@generated function value(kb::KBase, i::T) where {T<:Union{UUID, AbstractID}}
    if i == UUID
        return :(get(kb.v, VID(i), nothing))
    else
        d = Dict(VID => :v, CID => :c, OID => :o, COID => :co, RID => :r, RCID => :rc, RCOID => :rco, AID => :a,
        ACID => :ac,  ARID => :ar, ACOID => :aco, ARCID => :arc, ARCOID => :arco)
        return :(get(kb.$(d[T]), i, nothing))
    end
end
