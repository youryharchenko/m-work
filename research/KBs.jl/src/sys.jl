
function init(script::Expr)
    kb = KBase()

    make!(ACO, kb, 
        make!(CO, kb, make!(C, kb, :System), make!(O, kb, :Init)), 
        make!(AC, kb, make!(C, kb, :System), make!(A, kb, :script), nothing),
        script)

    evalue(kb, id(kb, script))

    kb
end

function init_run(kb::KBase)


    ac_system_script = id(kb, ACKey(make!(C, kb, :System), make!(A, kb, :script)))
    (isnothing(ac_system_script)) && (return "AC System.script not found")

    co_system_init = id(kb, CO(make!(C, kb, :System), make!(O, kb, :Init)))
    (isnothing(co_system_init)) && (return "CO System.Init not found")
    
    aco_system_init_script = id(kb, ACOKey(co_system_init, ac_system_script))
    (isnothing(aco_system_init_script)) && (return "ACO System.Init.script not found")

    evalue(kb, value(kb, aco_system_init_script).v)
end

function make!(::Type{MT}, kb::KBase, v::VT)::AbstractID where {MT, VT<:ValueTypes}
    id!(kb, MT(id!(kb, v)))
end

function make!(::Type{MT}, kb::KBase, x, y)::AbstractID where {MT}
    id!(kb, MT(x, y))
end

function make!(::Type{MT}, kb::KBase, x, y, v::VT)::AbstractID  where {MT, VT<:ValueTypes}
    id!(kb, MT(x, y, id!(kb, v)))
end



