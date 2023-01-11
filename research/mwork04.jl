### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 5637c043-4d20-4533-a3bc-bd719101effd
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	#Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.instantiate()
	Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ 40d83ca0-2c11-46b4-932c-a7920473eea6
using KBs 

# ╔═╡ e9ae32d1-3279-4414-b8ce-5cf8663902f8
using Serialization

# ╔═╡ 66065870-8c27-11ed-13d6-2f98c7c0acc3
#using UUIDs, Parameters, DataFrames, TextAnalysis, Languages, BSON

# ╔═╡ 7a3b4ec9-5175-4174-b436-66317e92650f
#KB = ingredients("mwork04/kb.jl")

# ╔═╡ c0d34b76-b100-4841-b1ad-1dcdf204fb39
const KB = KBs

# ╔═╡ 5d941dec-b446-4039-9c85-3b251682ccaf
kb = KB.KBase()

# ╔═╡ 8c4361a2-c9e7-467a-a222-23a1b667ccc2
KB.id!(kb, nothing)

# ╔═╡ c3c87912-276c-4d94-bc86-8807114be646
begin
	c_book = KB.id!(kb, KB.C(KB.id!(kb, "Book")))
	c_author = KB.id!(kb, KB.C(KB.id!(kb, "Author")))
	c_sentence = KB.id!(kb, KB.C(KB.id!(kb, "Sentence")))
	c_sentence_inst = KB.id!(kb, KB.C(KB.id!(kb, "SentenceInst")))
	c_word = KB.id!(kb, KB.C(KB.id!(kb, "Word")))
	c_word_inst = KB.id!(kb, KB.C(KB.id!(kb, "WordInst")))
end

# ╔═╡ 729ffe5b-ee14-439b-9859-19a498136632
begin
	r_part_of = KB.id!(kb, KB.R(KB.id!(kb, "part-of")))
	r_instance_of = KB.id!(kb, KB.R(KB.id!(kb, "instance-of")))
	r_author_of =  KB.id!(kb, KB.R(KB.id!(kb, "author-of")))
	KB.id!(kb, KB.R(KB.id!(kb, "has")))
end

# ╔═╡ 6b9f2732-54d1-4405-9fe9-c1f30d02f079
begin
	a_name = KB.id!(kb, KB.A(KB.id!(kb, "Name")))
	a_title = KB.id!(kb, KB.A(KB.id!(kb, "Title")))
	a_number = KB.id!(kb, KB.A(KB.id!(kb, "Number")))
end

# ╔═╡ 8de15b46-9177-4971-bbaf-e7c7be215561
begin
	o_author_1 = KB.id!(kb, KB.O(KB.id!(kb, "Russell")))
	o_author_2 = KB.id!(kb, KB.O(KB.id!(kb, "Norvig")))
	o_book_1 = KB.id!(kb, KB.O(KB.id!(kb, "Preface To Artificial Intelligence: A Modern Approach")))
end

# ╔═╡ a0b85212-33be-4e4e-95b3-495b7f44a2c6
begin
	co_author_1 = KB.id!(kb, KB.CO(c_author, o_author_1))
	co_author_2 = KB.id!(kb, KB.CO(c_author, o_author_2))
	co_book_1 = KB.id!(kb, KB.CO(c_book, o_book_1))
end

# ╔═╡ 74a1693b-9b04-4c4b-b337-f062a970baa9
begin
	rc_author_of_book = KB.id!(kb, KB.RC(r_author_of, c_author, c_book))
	KB.id!(kb, KB.RC(r_part_of, c_sentence_inst, c_book))
	KB.id!(kb, KB.RC(r_part_of, c_word_inst, c_sentence))
	KB.id!(kb, KB.RC(r_instance_of, c_word_inst, c_word))
	KB.id!(kb, KB.RC(r_instance_of, c_sentence_inst, c_sentence))
end

# ╔═╡ 4c794934-53b1-4b29-9e5f-b71c86c21318
begin
	KB.id!(kb, KB.RCO(rc_author_of_book, co_author_1, co_book_1))
	KB.id!(kb, KB.RCO(rc_author_of_book, co_author_2, co_book_1))
end

# ╔═╡ 42c6630c-5347-420b-af19-001d9369c50d
begin
	KB.id!(kb, KB.AC(c_author, a_name, KB.id!(kb, nothing)))
	KB.id!(kb, KB.AC(c_book, a_title, KB.id!(kb, nothing)))
end

# ╔═╡ 42a94168-1d73-499d-aa64-862ef0632a2b
begin
	serialize("kb.v-i.serialized", collect(keys(kb.v)))
	deserialize("kb.v-i.serialized")
end

# ╔═╡ b8103f41-46c8-41d1-81cd-8ed2992e4a8b
begin
	serialize("kb.v-i.serialized", [kb.v[k].value for k in keys(kb.v)])
	deserialize("kb.v-i.serialized")
end

# ╔═╡ a4501342-8cd2-47ba-94d7-72ee600fdcb8
db = let
	#dir = "save"
	db = KB.KBase()

	#KB.proc_doc!(db, 
	#	"""test01.txt""",
	#	"Russell, Stuart; Norvig, Peter",
	#	"Preface To Artificial Intelligence: A Modern Approach")
	#kb.save(db, dir)

	KB.proc_doc!(db, 
		"""Russell, Stuart; Norvig, Peter. "Preface To Artificial Intelligence: A Modern Approach".txt""",
		"Russell, Stuart; Norvig, Peter",
		"Preface To Artificial Intelligence: A Modern Approach")
	#kb.save(db, dir)
	
	KB.proc_doc!(db, 
		"""Helbig Knowledge Representation and the Semantics of Natural Language.txt""",
		"Helbig, Hermann",
		"Knowledge Representation and the Semantics of Natural Language")
	
	#kb.save(db, dir)
	#kb.load(dir)
	db
	
end

# ╔═╡ bc50c69b-8ac5-4f64-bd08-8d672a7209a3
KB.select_v(db)

# ╔═╡ 0f929e96-1b1e-4bc8-beef-4879ff9e1c8d
KB.select_c(db)

# ╔═╡ d9f43f4e-02b2-46a8-ae2b-8c01457a280d
KB.select_r(db)

# ╔═╡ ebf37fba-f767-4c4b-acc8-9afd84301dfb
KB.select_a(db)

# ╔═╡ 63c579a4-1bd7-4fa7-a01a-cf83e565d863
KB.select_o(db)

# ╔═╡ 194e85bd-92ba-439e-bc31-af0e51a4d6c6
KB.select_co(db)

# ╔═╡ 88827d6a-848f-45b0-85a1-2d506062858a
KB.select_rc(db)

# ╔═╡ 2ff9ecc9-40df-402e-a406-555194726a66
KB.select_rco(db)

# ╔═╡ f04d6d10-39cd-4ffd-ae97-f5ae4a033836
KB.select_ac(db)

# ╔═╡ ace1a6bf-08f1-4545-9e5a-4fa3f2621787
KB.select_ar(db)

# ╔═╡ a808e8d3-cf0a-4f38-8db9-3cfe12f8d98b
KB.select_aco(db)

# ╔═╡ 781975bc-5cc6-4d12-a62f-ca7852337498
KB.select_arc(db)

# ╔═╡ fcdd53c7-0b13-490e-9dfd-111953adafbf
KB.select_arco(db)

# ╔═╡ 06eb23dc-0675-4f94-abdd-6a15bed46849
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ 54393b32-51ed-45f7-a857-d67819764f36
begin
	serialize("db.v-i.serialized", collect(keys(db.v)))
	deserialize("db.v-i.serialized")
end

# ╔═╡ 1cce58f4-ebe9-4441-aeaa-9d8535793405
begin
	serialize("db.v-value.serialized", [db.v[k].value for k in keys(db.v)])
	deserialize("db.v-value.serialized")
end

# ╔═╡ Cell order:
# ╠═66065870-8c27-11ed-13d6-2f98c7c0acc3
# ╠═7a3b4ec9-5175-4174-b436-66317e92650f
# ╠═5637c043-4d20-4533-a3bc-bd719101effd
# ╠═40d83ca0-2c11-46b4-932c-a7920473eea6
# ╠═c0d34b76-b100-4841-b1ad-1dcdf204fb39
# ╠═5d941dec-b446-4039-9c85-3b251682ccaf
# ╠═8c4361a2-c9e7-467a-a222-23a1b667ccc2
# ╠═c3c87912-276c-4d94-bc86-8807114be646
# ╠═729ffe5b-ee14-439b-9859-19a498136632
# ╠═6b9f2732-54d1-4405-9fe9-c1f30d02f079
# ╠═8de15b46-9177-4971-bbaf-e7c7be215561
# ╠═a0b85212-33be-4e4e-95b3-495b7f44a2c6
# ╠═74a1693b-9b04-4c4b-b337-f062a970baa9
# ╠═4c794934-53b1-4b29-9e5f-b71c86c21318
# ╠═42c6630c-5347-420b-af19-001d9369c50d
# ╠═e9ae32d1-3279-4414-b8ce-5cf8663902f8
# ╠═42a94168-1d73-499d-aa64-862ef0632a2b
# ╠═b8103f41-46c8-41d1-81cd-8ed2992e4a8b
# ╠═a4501342-8cd2-47ba-94d7-72ee600fdcb8
# ╠═bc50c69b-8ac5-4f64-bd08-8d672a7209a3
# ╠═0f929e96-1b1e-4bc8-beef-4879ff9e1c8d
# ╠═d9f43f4e-02b2-46a8-ae2b-8c01457a280d
# ╠═ebf37fba-f767-4c4b-acc8-9afd84301dfb
# ╠═63c579a4-1bd7-4fa7-a01a-cf83e565d863
# ╠═194e85bd-92ba-439e-bc31-af0e51a4d6c6
# ╠═88827d6a-848f-45b0-85a1-2d506062858a
# ╠═2ff9ecc9-40df-402e-a406-555194726a66
# ╠═f04d6d10-39cd-4ffd-ae97-f5ae4a033836
# ╠═ace1a6bf-08f1-4545-9e5a-4fa3f2621787
# ╠═a808e8d3-cf0a-4f38-8db9-3cfe12f8d98b
# ╠═781975bc-5cc6-4d12-a62f-ca7852337498
# ╠═fcdd53c7-0b13-490e-9dfd-111953adafbf
# ╠═06eb23dc-0675-4f94-abdd-6a15bed46849
# ╠═54393b32-51ed-45f7-a857-d67819764f36
# ╠═1cce58f4-ebe9-4441-aeaa-9d8535793405
