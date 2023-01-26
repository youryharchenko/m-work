module KBs

using UUIDs, Parameters, DataFrames, TextAnalysis, Languages

include("kb.jl")
include("sys.jl")
include("macros.jl")

export @c!, @r!, @o!, @c, @co, @r, @o
export init, save, load, load_as_juliadb, select
export id, id!, value
export V, C, R, RC, O, CO, RCO, A, AC, AR, ACO, ARC, ARCO

end # module KBs
