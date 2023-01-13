#import Pkg
#Pkg.activate(joinpath(@__DIR__, ".."))

include("expr.jl")

using KBs

script1 = "1 + 1"

expr1 = Meta.parse(script1)

println(script1)
println(expr1)

dump(expr1)

eval(expr1)


kb = KBs.KBase()

println(add!(kb, expr1, ""))

KBs.save(kb, "save")
