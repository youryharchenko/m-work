using UUIDs, Dates, Parameters, DataFrames

include("document.jl")

abstract type AbstractNode end
abstract type AbstractID end

const ValueTypes = Union{Symbol, Number, Bool, String, Date, Time, DateTime, UUID, Nothing}


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

end

# V

function id(kb::KBase, value::ValueTypes)::VID
    v = V(value)
    id(kb, v)
end

function id(kb::KBase, v::V)::VID
    if haskey(kb.vi, v)
        kb.vi[v]
    else
        i = VID(UUIDs.uuid4())
        kb.v[i] = v
        kb.vi[v] = i
        i
    end
end

function value(kb::KBase, u::UUID)::V
    i = VID(u)
    value(kb, i)
end

function value(kb::KBase, i::VID)::V
    if haskey(kb.v, i)
        kb.v[i]
    else
        kb.v[id(kb, nothing)]
    end
end

# C

function id(kb::KBase, n::C)::CID
    if haskey(kb.ci, n)
        kb.ci[n]
    else
        i = CID(UUIDs.uuid4())
        kb.c[i] = n
        kb.ci[n] = i
        i
    end
end

function value(kb::KBase, i::CID)::Union{C, Nothing}
    if haskey(kb.c, i)
        kb.c[i]
    else
        nothing
    end
end

# R

function id(kb::KBase, n::R)::RID
    if haskey(kb.ri, n)
        kb.ri[n]
    else
        i = RID(UUIDs.uuid4())
        kb.r[i] = n
        kb.ri[n] = i
        i
    end
end

function value(kb::KBase, i::RID)::Union{R, Nothing}
    if haskey(kb.r, i)
        kb.r[i]
    else
        nothing
    end
end

# A

function id(kb::KBase, n::A)::AID
    if haskey(kb.ai, n)
        kb.ri[n]
    else
        i = AID(UUIDs.uuid4())
        kb.a[i] = n
        kb.ai[n] = i
        i
    end
end

function value(kb::KBase, i::AID)::Union{A, Nothing}
    if haskey(kb.a, i)
        kb.a[i]
    else
        nothing
    end
end

# O

function id(kb::KBase, n::O)::OID
    if haskey(kb.oi, n)
        kb.oi[n]
    else
        i = OID(UUIDs.uuid4())
        kb.o[i] = n
        kb.oi[n] = i
        i
    end
end

function value(kb::KBase, i::OID)::Union{O, Nothing}
    if haskey(kb.o, i)
        kb.o[i]
    else
        nothing
    end
end

# CO

function id(kb::KBase, n::CO)::COID
    if haskey(kb.coi, n)
        kb.coi[n]
    else
        i = COID(UUIDs.uuid4())
        kb.co[i] = n
        kb.coi[n] = i
        i
    end
end

function value(kb::KBase, i::COID)::Union{CO, Nothing}
    if haskey(kb.co, i)
        kb.co[i]
    else
        nothing
    end
end

# RC

function id(kb::KBase, n::RC)::RCID
    if haskey(kb.rci, n)
        kb.rci[n]
    else
        i = RCID(UUIDs.uuid4())
        kb.rc[i] = n
        kb.rci[n] = i
        i
    end
end

function value(kb::KBase, i::RCID)::Union{RC, Nothing}
    if haskey(kb.rc, i)
        kb.rc[i]
    else
        nothing
    end
end

# RCO

function id(kb::KBase, n::RCO)::RCOID
    if haskey(kb.rcoi, n)
        kb.rcoi[n]
    else
        i = RCOID(UUIDs.uuid4())
        kb.rco[i] = n
        kb.rcoi[n] = i
        i
    end
end

function value(kb::KBase, i::RCOID)::Union{RCO, Nothing}
    if haskey(kb.rco, i)
        kb.rco[i]
    else
        nothing
    end
end


# df

function select_v(kb::KBase)
    ks = keys(kb.v)
    DataFrame(
        vid = [k.i for k in ks],
        value = [kb.v[k].value for k in ks]
    )
end

function select_c(kb::KBase)
    ks = keys(kb.c)
    DataFrame(
        cid = [k.i for k in ks],
        v = [value(kb, kb.c[k].v.i) for k in ks],
        vid = [kb.c[k].v.i for k in ks],
    )
end

function select_r(kb::KBase)
    ks = keys(kb.r)
    DataFrame(
        rid = [k.i for k in ks],
        v = [value(kb, kb.r[k].v.i) for k in ks],
        vid = [kb.r[k].v.i for k in ks],
    )
end

function select_a(kb::KBase)
    ks = keys(kb.a)
    DataFrame(
        aid = [k.i for k in ks],
        v = [value(kb, kb.a[k].v.i) for k in ks],
        vid = [kb.a[k].v.i for k in ks],
    )
end

function select_o(kb::KBase)
    ks = keys(kb.o)
    DataFrame(
        oid = [k.i for k in ks],
        v = [value(kb, kb.o[k].v.i) for k in ks],
        vid = [kb.o[k].v.i for k in ks],
    )
end

function select_co(kb::KBase)
    ks = keys(kb.co)
    DataFrame(
        coid = [k.i for k in ks],
        cv = [value(kb, value(kb, kb.co[k].c).v.i) for k in ks],
        ov = [value(kb, value(kb, kb.co[k].o).v.i) for k in ks],
        cid = [kb.co[k].c.i for k in ks],
        oid = [kb.co[k].o.i for k in ks],
    )
end

function select_rc(kb::KBase)
    ks = keys(kb.rc)
    DataFrame(
        rcid = [k.i for k in ks],
        rv = [value(kb, value(kb, kb.rc[k].r).v.i) for k in ks],
        cfv = [value(kb, value(kb, kb.rc[k].cf).v.i) for k in ks],
        ctv = [value(kb, value(kb, kb.rc[k].ct).v.i) for k in ks],
        rid = [kb.rc[k].r.i for k in ks],
        cfid = [kb.rc[k].cf.i for k in ks],
        ctid = [kb.rc[k].ct.i for k in ks],
    )
end

function select_rco(kb::KBase)
    ks = keys(kb.rco)
    DataFrame(
        rcoid = [k.i for k in ks],
        rv = [value(kb, value(kb, value(kb, kb.rco[k].rc).r).v.i) for k in ks],
        cfv = [value(kb, value(kb, value(kb, kb.rco[k].cof).c).v.i) for k in ks],
        ofv = [value(kb, value(kb, value(kb, kb.rco[k].cof).o).v.i) for k in ks],
        ctv = [value(kb, value(kb, value(kb, kb.rco[k].cot).c).v.i) for k in ks],
        otv = [value(kb, value(kb, value(kb, kb.rco[k].cot).o).v.i) for k in ks],
        rcid = [kb.rco[k].rc.i for k in ks],
        cofid = [kb.rco[k].cof.i for k in ks],
        cotid = [kb.rco[k].cot.i for k in ks],
    )
end

# proc

function proc_doc!(kb, file, author, title; lang=Languages.English())

	# log = open("log.txt", "w")

	sent_lcase, crps = document(file, lang)
		
	v_nothing = id(kb, "nothing")
	v_author1 = id(kb, author)
	v_doc1 = id(kb, title)

	v_c_doc = id(kb, "Document")
	v_c_author = id(kb, "Author")
	v_c_sentence = id(kb, "Sentence")
	v_c_sentence_inst = id(kb, "SentenceInst")
	v_c_word = id(kb, "Word")
	v_c_word_inst = id(kb, "WordInst")


	v_a_title = id(kb, "Title")
	v_a_name = id(kb, "Name")
	v_a_number = id(kb, "Number")

	v_r_is_author = id(kb, "is a author")
	v_r_has_parts = id(kb, "has parts")
	v_r_inst_of = id(kb, "inst of")

		
	c_doc = id(kb, C(v_c_doc))
	c_author = id(kb, C(v_c_author))
	c_sentence = id(kb, C(v_c_sentence))
	c_sentence_inst = id(kb, C(v_c_sentence_inst))
	c_word = id(kb, C(v_c_word))
	c_word_inst = id(kb, C(v_c_word_inst))
	
	

	# insert(kb, :A, [v_a_title])
	# insert(kb, :A, [v_a_name])
	# insert(kb, :A, [v_a_number])
	
	
	# insert(kb, :AC, [id(kb, :C, [v_c_author]), id(kb, :A, [v_a_name]), v_nothing])
	# insert(kb, :AC, [id(kb, :C, [v_c_doc]), id(kb, :A, [v_a_title]), v_nothing])
		
	r_is_author = id(kb, R(v_r_is_author))
	r_has_parts = id(kb, R(v_r_has_parts))
	r_inst_of = id(kb, R(v_r_inst_of))
		
	# insert(kb, :AR, [id(kb, :R, [v_r_has_parts]), id(kb, :A, [v_a_number]), v_nothing])
	
	rc_is_author = id(kb, RC(r_is_author, c_author, c_doc))
	    
	rc1 = id(kb, RC(r_has_parts, c_doc, c_sentence_inst))
	rc2 = id(kb, RC(r_has_parts, c_sentence, c_word_inst))
	rc3 = id(kb, RC(r_inst_of, c_sentence_inst, c_sentence))
	rc4 = id(kb, RC(r_inst_of, c_word_inst, c_word))

	# insert(kb, :ARC, [rc1, id(kb, :A, [v_a_number]), v_nothing])
	# insert(kb, :ARC, [rc2, id(kb, :A, [v_a_number]), v_nothing])
	
	o_author1 = id(kb, O(v_author1))
	o_doc1 = id(kb, O(v_doc1))
		
	co1 = id(kb, CO(c_author, o_author1))
	co2 = id(kb, CO(c_doc, o_doc1))
		
	# insert(kb, :ACO, [co1, id(kb, :A, [v_a_name]), v_author1])
	# insert(kb, :ACO, [co2, id(kb, :A, [v_a_title]), v_doc1])

	#c = id(kb, :C, [v_c_sentence])
	
	for s in sent_lcase
	 	o = id(kb, O(id(kb, s)))
	 	id(kb, CO(c_sentence, o))	
	end
		
	# c = id(kb, :C, [v_c_word])
	
	for s in keys(lexicon(crps))
	 	o = id(kb, O(id(kb, s)))
		id(kb, CO(c_word, o))	
	end
		
	ins_has_parts_inst_of!(
	 	kb, v_r_has_parts, v_r_inst_of, v_c_doc, v_c_sentence, v_c_sentence_inst, v_a_number, v_doc1, sent_lcase)

	for s in sent_lcase
	 	v_sent = id(kb, s)
	 	words = TextAnalysis.tokenize(s)
	 	ins_has_parts_inst_of!(
	 		kb, v_r_has_parts, v_r_inst_of, v_c_sentence, v_c_word, v_c_word_inst, v_a_number, v_sent, words)
	end
	
	# kb
end

function ins_has_parts_inst_of!(
	kb, v_r_has_parts, v_r_inst_of, v_c_doc, v_c_sentence, v_c_sentence_inst, v_a_number, v_doc, sent_lcase)

	r = id(kb, R(v_r_has_parts))
	rp = id(kb, R(v_r_inst_of))

	cf = id(kb, C(v_c_doc))
	ct = id(kb, C(v_c_sentence_inst))
	cp = id(kb, C(v_c_sentence))

	rc = id(kb, RC(r, cf, ct))
	rcp = id(kb, RC(rp, ct, cp))
	
	of = id(kb, O(v_doc))
    cof = id(kb, CO(cf, of))
    
	# a = id(kb, :A, [v_a_number])

	for i in eachindex(sent_lcase)
		v_sent = id(kb, sent_lcase[i])
		ot_p = id(kb, O(v_sent))
        cot_p = id(kb, CO(cp, ot_p))
		#k = count_rco_from(kb, rcp, ot_p)
		v_sent_inst = id(kb, UUIDs.uuid4())
		ot = id(kb, O(v_sent_inst))
        cot = id(kb, CO(ct, ot))
		
		id(kb, RCO(rcp, cot, cot_p))
		id(kb, RCO(rc, cof, cot))
		#v_i = insert(kb, :V, ["$i"])
		#insert(kb, :ARCO, [rco, a, v_i])

	end
end