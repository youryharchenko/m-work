### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 382b97cf-a818-4af9-9c9b-9ab83e6a2c3e
begin
	import Pkg
	Pkg.activate(joinpath(@__DIR__, "."))
	#Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.instantiate()
	Pkg.add("Revise")
	Pkg.develop(path=joinpath(@__DIR__, "KBs.jl"))
	Pkg.resolve()
end

# ╔═╡ ab294525-c913-4c0a-b2fd-ee60484826a0
using Revise, KBs

# ╔═╡ 003a8297-b89c-432c-a614-f07410882e47
using Serialization

# ╔═╡ 59a569a8-90d8-11ed-3186-39a20377bba6
#using BSON,UUIDs, Parameters, DataFrames, TextAnalysis, Languages

# ╔═╡ 29adc2c8-838d-43c1-8b18-ac3a190623d5
#KB = ingredients("mwork04/kb.jl")

# ╔═╡ 46c592bb-786e-4e8f-b003-d7b8722c7b31
dir = "db-save"

# ╔═╡ 8e370255-0b07-47d4-8a4f-3d265b39f38e
kb = KBs.load(dir)

# ╔═╡ abcc41a0-3554-43da-92a9-c4e9d01fc432
Dict(
        zip(
            deserialize(joinpath(dir, "v-i.serialized")),
            KBs.V.(deserialize(joinpath(dir, "v-value.serialized")))
        )
)

# ╔═╡ c7661903-7016-4533-99ae-796f51abb6df
Dict(
        zip(
			KBs.V.(deserialize(joinpath(dir, "v-value.serialized"))),
            deserialize(joinpath(dir, "v-i.serialized"))
        )
)

# ╔═╡ 0cca92fc-05d4-4471-a72e-396f4045636d
Dict(
        zip(
            KBs.C.(deserialize(joinpath(dir, "c-v.serialized"))),
            deserialize(joinpath(dir, "c-i.serialized"))
		)
)

# ╔═╡ 67bbc349-be36-4236-ba0d-34ef6965c718
Dict(
        zip(
            deserialize(joinpath(dir, "o-i.serialized")),
            KBs.O.(deserialize(joinpath(dir, "o-v.serialized")))
        )
    )

# ╔═╡ 9d2124a5-e2eb-4e03-bf23-63166103e8fc
Dict(
        zip(
            KBs.O.(deserialize(joinpath(dir, "o-v.serialized"))),
            deserialize(joinpath(dir, "o-i.serialized"))
		)
)

# ╔═╡ 8e5db7c7-e653-4c2c-8f53-1fba1bee1813
Dict(
        zip(
            deserialize(joinpath(dir, "co-i.serialized")),
            [KBs.CO(args...) for args in zip(
				deserialize(joinpath(dir, "co-c.serialized")),
				deserialize(joinpath(dir, "co-o.serialized")),
			)],
		)
    )
    

# ╔═╡ 67173d68-1efd-46ab-b6ad-09287d487eb8
KBs.select(KBs.V ,kb, (x)->x.value isa String)

# ╔═╡ 13fdd8a1-2fc6-477a-bde5-636ab187f077
KBs.select(KBs.C ,kb, (x)->true)

# ╔═╡ e0357704-20ef-4123-8ea2-00ca3ff78040
KBs.select(KBs.C ,kb, (x)->x.v == KBs.id(kb, "Document"))

# ╔═╡ aa6e48e7-6220-43a4-9e43-2e3765d4c9aa
KBs.select(KBs.O, kb, (x)->x.v == KBs.id(kb, "one"))

# ╔═╡ e1fcb5ca-5cde-454d-bff6-50358e9ab53a
begin
	v_nothing = KBs.id(kb, "nothing")
	
	c_document = KBs.C(KBs.id(kb, "Document"))
	i_c_document = KBs.id(kb, c_document)

	c_word = KBs.C(KBs.id(kb, "Word"))
	i_c_word = KBs.id(kb, c_word)

	c_sentence = KBs.C(KBs.id(kb, "Sentence"))
	i_c_sentence = KBs.id(kb, c_sentence)

	c_sentence_inst = KBs.C(KBs.id(kb, "SentenceInst"))
	i_c_sentence_inst = KBs.id(kb, c_sentence_inst)
end

# ╔═╡ d1199439-36d7-4b19-814b-0080b013b05a
KBs.select(KBs.CO, kb, (x)->x.c == i_c_document)

# ╔═╡ 228dfeeb-9c46-467c-b6ea-509693b6137a
KBs.select(KBs.CO, kb, (x)->x.c == i_c_word)

# ╔═╡ 6c3177d6-be77-4126-a87c-98b66d490b75
KBs.select(KBs.CO, kb, (x)->x.c == i_c_sentence)

# ╔═╡ 03352c54-4b55-46eb-9d49-17ca822cc743
begin
	o_modeling = KBs.O(KBs.id(kb, "modeling"))
	i_o_modeling = KBs.id(kb, o_modeling)

	o_b = KBs.O(KBs.id(kb, "b"))
	i_o_b = KBs.id(kb, o_b)
end

# ╔═╡ 97f9aab4-6d9a-4354-bf5a-d5fcdddb7d31
KBs.select(KBs.CO, kb, (x)->x.o == i_o_modeling)

# ╔═╡ ca309c65-b469-4f82-8758-a47d8bf5bacc
KBs.select_co(kb, (x)->x.o == i_o_b)

# ╔═╡ f80b454b-2521-4f62-94d0-4224def96d36
begin
	v_r_has_parts = KBs.id(kb, "has parts")
	r_has_parts = KBs.R(v_r_has_parts)
	i_r_has_parts = KBs.id(kb, r_has_parts)
	
end

# ╔═╡ fc80b046-43af-45af-8087-462a0a5e1531
KBs.select(KBs.R, kb, (x)->x.v == v_r_has_parts)

# ╔═╡ 2e46d7a4-a44d-4f07-8bad-d0a394d6d0ea
KBs.select(KBs.RC, kb, (x)->x.r == i_r_has_parts)

# ╔═╡ 4e178fd8-658a-47e4-a77b-c820bd2c4ba3
KBs.select(KBs.RC, kb, (x)->x.cf == i_c_sentence)

# ╔═╡ 9cabdfb9-3b6d-4b7d-b1b2-4738a8ecc91e
KBs.select(KBs.RC, kb, (x)->x.ct == i_c_sentence_inst)

# ╔═╡ 0a73a14c-6086-4ef3-9762-382e89483814
KBs.select(KBs.RC, kb)

# ╔═╡ 3fd6bc52-038a-45c3-a5bc-3684f2847b1d
begin
	rc_hasparts_document_sentenceinst = KBs.RC(i_r_has_parts, i_c_document, i_c_sentence_inst)
	i_rc_hasparts_document_sentenceinst = KBs.id(kb, rc_hasparts_document_sentenceinst)

	co_word_b = KBs.CO(i_c_word, i_o_b)
	i_co_word_b = KBs.id(kb, co_word_b)

	co_sentence_b = KBs.CO(i_c_sentence, i_o_b)
	i_co_sentence_b = KBs.id(kb, co_sentence_b)

	
end

# ╔═╡ 52da4039-1d86-4cb6-b8d5-062c78d5b0ed
KBs.select(KBs.RCO, kb, (x)->x.rc == i_rc_hasparts_document_sentenceinst)

# ╔═╡ 78397bd7-728a-40b0-94ac-262f8dfaf7b7
KBs.select(KBs.RCO, kb, (x)->x.cot == i_co_word_b)

# ╔═╡ 3437cde5-e45c-4292-8787-ea3db12ee6e5
KBs.select(KBs.RCO, kb, (x)->x.cof == i_co_sentence_b)

# ╔═╡ 30a74d55-f2ae-4f30-9c8a-0a1fc9f39d7d
KBs.select(KBs.RCO, kb)

# ╔═╡ 1f6663b4-8e9d-4351-bff7-6543acf26d2a
KBs.select(KBs.A, kb)

# ╔═╡ df9897c9-c5f7-4d2b-9d48-72f10cf90a27
begin
	v_number = KBs.id(kb, "Number")
	a_number = KBs.A(v_number)
	i_a_number = KBs.id(kb, a_number)

	v_title = KBs.id(kb, "Title")
	a_title = KBs.A(v_title)
	i_a_title = KBs.id(kb, a_title)
end

# ╔═╡ 6b6f8c32-b558-4ab5-889c-40d4439ef20d
KBs.select(KBs.AC, kb, (x)->x.a == i_a_title)

# ╔═╡ 75b38573-b3f2-4c6f-8769-5f1b9cd2f414
KBs.select(KBs.AC, kb, (x)->x.c == i_c_document)

# ╔═╡ 5b6c605b-c14f-4e4c-a30f-1fad37e2899a
KBs.select(KBs.AC, kb)

# ╔═╡ 4198b1b4-ad30-4bc8-bcd3-bc1e4a065a65
KBs.select(KBs.AR, kb, (x)->x.a == i_a_number)

# ╔═╡ b8440fb0-60a2-466b-b16f-ff39161ed91e
KBs.select(KBs.AR, kb, (x)->x.r == i_r_has_parts)

# ╔═╡ bd13f7c1-bb16-4981-bffb-5836d4050b0b
begin
	i_o_document_1 = KBs.id(kb, KBs.O(KBs.id(kb, "Preface To Artificial Intelligence: A Modern Approach")))
	i_ac_title_document = KBs.id(kb, KBs.ACKey(i_c_document, i_a_title))
	i_co_document_1 = KBs.id(kb, KBs.CO(i_c_document, i_o_document_1))

	i_o_document_2 = KBs.id(kb, KBs.O(KBs.id(kb, "Knowledge Representation and the Semantics of Natural Language")))
	i_co_document_2 = KBs.id(kb, KBs.CO(i_c_document, i_o_document_2))
end

# ╔═╡ d683b840-ed7f-4883-9d4d-6a3ca16b23f7
KBs.select(KBs.RCO, kb, (x)->x.cof == i_co_document_1)

# ╔═╡ 339d4aad-d5f1-4e0c-9f0e-170716acc7f8
KBs.select(KBs.ACO, kb, (x)->x.ac == i_ac_title_document)

# ╔═╡ f2386b0f-0759-4496-ac1d-34919f629527
KBs.select(KBs.ACO, kb, (x)->x.co == i_co_document_1)

# ╔═╡ 71fde9e6-c5cb-4a7a-8a37-79a3a884c5ce
KBs.select(KBs.ACO, kb, (x)->x.co == i_co_document_2)

# ╔═╡ 199abb46-4059-48ae-9ad2-a14023d9194c
KBs.select(KBs.ACO, kb)

# ╔═╡ 04d1a92f-0668-4ea1-83c5-85060f8cfb5f
begin
	i_ar_hasparts_number = KBs.id(kb, KBs.ARKey(i_r_has_parts, i_a_number))
end

# ╔═╡ fc1d39fe-94f8-410d-b5bb-6f2211a3eece
KBs.select(KBs.ARC, kb, (x)->x.rc == i_rc_hasparts_document_sentenceinst)

# ╔═╡ 77cf2ae8-da95-408b-9742-27978ae18629
KBs.select(KBs.ARC, kb, (x)->x.ar == i_ar_hasparts_number)

# ╔═╡ 7bb10aef-d83d-4810-982f-1facbe1e03d0
KBs.select(KBs.ARC, kb)

# ╔═╡ b4d301df-f00b-4211-a1c1-3633996732d0
begin
	i_arc_hasparts_number = KBs.id(kb, KBs.ARCKey(i_rc_hasparts_document_sentenceinst, i_ar_hasparts_number))

	i_rco_hasparts_number = KBs.id(kb, KBs.RCO(i_rc_hasparts_document_sentenceinst, i_co_document_2, i_co_sentence_b))
end

# ╔═╡ 746dc195-9c98-4b1b-b893-fcb48ec2543d
KBs.select(KBs.ARCO, kb, (x)->x.arc == i_arc_hasparts_number)

# ╔═╡ 43ac3d53-eaf7-4235-913b-689c356215d9
KBs.select(KBs.ARCO, kb)

# ╔═╡ f561b509-e20c-4549-b123-d245d839cada
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

# ╔═╡ Cell order:
# ╠═59a569a8-90d8-11ed-3186-39a20377bba6
# ╠═29adc2c8-838d-43c1-8b18-ac3a190623d5
# ╠═382b97cf-a818-4af9-9c9b-9ab83e6a2c3e
# ╠═ab294525-c913-4c0a-b2fd-ee60484826a0
# ╠═003a8297-b89c-432c-a614-f07410882e47
# ╠═46c592bb-786e-4e8f-b003-d7b8722c7b31
# ╠═8e370255-0b07-47d4-8a4f-3d265b39f38e
# ╠═abcc41a0-3554-43da-92a9-c4e9d01fc432
# ╠═c7661903-7016-4533-99ae-796f51abb6df
# ╠═0cca92fc-05d4-4471-a72e-396f4045636d
# ╠═67bbc349-be36-4236-ba0d-34ef6965c718
# ╠═9d2124a5-e2eb-4e03-bf23-63166103e8fc
# ╠═8e5db7c7-e653-4c2c-8f53-1fba1bee1813
# ╠═67173d68-1efd-46ab-b6ad-09287d487eb8
# ╠═13fdd8a1-2fc6-477a-bde5-636ab187f077
# ╠═e0357704-20ef-4123-8ea2-00ca3ff78040
# ╠═aa6e48e7-6220-43a4-9e43-2e3765d4c9aa
# ╠═e1fcb5ca-5cde-454d-bff6-50358e9ab53a
# ╠═d1199439-36d7-4b19-814b-0080b013b05a
# ╠═228dfeeb-9c46-467c-b6ea-509693b6137a
# ╠═6c3177d6-be77-4126-a87c-98b66d490b75
# ╠═03352c54-4b55-46eb-9d49-17ca822cc743
# ╠═97f9aab4-6d9a-4354-bf5a-d5fcdddb7d31
# ╠═ca309c65-b469-4f82-8758-a47d8bf5bacc
# ╠═f80b454b-2521-4f62-94d0-4224def96d36
# ╠═fc80b046-43af-45af-8087-462a0a5e1531
# ╠═2e46d7a4-a44d-4f07-8bad-d0a394d6d0ea
# ╠═4e178fd8-658a-47e4-a77b-c820bd2c4ba3
# ╠═9cabdfb9-3b6d-4b7d-b1b2-4738a8ecc91e
# ╠═0a73a14c-6086-4ef3-9762-382e89483814
# ╠═3fd6bc52-038a-45c3-a5bc-3684f2847b1d
# ╠═52da4039-1d86-4cb6-b8d5-062c78d5b0ed
# ╠═78397bd7-728a-40b0-94ac-262f8dfaf7b7
# ╠═3437cde5-e45c-4292-8787-ea3db12ee6e5
# ╠═d683b840-ed7f-4883-9d4d-6a3ca16b23f7
# ╠═30a74d55-f2ae-4f30-9c8a-0a1fc9f39d7d
# ╠═1f6663b4-8e9d-4351-bff7-6543acf26d2a
# ╠═df9897c9-c5f7-4d2b-9d48-72f10cf90a27
# ╠═6b6f8c32-b558-4ab5-889c-40d4439ef20d
# ╠═75b38573-b3f2-4c6f-8769-5f1b9cd2f414
# ╠═5b6c605b-c14f-4e4c-a30f-1fad37e2899a
# ╠═4198b1b4-ad30-4bc8-bcd3-bc1e4a065a65
# ╠═b8440fb0-60a2-466b-b16f-ff39161ed91e
# ╠═bd13f7c1-bb16-4981-bffb-5836d4050b0b
# ╠═339d4aad-d5f1-4e0c-9f0e-170716acc7f8
# ╠═f2386b0f-0759-4496-ac1d-34919f629527
# ╠═71fde9e6-c5cb-4a7a-8a37-79a3a884c5ce
# ╠═199abb46-4059-48ae-9ad2-a14023d9194c
# ╠═04d1a92f-0668-4ea1-83c5-85060f8cfb5f
# ╠═fc1d39fe-94f8-410d-b5bb-6f2211a3eece
# ╠═77cf2ae8-da95-408b-9742-27978ae18629
# ╠═7bb10aef-d83d-4810-982f-1facbe1e03d0
# ╠═b4d301df-f00b-4211-a1c1-3633996732d0
# ╠═746dc195-9c98-4b1b-b893-fcb48ec2543d
# ╠═43ac3d53-eaf7-4235-913b-689c356215d9
# ╠═f561b509-e20c-4549-b123-d245d839cada
