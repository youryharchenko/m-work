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
KBs.select_v(kb)

# ╔═╡ e0357704-20ef-4123-8ea2-00ca3ff78040
KBs.select_c(kb)

# ╔═╡ aa6e48e7-6220-43a4-9e43-2e3765d4c9aa
KBs.select_o(kb)

# ╔═╡ d1199439-36d7-4b19-814b-0080b013b05a
KBs.select_co(kb)

# ╔═╡ fc80b046-43af-45af-8087-462a0a5e1531
KBs.select_r(kb)

# ╔═╡ 52da4039-1d86-4cb6-b8d5-062c78d5b0ed
KBs.select_rc(kb)

# ╔═╡ 30a74d55-f2ae-4f30-9c8a-0a1fc9f39d7d
KBs.select_rco(kb)

# ╔═╡ 1f6663b4-8e9d-4351-bff7-6543acf26d2a
KBs.select_a(kb)

# ╔═╡ 6b6f8c32-b558-4ab5-889c-40d4439ef20d
KBs.select_ac(kb)

# ╔═╡ 4198b1b4-ad30-4bc8-bcd3-bc1e4a065a65
KBs.select_ar(kb)

# ╔═╡ 199abb46-4059-48ae-9ad2-a14023d9194c
KBs.select_aco(kb)

# ╔═╡ ef9f50c4-3dc9-4ebd-8896-96d0a3888363
KBs.select_arc(kb)

# ╔═╡ 43ac3d53-eaf7-4235-913b-689c356215d9
KBs.select_arco(kb)

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
# ╠═e0357704-20ef-4123-8ea2-00ca3ff78040
# ╠═aa6e48e7-6220-43a4-9e43-2e3765d4c9aa
# ╠═d1199439-36d7-4b19-814b-0080b013b05a
# ╠═fc80b046-43af-45af-8087-462a0a5e1531
# ╠═52da4039-1d86-4cb6-b8d5-062c78d5b0ed
# ╠═30a74d55-f2ae-4f30-9c8a-0a1fc9f39d7d
# ╠═1f6663b4-8e9d-4351-bff7-6543acf26d2a
# ╠═6b6f8c32-b558-4ab5-889c-40d4439ef20d
# ╠═4198b1b4-ad30-4bc8-bcd3-bc1e4a065a65
# ╠═199abb46-4059-48ae-9ad2-a14023d9194c
# ╠═ef9f50c4-3dc9-4ebd-8896-96d0a3888363
# ╠═43ac3d53-eaf7-4235-913b-689c356215d9
# ╠═f561b509-e20c-4549-b123-d245d839cada
