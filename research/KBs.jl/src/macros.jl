

@generated function idg!(kb::KBase, n::T) where {T<:Union{ValueTypes, AbstractNode}}
    
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
            if haskey(kb.vi, k)
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
