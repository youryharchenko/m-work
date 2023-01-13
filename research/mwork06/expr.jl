using KBs

function add!(kb::KBs.KBase, expr::Expr, name::String)::KBs.COID
    v_c_expr = KBs.id!(kb, :Expr)
    c_expr = KBs.id!(kb, KBs.C(v_c_expr))
    v_o_expr = KBs.id!(kb, expr)
    o_expr = KBs.id!(kb, KBs.O(v_o_expr))
    co_expr = KBs.id!(kb, KBs.CO(c_expr, o_expr))
    co_expr
end