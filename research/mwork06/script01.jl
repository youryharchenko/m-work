
include("expr.jl")

using KBs

script1 = "a + b"

expr1 = Meta.parse(script1)

println(script1)
println(expr1)

dump(expr1)


a, b = 5, 4
print(eval(expr1))


kb = KBs.KBase()

println(add!(kb, expr1, ""))

KBs.save(kb, "save")
