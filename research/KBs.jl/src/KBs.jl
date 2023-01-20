module KBs

using UUIDs, Parameters, DataFrames, TextAnalysis, Languages, BSON

include("kb.jl")
include("sys.jl")
include("macros.jl")

export @c!, @r!, @o!, init, save, load, select
export V, C, R, RC, O, CO, RCO, A, AC, AR, ACO, ARC, ARCO

end # module KBs
