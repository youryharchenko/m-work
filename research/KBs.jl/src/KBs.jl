module KBs

using UUIDs, Parameters, DataFrames, TextAnalysis, Languages, BSON

include("kb.jl")
include("sys.jl")
include("macros.jl")

export @c!, @r!, @o!, init, save, load, select


end # module KBs
