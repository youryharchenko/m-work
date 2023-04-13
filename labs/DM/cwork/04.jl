### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 6f341f22-d9d4-11ed-1df6-91d6765c4d5c
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	Pkg.instantiate()
	Pkg.add("Revise")
	Pkg.add("PlutoUI")
	Pkg.add("DataFrames")
	Pkg.add("Dates")
	Pkg.add("Parsers")
	Pkg.add("Julog")
	Pkg.develop(path=joinpath(@__DIR__, "/home/youry/Projects/m-work/research/KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ 23531297-30da-46e2-baa7-5fad223a27de
using Revise, KBs, Dates, Julog, DataFrames, PlutoUI

# ╔═╡ 7a0d7ccb-b42c-49ed-83fe-992363308891
let
structure_kb = """
@startuml

Class Log
Class Record
Class Time
Class Return
Class Word
Class Request
Class WordInst
Class Host
Class RecordInst
Class Agent
Class Path
Class Method


Log -- RecordInst : HAS >
RecordInst -- Record : IS >
Record -- Time : HAS >
Record -- Host : HAS >
Record -- Request : HAS >
Record -- Return : HAS >
Record -- Agent : HAS >
Agent -- WordInst : HAS >
WordInst -- Word : IS >
Request -- Method : HAS >
Request -- Path : HAS >

@enduml
"""
file = "pic01"
open("$file.txt", "w") do io
	write(io, structure_kb)
end
run(`plantuml "$file.txt"`)
LocalResource("$file.png")
end

# ╔═╡ Cell order:
# ╠═6f341f22-d9d4-11ed-1df6-91d6765c4d5c
# ╠═23531297-30da-46e2-baa7-5fad223a27de
# ╠═7a0d7ccb-b42c-49ed-83fe-992363308891
