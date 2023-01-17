using UUIDs, Dates, Parameters, DataFrames, Serialization

include("document.jl")

abstract type AbstractNode end
abstract type AbstractID end
abstract type AbstractANodeKey end

const ValueTypes = Union{Expr, Symbol, Number, Bool, String, Date, Time, DateTime, UUID, Nothing}


# V

struct VID <: AbstractID 
    i :: UUID
end

struct V <: AbstractNode
    value :: ValueTypes
end


# C

struct CID <: AbstractID 
    i :: UUID
end

struct C <: AbstractNode
    v :: VID
end

# R

struct RID <: AbstractID 
    i :: UUID
end

struct R <: AbstractNode
    v :: VID
end

# A

struct AID <: AbstractID 
    i :: UUID
end

struct A <: AbstractNode
    v :: VID
end

# O

struct OID <: AbstractID 
    i :: UUID
end

struct O <: AbstractNode
    v :: VID
end

# CO

struct COID <: AbstractID 
    i :: UUID
end

struct CO <: AbstractNode
    c :: CID
    o :: OID
end

# RC

struct RCID <: AbstractID 
    i :: UUID
end

struct RC <: AbstractNode
    r :: RID
    cf :: CID
    ct :: CID
end

# RCO

struct RCOID <: AbstractID 
    i :: UUID
end

struct RCO <: AbstractNode
    rc :: RCID
    cof :: COID
    cot :: COID
end

# AC

struct ACID <: AbstractID 
    i :: UUID
end

struct AC <: AbstractNode
    c :: CID
    a :: AID
    v :: VID
end

struct ACKey <: AbstractANodeKey
    c :: CID
    a :: AID
end

# AR

struct ARID <: AbstractID 
    i :: UUID
end

struct AR <: AbstractNode
    r :: RID
    a :: AID
    v :: VID
end

struct ARKey <: AbstractANodeKey
    r :: RID
    a :: AID
end

# ACO

struct ACOID <: AbstractID 
    i :: UUID
end

struct ACO <: AbstractNode
    co :: COID
    ac :: ACID
    v :: VID
end

struct ACOKey <: AbstractANodeKey
    co :: COID
    ac :: ACID
end

# ARC

struct ARCID <: AbstractID 
    i :: UUID
end

struct ARC <: AbstractNode
    rc :: RCID
    ar :: ARID
    v :: VID
end

struct ARCKey <: AbstractANodeKey
    rc :: RCID
    ar :: ARID
end

# ARCO

struct ARCOID <: AbstractID 
    i :: UUID
end

struct ARCO <: AbstractNode
    rco :: RCOID
    arc :: ARCID
    v :: VID
end

struct ARCOKey <: AbstractANodeKey
    rco :: RCOID
    arc :: ARCID
end

# KB

@with_kw struct KBase

    v :: Dict{VID, V} = Dict{VID, V}()
    vi :: Dict{V, VID} = Dict{V, VID}()

    c :: Dict{CID, C} = Dict{CID, C}()
    ci :: Dict{C, CID} = Dict{C, CID}()

    r :: Dict{RID, R} = Dict{RID, R}()
    ri :: Dict{R, RID} = Dict{R, RID}()

    a :: Dict{AID, A} = Dict{AID, A}()
    ai :: Dict{A, AID} = Dict{A, AID}()

    o :: Dict{OID, O} = Dict{OID, O}()
    oi :: Dict{O, OID} = Dict{O, OID}()

    co :: Dict{COID, CO} = Dict{COID, CO}()
    coi :: Dict{CO, COID} = Dict{CO, COID}()

    rc :: Dict{RCID, RC} = Dict{RCID, RC}()
    rci :: Dict{RC, RCID} = Dict{RC, RCID}()

    rco :: Dict{RCOID, RCO} = Dict{RCOID, RCO}()
    rcoi :: Dict{RCO, RCOID} = Dict{RCO, RCOID}()

    ac :: Dict{ACID, AC} = Dict{ACID, AC}()
    aci :: Dict{ACKey, ACID} = Dict{ACKey, ACID}()

    ar :: Dict{ARID, AR} = Dict{ARID, AR}()
    ari :: Dict{ARKey, ARID} = Dict{ARKey, ARID}()

    aco :: Dict{ACOID, ACO} = Dict{ACOID, ACO}()
    acoi :: Dict{ACOKey, ACOID} = Dict{ACOKey, ACOID}()

    arc :: Dict{ARCID, ARC} = Dict{ARCID, ARC}()
    arci :: Dict{ARCKey, ARCID} = Dict{ARCKey, ARCID}()

    arco :: Dict{ARCOID, ARCO} = Dict{ARCOID, ARCO}()
    arcoi :: Dict{ARCOKey, ARCOID} = Dict{ARCOKey, ARCOID}()

end

function save(kb::KBase, dir::String)
    mkpath(dir)

    # V
    ks = collect(keys(kb.v))
    serialize(joinpath(dir, "v-i.serialized"), ks)
    serialize(joinpath(dir, "v-value.serialized"), [kb.v[k].value for k in ks])
    
    # C
    ks = collect(keys(kb.c))
    serialize(joinpath(dir, "c-i.serialized"), ks)
    serialize(joinpath(dir, "c-v.serialized"), [kb.c[k].v for k in ks])
    
    # O
    ks = collect(keys(kb.o))
    serialize(joinpath(dir, "o-i.serialized"), ks)
    serialize(joinpath(dir, "o-v.serialized"), [kb.o[k].v for k in ks])
    
    # CO
    ks = collect(keys(kb.co))
    serialize(joinpath(dir, "co-i.serialized"), ks)
    serialize(joinpath(dir, "co-c.serialized"), [kb.co[k].c for k in ks])
    serialize(joinpath(dir, "co-o.serialized"), [kb.co[k].o for k in ks])
    
    # R
    ks = collect(keys(kb.r))
    serialize(joinpath(dir, "r-i.serialized"), ks)
    serialize(joinpath(dir, "r-v.serialized"), [kb.r[k].v for k in ks])

    # RC
    ks = collect(keys(kb.rc))
    serialize(joinpath(dir, "rc-i.serialized"), ks)
    serialize(joinpath(dir, "rc-r.serialized"), [kb.rc[k].r for k in ks])
    serialize(joinpath(dir, "rc-cf.serialized"), [kb.rc[k].cf for k in ks])
    serialize(joinpath(dir, "rc-ct.serialized"), [kb.rc[k].ct for k in ks])

    # RCO
    ks = collect(keys(kb.rco))
    serialize(joinpath(dir, "rco-i.serialized"), ks)
    serialize(joinpath(dir, "rco-rc.serialized"), [kb.rco[k].rc for k in ks])
    serialize(joinpath(dir, "rco-cof.serialized"), [kb.rco[k].cof for k in ks])
    serialize(joinpath(dir, "rco-cot.serialized"), [kb.rco[k].cot for k in ks])

    # A
    ks = collect(keys(kb.a))
    serialize(joinpath(dir, "a-i.serialized"), ks)
    serialize(joinpath(dir, "a-v.serialized"), [kb.a[k].v for k in ks])

    # AC
    ks = collect(keys(kb.ac))
    serialize(joinpath(dir, "ac-i.serialized"), ks)
    serialize(joinpath(dir, "ac-c.serialized"), [kb.ac[k].c for k in ks])
    serialize(joinpath(dir, "ac-a.serialized"), [kb.ac[k].a for k in ks])
    serialize(joinpath(dir, "ac-v.serialized"), [kb.ac[k].v for k in ks])

    # ACO
    ks = collect(keys(kb.aco))
    serialize(joinpath(dir, "aco-i.serialized"), ks)
    serialize(joinpath(dir, "aco-co.serialized"), [kb.aco[k].co for k in ks])
    serialize(joinpath(dir, "aco-ac.serialized"), [kb.aco[k].ac for k in ks])
    serialize(joinpath(dir, "aco-v.serialized"), [kb.aco[k].v for k in ks])


    # AR
    ks = collect(keys(kb.ar))
    serialize(joinpath(dir, "ar-i.serialized"), ks)
    serialize(joinpath(dir, "ar-r.serialized"), [kb.ar[k].r for k in ks])
    serialize(joinpath(dir, "ar-a.serialized"), [kb.ar[k].a for k in ks])
    serialize(joinpath(dir, "ar-v.serialized"), [kb.ar[k].v for k in ks])

    # ARC
    ks = collect(keys(kb.arc))
    serialize(joinpath(dir, "arc-i.serialized"), ks)
    serialize(joinpath(dir, "arc-rc.serialized"), [kb.arc[k].rc for k in ks])
    serialize(joinpath(dir, "arc-ar.serialized"), [kb.arc[k].ar for k in ks])
    serialize(joinpath(dir, "arc-v.serialized"), [kb.arc[k].v for k in ks])

    # ARCO
    ks = collect(keys(kb.arco))
    serialize(joinpath(dir, "arco-i.serialized"), ks)
    serialize(joinpath(dir, "arco-rco.serialized"), [kb.arco[k].rco for k in ks])
    serialize(joinpath(dir, "arco-arc.serialized"), [kb.arco[k].arc for k in ks])
    serialize(joinpath(dir, "arco-v.serialized"), [kb.arco[k].v for k in ks])

    nothing
end

function load(dir::String)::KBase 
    

    # V
    v = Dict(
        zip(
            deserialize(joinpath(dir, "v-i.serialized")),
            V.(deserialize(joinpath(dir, "v-value.serialized")))
        )
    )

    vi = Dict(
        zip(
			V.(deserialize(joinpath(dir, "v-value.serialized"))),
            deserialize(joinpath(dir, "v-i.serialized"))
        )
    )

    # C
    c = Dict(
        zip(
            deserialize(joinpath(dir, "c-i.serialized")),
            C.(deserialize(joinpath(dir, "c-v.serialized"))),
        )
    )

    ci = Dict(
        zip(
            C.(deserialize(joinpath(dir, "c-v.serialized"))),
            deserialize(joinpath(dir, "c-i.serialized")),
        )
    )
    
    
    # O
    o = Dict(
        zip(
            deserialize(joinpath(dir, "o-i.serialized")),
            O.(deserialize(joinpath(dir, "o-v.serialized"))),
        )
    )
    
    oi = Dict(
        zip(
            O.(deserialize(joinpath(dir, "o-v.serialized"))),
            deserialize(joinpath(dir, "o-i.serialized")),
        )
    )
    
    # CO
    co = Dict(
        zip(
            deserialize(joinpath(dir, "co-i.serialized")),
            [CO(args...) for args in zip(
				deserialize(joinpath(dir, "co-c.serialized")),
				deserialize(joinpath(dir, "co-o.serialized")),
			)],
		)
    )
    
    coi = Dict(
        zip(
            [CO(args...) for args in zip(
				deserialize(joinpath(dir, "co-c.serialized")),
				deserialize(joinpath(dir, "co-o.serialized")),
			)],
            deserialize(joinpath(dir, "co-i.serialized")),
		)
    )

    # R
    r = Dict(
        zip(
            deserialize(joinpath(dir, "r-i.serialized")),
            R.(deserialize(joinpath(dir, "r-v.serialized"))),
        )
    )
    
    ri = Dict(
        zip(
            R.(deserialize(joinpath(dir, "r-v.serialized"))),
            deserialize(joinpath(dir, "r-i.serialized")),
        )
    )

    # RC
    rc = Dict(
        zip(
            deserialize(joinpath(dir, "rc-i.serialized")),
            [RC(args...) for args in zip(
				deserialize(joinpath(dir, "rc-r.serialized")),
				deserialize(joinpath(dir, "rc-cf.serialized")),
                deserialize(joinpath(dir, "rc-ct.serialized")),
			)],
        )
    )
    
    rci = Dict(
        zip(
            [RC(args...) for args in zip(
				deserialize(joinpath(dir, "rc-r.serialized")),
				deserialize(joinpath(dir, "rc-cf.serialized")),
                deserialize(joinpath(dir, "rc-ct.serialized")),
			)],
            deserialize(joinpath(dir, "rc-i.serialized")),
        )
    )

    # RCO
    rco = Dict(
        zip(
            deserialize(joinpath(dir, "rco-i.serialized")),
            [RCO(args...) for args in zip(
				deserialize(joinpath(dir, "rco-rc.serialized")),
				deserialize(joinpath(dir, "rco-cof.serialized")),
                deserialize(joinpath(dir, "rco-cot.serialized")),
			)],
        )
    )
    
    rcoi = Dict(
        zip(
            [RCO(args...) for args in zip(
				deserialize(joinpath(dir, "rco-rc.serialized")),
				deserialize(joinpath(dir, "rco-cof.serialized")),
                deserialize(joinpath(dir, "rco-cot.serialized")),
			)],
            deserialize(joinpath(dir, "rco-i.serialized")),
        )
    )

    # A
    a = Dict(
        zip(
            deserialize(joinpath(dir, "a-i.serialized")),
            A.(deserialize(joinpath(dir, "a-v.serialized"))),
        )
    )
    
    ai = Dict(
        zip(
            A.(deserialize(joinpath(dir, "a-v.serialized"))),
            deserialize(joinpath(dir, "a-i.serialized")),
        )
    )

    # AC
    ac = Dict(
        zip(
            deserialize(joinpath(dir, "ac-i.serialized")),
            [AC(args...) for args in zip(
				deserialize(joinpath(dir, "ac-c.serialized")),
				deserialize(joinpath(dir, "ac-a.serialized")),
                deserialize(joinpath(dir, "ac-v.serialized")),
			)],
        )
    )
    
    aci = Dict(
        zip(
            [ACKey(args...) for args in zip(
				deserialize(joinpath(dir, "ac-c.serialized")),
				deserialize(joinpath(dir, "ac-a.serialized")),
			)],
            deserialize(joinpath(dir, "ac-i.serialized")),
        )
    )

    # ACO
    aco = Dict(
        zip(
            deserialize(joinpath(dir, "aco-i.serialized")),
            [ACO(args...) for args in zip(
				deserialize(joinpath(dir, "aco-co.serialized")),
				deserialize(joinpath(dir, "aco-ac.serialized")),
                deserialize(joinpath(dir, "aco-v.serialized")),
			)],
        )
    )
        
    acoi = Dict(
        zip(
            [ACOKey(args...) for args in zip(
				deserialize(joinpath(dir, "aco-co.serialized")),
				deserialize(joinpath(dir, "aco-ac.serialized")),
			)],
            deserialize(joinpath(dir, "aco-i.serialized")),
        )
    )

    # AR
    ar = Dict(
        zip(
            deserialize(joinpath(dir, "ar-i.serialized")),
            [AR(args...) for args in zip(
				deserialize(joinpath(dir, "ar-r.serialized")),
				deserialize(joinpath(dir, "ar-a.serialized")),
                deserialize(joinpath(dir, "ar-v.serialized")),
			)],
        )
    )
    
    ari = Dict(
        zip(
            [ARKey(args...) for args in zip(
				deserialize(joinpath(dir, "ar-r.serialized")),
				deserialize(joinpath(dir, "ar-a.serialized")),
			)],
            deserialize(joinpath(dir, "ar-i.serialized")),
        )
    )

    # ARC
    arc = Dict(
        zip(
            deserialize(joinpath(dir, "arc-i.serialized")),
            [ARC(args...) for args in zip(
				deserialize(joinpath(dir, "arc-rc.serialized")),
				deserialize(joinpath(dir, "arc-ar.serialized")),
                deserialize(joinpath(dir, "arc-v.serialized")),
			)],
        )
    )
        
    arci = Dict(
        zip(
            [ARCKey(args...) for args in zip(
				deserialize(joinpath(dir, "arc-rc.serialized")),
				deserialize(joinpath(dir, "arc-ar.serialized")),
			)],
            deserialize(joinpath(dir, "arc-i.serialized")),
        )
    )

    # ARCO
    arco = Dict(
        zip(
            deserialize(joinpath(dir, "arco-i.serialized")),
            [ARCO(args...) for args in zip(
				deserialize(joinpath(dir, "arco-rco.serialized")),
				deserialize(joinpath(dir, "arco-arc.serialized")),
                deserialize(joinpath(dir, "arco-v.serialized")),
			)],
        )
    )
    
    arcoi = Dict(
        zip(
            [ARCOKey(args...) for args in zip(
				deserialize(joinpath(dir, "arco-rco.serialized")),
				deserialize(joinpath(dir, "arco-arc.serialized")),
			)],
            deserialize(joinpath(dir, "arco-i.serialized")),
        )
    )

    KBase(v=v, vi=vi, c=c, ci=ci, o=o, oi=oi, co=co, coi=coi, r=r, ri=ri, rc=rc, rci=rci, rco=rco, rcoi=rcoi,
    a=a, ai=ai, ac=ac, aci=aci, aco=aco, acoi=acoi, ar=ar, ari=ari, arc=arc, arci=arci, arco=arco, arcoi=arcoi)
    
end

# V

function eval(v::ValueTypes)::ValueTypes
    (v isa Expr) ? Core.eval(@__MODULE__, v) : v 
end

# function id!(kb::KBase, value::ValueTypes)::VID
#     v = V(value)
#     id!(kb, v)
# end

# function id!(kb::KBase, v::V)::VID
#     if haskey(kb.vi, v)
#         kb.vi[v]
#     else
#         i = VID(UUIDs.uuid4())
#         kb.v[i] = v
#         kb.vi[v] = i
#         i
#     end
# end

# function id(kb::KBase, value::ValueTypes)::Union{VID, Nothing}
#     v = V(value)
#     id(kb, v)
# end

# function id(kb::KBase, v::V)::Union{VID, Nothing}
#     get(kb.vi, v, nothing)
# end

# function value(kb::KBase, u::UUID)::V
#     i = VID(u)
#     value(kb, i)
# end

function evalue(kb::KBase, u::UUID)::ValueTypes
    i = VID(u)
    evalue(kb, i)
end

# function value(kb::KBase, i::VID)::V
#     if haskey(kb.v, i)
#         kb.v[i]
#     else
#         kb.v[id!(kb, nothing)]
#     end
# end

function evalue(kb::KBase, i::VID)::ValueTypes
    if haskey(kb.v, i)
        eval(kb.v[i].value)
    else
        kb.v[id!(kb, nothing)]
    end
end

# C

# function id!(kb::KBase, n::C)::CID
#     if haskey(kb.ci, n)
#         kb.ci[n]
#     else
#         i = CID(UUIDs.uuid4())
#         kb.c[i] = n
#         kb.ci[n] = i
#         i
#     end
# end

# function id(kb::KBase, n::C)::Union{CID, Nothing}
#     get(kb.ci, n, nothing)
# end

# function value(kb::KBase, i::CID)::Union{C, Nothing}
#     get(kb.c, i, nothing)
# end

# R

# function id!(kb::KBase, n::R)::RID
#     if haskey(kb.ri, n)
#         kb.ri[n]
#     else
#         i = RID(UUIDs.uuid4())
#         kb.r[i] = n
#         kb.ri[n] = i
#         i
#     end
# end

# function id(kb::KBase, n::R)::Union{RID, Nothing}
#     get(kb.ri, n, nothing)
# end

# function value(kb::KBase, i::RID)::Union{R, Nothing}
#     get(kb.r, i, nothing)
# end

# A

# function id!(kb::KBase, n::A)::AID
#     if haskey(kb.ai, n)
#         kb.ai[n]
#     else
#         i = AID(UUIDs.uuid4())
#         kb.a[i] = n
#         kb.ai[n] = i
#         i
#     end
# end

# function id(kb::KBase, n::A)::Union{AID, Nothing}
#     get(kb.ai, n, nothing)
# end

# function value(kb::KBase, i::AID)::Union{A, Nothing}
#     get(kb.a, i, nothing)
# end

# O

# function id!(kb::KBase, n::O)::OID
#     if haskey(kb.oi, n)
#         kb.oi[n]
#     else
#         i = OID(UUIDs.uuid4())
#         kb.o[i] = n
#         kb.oi[n] = i
#         i
#     end
# end

# function id(kb::KBase, n::O)::Union{OID, Nothing}
#     get(kb.oi, n, nothing)
# end

# function value(kb::KBase, i::OID)::Union{O, Nothing}
#     get(kb.o, i, nothing)
# end

# CO

# function id!(kb::KBase, n::CO)::COID
#     if haskey(kb.coi, n)
#         kb.coi[n]
#     else
#         i = COID(UUIDs.uuid4())
#         kb.co[i] = n
#         kb.coi[n] = i
#         i
#     end
# end

# function id(kb::KBase, n::CO)::Union{COID, Nothing}
#     get(kb.coi, n, nothing)
# end

# function value(kb::KBase, i::COID)::Union{CO, Nothing}
#     get(kb.co, i, nothing)
# end

# RC

# function id!(kb::KBase, n::RC)::RCID
#     if haskey(kb.rci, n)
#         kb.rci[n]
#     else
#         i = RCID(UUIDs.uuid4())
#         kb.rc[i] = n
#         kb.rci[n] = i
#         i
#     end
# end

# function id(kb::KBase, n::RC)::Union{RCID, Nothing}
#     get(kb.rci, n, nothing)
# end

# function value(kb::KBase, i::RCID)::Union{RC, Nothing}
#     get(kb.rc, i, nothing)
# end

# RCO

# function id!(kb::KBase, n::RCO)::RCOID
#     if haskey(kb.rcoi, n)
#         kb.rcoi[n]
#     else
#         i = RCOID(UUIDs.uuid4())
#         kb.rco[i] = n
#         kb.rcoi[n] = i
#         i
#     end
# end

# function id(kb::KBase, n::RCO)::Union{RCOID, Nothing}
#     get(kb.rcoi, n, nothing)
# end

# function value(kb::KBase, i::RCOID)::Union{RCO, Nothing}
#     get(kb.rco, i, nothing)
# end

# AC

# function id!(kb::KBase, n::AC)::ACID
#     ack = ACKey(n.c, n.a)
#     if haskey(kb.aci, ack)
#         i = kb.aci[ack]
#         kb.ac[i] = n
#         i
#     else
#         i = ACID(UUIDs.uuid4())
#         kb.ac[i] = n
#         kb.aci[ack] = i
#         i
#     end
# end

# function id(kb::KBase, n::ACKey)::Union{ACID, Nothing}
#     get(kb.aci, n, nothing)
# end

# function value(kb::KBase, i::ACID)::Union{AC, Nothing}
#     get(kb.ac, i, nothing)
# end

# AR

# function id!(kb::KBase, n::AR)::ARID
#     ark = ARKey(n.r, n.a)
#     if haskey(kb.ari, ark)
#         i = kb.ari[ark]
#         kb.ar[i] = n
#         i
#     else
#         i = ARID(UUIDs.uuid4())
#         kb.ar[i] = n
#         kb.ari[ark] = i
#         i
#     end
# end

# function id(kb::KBase, n::ARKey)::Union{ARID, Nothing}
#     get(kb.ari, n, nothing)
# end

# function value(kb::KBase, i::ARID)::Union{AR, Nothing}
#     get(kb.ar, i, nothing)
# end

# ACO

# function id!(kb::KBase, n::ACO)::ACOID
#     acok = ACOKey(n.co, n.ac)
#     if haskey(kb.acoi, acok)
#         i = kb.acoi[acok]
#         kb.aco[i] = n
#         i
#     else
#         i = ACOID(UUIDs.uuid4())
#         kb.aco[i] = n
#         kb.acoi[acok] = i
#         i
#     end
# end

# function id(kb::KBase, n::ACOKey)::Union{ACOID, Nothing}
#     get(kb.acoi, n, nothing)
# end

# function value(kb::KBase, i::ACOID)::Union{ACO, Nothing}
#     get(kb.aco, i, nothing)
# end

# ARC

# function id!(kb::KBase, n::ARC)::ARCID
#     arck = ARCKey(n.rc, n.ar)
#     if haskey(kb.arci, arck)
#         i = kb.arci[arck]
#         kb.arc[i] = n
#         i
#     else
#         i = ARCID(UUIDs.uuid4())
#         kb.arc[i] = n
#         kb.arci[arck] = i
#         i
#     end
# end

# function id(kb::KBase, n::ARCKey)::Union{ARCID, Nothing}
#     get(kb.arci, n, nothing)
# end

# function value(kb::KBase, i::ARCID)::Union{ARC, Nothing}
#     get(kb.arc, i, nothing)
# end

# ARCO

# function id!(kb::KBase, n::ARCO)::ARCOID
#     arcok = ARCOKey(n.rco, n.arc)
#     if haskey(kb.arcoi, arcok)
#         i = kb.arcoi[arcok]
#         kb.arco[i] = n
#         i
#     else
#         i = ARCOID(UUIDs.uuid4())
#         kb.arco[i] = n
#         kb.arcoi[arcok] = i
#         i
#     end
# end

# function id(kb::KBase, n::ARCOKey)::Union{ARCOID, Nothing}
#     get(kb.arcoi, n, nothing)
# end

# function value(kb::KBase, i::ARCOID)::Union{ARCO, Nothing}
#     get(kb.arco, i, nothing)
# end

# df

function select(::Type{V}, kb::KBase; cs = [:vid, :ev, :value], f = ((x)->true))
    ks = [k for k in keys(kb.v) if f(kb.v[k])]
    d = Dict()
    (:vid in cs) && (d[:vid] = [k for k in ks])
    (:value in cs) && (d[:value] = [kb.v[k].value for k in ks])
    (:ev in cs) && (d[:ev] = [evalue(kb, k) for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end


function select(::Type{C}, kb::KBase; cs = [:cid, :v, :ev, :vid], f = (x)->true)
    ks = [k for k in keys(kb.c) if f(kb.c[k])]
    d = Dict()
    (:cid in cs) && (d[:cid] = [k for k in ks])
    (:v in cs) && (d[:v] = [value(kb, kb.c[k].v.i) for k in ks])
    (:ev in cs) && (d[:ev] = [evalue(kb, kb.c[k].v.i) for k in ks])
    (:vid in cs) && (d[:vid] = [kb.c[k].v for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

function select(::Type{R}, kb::KBase; cs = [:rid, :v, :vid], f = (x)->true)
    ks = [k for k in keys(kb.r) if f(kb.r[k])]
    d = Dict()
    (:rid in cs) && (d[:rid] = [k for k in ks])
    (:v in cs) && (d[:v] = [value(kb, kb.r[k].v.i) for k in ks])
    (:vid in cs) && (d[:vid] = [kb.r[k].v for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

function select(::Type{A}, kb::KBase; cs = [:aid, :v, :vid], f = (x)->true)
    ks = [k for k in keys(kb.a) if f(kb.a[k])]
    d = Dict()
    (:aid in cs) && (d[:aid] = [k for k in ks])
    (:v in cs) && (d[:v] = [value(kb, kb.a[k].v.i) for k in ks])
    (:vid in cs) && (d[:vid] = [kb.a[k].v for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

function select(::Type{O}, kb::KBase; cs = [:oid, :v, :ev, :vid], f = (x)->true)
    ks = [k for k in keys(kb.o) if f(kb.o[k])]
    d = Dict()
    (:oid in cs) && (d[:oid] = [k for k in ks])
    (:v in cs) && (d[:v] = [value(kb, kb.o[k].v.i) for k in ks])
    (:ev in cs) && (d[:ev] = [evalue(kb, kb.o[k].v.i) for k in ks])
    (:vid in cs) && (d[:vid] = [kb.o[k].v for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

function select(::Type{CO}, kb::KBase; cs = [:coid, :cv, :cev, :ov, :oev, :cid, :oid], f = (x)->true)
    ks = [k for k in keys(kb.co) if f(kb.co[k])]
    d = Dict()
    (:coid in cs) && (d[:coid] = [k for k in ks])
    (:cv in cs) && (d[:cv] = [value(kb, value(kb, kb.co[k].c).v.i) for k in ks])
    (:cev in cs) && (d[:cev] = [evalue(kb, value(kb, kb.co[k].c).v.i) for k in ks])
    (:ov in cs) && (d[:ov] = [value(kb, value(kb, kb.co[k].o).v.i) for k in ks])
    (:oev in cs) && (d[:oev] = [evalue(kb, value(kb, kb.co[k].o).v.i) for k in ks])
    (:cid in cs) && (d[:cid] = [kb.co[k].c for k in ks])
    (:oid in cs) && (d[:oid] = [kb.co[k].o for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

function select(::Type{RC}, kb::KBase; cs = [:rcid, :rv, :cfv, :ctv, :rid, :cfid, :ctid], f = (x)->true)
    ks = [k for k in keys(kb.rc) if f(kb.rc[k])]
    d = Dict()
    (:rcid in cs) && (d[:rcid] = [k for k in ks])
    (:rv in cs) && (d[:rv] = [value(kb, value(kb, kb.rc[k].r).v.i) for k in ks])
    (:cfv in cs) && (d[:cfv] = [value(kb, value(kb, kb.rc[k].cf).v.i) for k in ks])
    (:ctv in cs) && (d[:ctv] = [value(kb, value(kb, kb.rc[k].ct).v.i) for k in ks])
    (:rid in cs) && (d[:rid] = [kb.rc[k].r for k in ks])
    (:cfid in cs) && (d[:cfid] = [kb.rc[k].cf for k in ks])
    (:ctid in cs) && (d[:ctid] = [kb.rc[k].ct for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

function select(::Type{RCO}, kb::KBase; cs = [:rcoid, :rv, :cfv, :ofv, :ctv, :otv, :rcid, :cofid, :cotid], f = (x)->true)
    ks = [k for k in keys(kb.rco) if f(kb.rco[k])]
    d = Dict()
    (:rcoid in cs) && (d[:rcoid] = [k for k in ks])
    (:rv in cs) && (d[:rv] = [value(kb, value(kb, value(kb, kb.rco[k].rc).r).v.i) for k in ks])
    (:cfv in cs) && (d[:cfv] = [value(kb, value(kb, value(kb, kb.rco[k].cof).c).v.i) for k in ks])
    (:ofv in cs) && (d[:ofv] = [value(kb, value(kb, value(kb, kb.rco[k].cof).o).v.i) for k in ks])
    (:ctv in cs) && (d[:ctv] = [value(kb, value(kb, value(kb, kb.rco[k].cot).c).v.i) for k in ks])
    (:otv in cs) && (d[:otv] = [value(kb, value(kb, value(kb, kb.rco[k].cot).o).v.i) for k in ks])
    (:rcid in cs) && (d[:rcid] = [kb.rco[k].rc for k in ks])
    (:cofid in cs) && (d[:cofid] = [kb.rco[k].cof for k in ks])
    (:cotid in cs) && (d[:cotid] = [kb.rco[k].cot for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

function select(::Type{AC}, kb::KBase; cs = [:acid, :cv, :av, :v, :cid, :aid, :vid], f = (x)->true)
    ks = [k for k in keys(kb.ac) if f(kb.ac[k])]
    d = Dict()
    (:acid in cs) && (d[:acid] = [k for k in ks])
    (:cv in cs) && (d[:cv] = [value(kb, value(kb, kb.ac[k].c).v.i) for k in ks])
    (:av in cs) && (d[:av] = [value(kb, value(kb, kb.ac[k].a).v.i) for k in ks])
    (:v in cs) && (d[:v] = [value(kb, kb.ac[k].v.i) for k in ks])
    (:cid in cs) && (d[:cid] = [kb.ac[k].c for k in ks])
    (:aid in cs) && (d[:aid] = [kb.ac[k].a for k in ks])
    (:vid in cs) && (d[:vid] = [kb.ac[k].v for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

function select(::Type{AR}, kb::KBase; cs = [:arid, :rv, :av, :v, :rid, :aid, :vid], f = (x)->true)
    ks = [k for k in keys(kb.ar) if f(kb.ar[k])]
    d = Dict()
    (:arid in cs) && (d[:arid] = [k for k in ks])
    (:rv in cs) && (d[:rv] = [value(kb, value(kb, kb.ar[k].r).v.i) for k in ks])
    (:av in cs) && (d[:av] = [value(kb, value(kb, kb.ar[k].a).v.i) for k in ks])
    (:v in cs) && (d[:v] = [value(kb, kb.ar[k].v.i) for k in ks])
    (:rid in cs) && (d[:rid] = [kb.ar[k].r for k in ks])
    (:aid in cs) && (d[:aid] = [kb.ar[k].a for k in ks])
    (:vid in cs) && (d[:vid] = [kb.ar[k].v for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

function select(::Type{ACO}, kb::KBase; cs = [:acoid, :cv, :ov, :av, :v, :coid, :acid, :vid], f = (x)->true)
    ks = [k for k in keys(kb.aco) if f(kb.aco[k])]
    d = Dict()
    (:acoid in cs) && (d[:acoid] = [k for k in ks])
    (:cv in cs) && (d[:cv] = [value(kb, value(kb, value(kb, kb.aco[k].co).c).v.i) for k in ks])
    (:ov in cs) && (d[:ov] = [value(kb, value(kb, value(kb, kb.aco[k].co).o).v.i) for k in ks])
    (:av in cs) && (d[:av] = [value(kb, value(kb, value(kb, kb.aco[k].ac).a).v.i) for k in ks])
    (:v in cs) && (d[:v] = [value(kb, kb.aco[k].v.i) for k in ks])
    (:coid in cs) && (d[:coid] = [kb.aco[k].co for k in ks])
    (:acid in cs) && (d[:acid] = [kb.aco[k].ac for k in ks])
    (:vid in cs) && (d[:vid] = [kb.aco[k].v for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

function select(::Type{ARC}, kb::KBase; cs = [:arcid, :rv, :cfv, :ctv, :av, :v, :rcid, :arid, :vid], f = (x)->true)
    ks = [k for k in keys(kb.arc) if f(kb.arc[k])]
    d = Dict()
    (:arcid in cs) && (d[:arcid] = [k for k in ks])
    (:rv in cs) && (d[:rv] = [value(kb, value(kb, value(kb, kb.arc[k].rc).r).v.i) for k in ks])
    (:cfv in cs) && (d[:cfv] = [value(kb, value(kb, value(kb, kb.arc[k].rc).cf).v.i) for k in ks])
    (:ctv in cs) && (d[:ctv] = [value(kb, value(kb, value(kb, kb.arc[k].rc).ct).v.i) for k in ks])
    (:av in cs) && (d[:av] = [value(kb, value(kb, value(kb, kb.arc[k].ar).a).v.i) for k in ks])
    (:v in cs) && (d[:v] = [value(kb, kb.arc[k].v.i) for k in ks])
    (:rcid in cs) && (d[:rcid] = [kb.arc[k].rc for k in ks])
    (:arid in cs) && (d[:arid] = [kb.arc[k].ar for k in ks])
    (:vid in cs) && (d[:vid] = [kb.arc[k].v for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

function select(::Type{ARCO}, kb::KBase; cs = [:arcoid, :rv, :cfv, :ofv, :ctv, :otv, :av, :v, :rcoid, :arcid, :vid],
    f = (x)->true)

    ks = [k for k in keys(kb.arco) if f(kb.arco[k])]
    d = Dict()
    (:arcoid in cs) && (d[:arcoid] = [k for k in ks])
    (:rv in cs) && (d[:rv] = [value(kb, value(kb, value(kb, value(kb, kb.arco[k].rco).rc).r).v.i) for k in ks])
    (:cfv in cs) && (d[:cfv] = [value(kb, value(kb, value(kb, value(kb, kb.arco[k].rco).cof).c).v.i) for k in ks])
    (:ofv in cs) && (d[:ofv] = [value(kb, value(kb, value(kb, value(kb, kb.arco[k].rco).cof).o).v.i) for k in ks])
    (:ctv in cs) && (d[:ctv] = [value(kb, value(kb, value(kb, value(kb, kb.arco[k].rco).cot).c).v.i) for k in ks])
    (:otv in cs) && (d[:otv] = [value(kb, value(kb, value(kb, value(kb, kb.arco[k].rco).cot).o).v.i) for k in ks])
    (:av in cs) && (d[:av] = [value(kb, value(kb, value(kb, value(kb, kb.arco[k].arc).ar).a).v.i) for k in ks])
    (:v in cs) && (d[:v] = [value(kb, kb.arco[k].v.i) for k in ks])
    (:rcoid in cs) && (d[:rcoid] = [kb.arco[k].rco for k in ks])
    (:arcid in cs) && (d[:arcid] = [kb.arco[k].arc for k in ks])
    (:vid in cs) && (d[:vid] = [kb.arco[k].v for k in ks])
    select!(DataFrame(d; copycols = false), cs)
end

# proc

function proc_doc!(kb, file, author, title; lang=Languages.English())

	# log = open("log.txt", "w")

	sent_lcase, crps = document(file, lang)
		
	v_nothing = id!(kb, nothing)
	v_author1 = id!(kb, author)
	v_doc1 = id!(kb, title)

	v_c_doc = id!(kb, "Document")
	v_c_author = id!(kb, "Author")
	v_c_sentence = id!(kb, "Sentence")
	v_c_sentence_inst = id!(kb, "SentenceInst")
	v_c_word = id!(kb, "Word")
	v_c_word_inst = id!(kb, "WordInst")


	v_a_title = id!(kb, "Title")
	v_a_name = id!(kb, "Name")
	v_a_number = id!(kb, "Number")

	v_r_is_author = id!(kb, "is a author")
	v_r_has_parts = id!(kb, "has parts")
	v_r_inst_of = id!(kb, "inst of")

		
	c_doc = id!(kb, C(v_c_doc))
	c_author = id!(kb, C(v_c_author))
	c_sentence = id!(kb, C(v_c_sentence))
	c_sentence_inst = id!(kb, C(v_c_sentence_inst))
	c_word = id!(kb, C(v_c_word))
	c_word_inst = id!(kb, C(v_c_word_inst))
	
	

	a_title = id!(kb, A(v_a_title))
	a_name = id!(kb, A(v_a_name))
	a_number = id!(kb, A(v_a_number))
	
	
	ac_author_name = id!(kb, AC(c_author, a_name, v_nothing))
	ac_doc_title = id!(kb, AC(c_doc, a_title, v_nothing))
		
	r_is_author = id!(kb, R(v_r_is_author))
	r_has_parts = id!(kb, R(v_r_has_parts))
	r_inst_of = id!(kb, R(v_r_inst_of))
		
	ar_has_parts_number = id!(kb, AR(r_has_parts, a_number, v_nothing))
	
	rc_is_author = id!(kb, RC(r_is_author, c_author, c_doc))
	    
	rc1 = id!(kb, RC(r_has_parts, c_doc, c_sentence_inst))
	rc2 = id!(kb, RC(r_has_parts, c_sentence, c_word_inst))
	rc3 = id!(kb, RC(r_inst_of, c_sentence_inst, c_sentence))
	rc4 = id!(kb, RC(r_inst_of, c_word_inst, c_word))

	id!(kb, ARC(rc1, ar_has_parts_number, v_nothing))
	id!(kb, ARC(rc2, ar_has_parts_number, v_nothing))
	
	o_author1 = id!(kb, O(v_author1))
	o_doc1 = id!(kb, O(v_doc1))
		
	co1 = id!(kb, CO(c_author, o_author1))
	co2 = id!(kb, CO(c_doc, o_doc1))
		
	id!(kb, ACO(co1, ac_author_name, v_author1))
	id!(kb, ACO(co2, ac_doc_title, v_doc1))

	#c = id!(kb, :C, [v_c_sentence])
	
	for s in sent_lcase
	 	o = id!(kb, O(id!(kb, s)))
	 	id!(kb, CO(c_sentence, o))	
	end
		
	# c = id!(kb, :C, [v_c_word])
	
	for s in keys(lexicon(crps))
	 	o = id!(kb, O(id!(kb, s)))
		id!(kb, CO(c_word, o))	
	end
		
	ins_has_parts_inst_of!(
	 	kb, v_r_has_parts, v_r_inst_of, v_c_doc, v_c_sentence, v_c_sentence_inst, v_a_number, v_doc1, sent_lcase)

	for s in sent_lcase
	 	v_sent = id!(kb, s)
	 	words = TextAnalysis.tokenize(s)
	 	ins_has_parts_inst_of!(
	 		kb, v_r_has_parts, v_r_inst_of, v_c_sentence, v_c_word, v_c_word_inst, v_a_number, v_sent, words)
	end
	
	# kb
end

function ins_has_parts_inst_of!(
	kb, v_r_has_parts, v_r_inst_of, v_c_doc, v_c_sentence, v_c_sentence_inst, v_a_number, v_doc, sent_lcase)

	r = id!(kb, R(v_r_has_parts))
	rp = id!(kb, R(v_r_inst_of))

	cf = id!(kb, C(v_c_doc))
	ct = id!(kb, C(v_c_sentence_inst))
	cp = id!(kb, C(v_c_sentence))

	rc = id!(kb, RC(r, cf, ct))
	rcp = id!(kb, RC(rp, ct, cp))
	
	of = id!(kb, O(v_doc))
    cof = id!(kb, CO(cf, of))

    v_nothing = id!(kb, nothing)
    a_number = id!(kb, A(v_a_number))
    ar_has_parts_number = id!(kb, AR(r, a_number, v_nothing))
    arc = id!(kb, ARC(rc, ar_has_parts_number, v_nothing))
   
	for i in eachindex(sent_lcase)
		v_sent = id!(kb, sent_lcase[i])
		ot_p = id!(kb, O(v_sent))
        cot_p = id!(kb, CO(cp, ot_p))
		#k = count_rco_from(kb, rcp, ot_p)
		v_sent_inst = id!(kb, UUIDs.uuid4())
		ot = id!(kb, O(v_sent_inst))
        cot = id!(kb, CO(ct, ot))
		
		id!(kb, RCO(rcp, cot, cot_p))
		rco = id!(kb, RCO(rc, cof, cot))
		v_i = id!(kb, i)
		id!(kb, ARCO(rco, arc, v_i))

	end
end