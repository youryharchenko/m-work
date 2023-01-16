
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
