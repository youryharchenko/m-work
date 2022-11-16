### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 17b3882a-518d-453f-b0b7-cf8c9ccd174e
using Dates, JuliaDB

# ╔═╡ d7589ce2-1507-46e3-bade-2d49848a40ca
abstract type AbstractRole end

# ╔═╡ 3c6423c4-eab2-423b-89b0-dfbcd072017b
abstract type AbstractRelation end

# ╔═╡ 234b62a8-7033-40e3-b778-e37f74fc9245
abstract type AbstractObject end

# ╔═╡ 320bf5b2-7d8a-4491-9244-199986a095e2
abstract type AbstractProperty end

# ╔═╡ 0bbd8dd3-aec3-423f-939f-8426e7b7f788
struct Role <: AbstractRole
	s::String
end

# ╔═╡ 482a0bdb-d19e-4be4-a70f-5cbfd4af95d9
struct Relation <: AbstractRelation
	s::String
end

# ╔═╡ 05363791-e01c-44e1-8e6d-ac86affc7597
struct Property <: AbstractProperty
	s::String
end

# ╔═╡ a662f2e0-3329-4af8-b0c7-0534653c7d23
struct Object <: AbstractObject
	s::String
end

# ╔═╡ 4f3240fe-bd70-48a0-81d3-bd9812ad1747
Base.@kwdef mutable struct Value
	value::Any
	count::UInt = 1
end

# ╔═╡ 75eec1b5-651c-438c-94d1-16ad83011be9
struct RoleRef
	i::UInt
end

# ╔═╡ e522b92b-52aa-4749-8eb1-1b2f00d5930f
struct RelationRef
	i::UInt
end

# ╔═╡ 266ba532-86c9-405d-b02f-7afc3ba3d423
struct RoleRelationRef
	i::UInt
end

# ╔═╡ c0002e69-505b-495b-8868-606cce05b496
struct PropertyRef
	i::UInt
end

# ╔═╡ 6982cc75-6775-4efa-acd1-554ff7c7b939
struct RolePropertyRef
	i::UInt
end

# ╔═╡ 72c28819-1feb-42aa-a4ac-2065d5d93ac8
struct ObjectRef
	i::UInt
end

# ╔═╡ 4267565b-6178-4e8e-9129-4d6a4544ec35
struct ValueRef
	i::UInt
end

# ╔═╡ 6114c20a-3653-4dce-a37a-08f620537a0c
struct ObjectRoleRef
	i::UInt
end

# ╔═╡ 4cbc52e4-2447-4d3f-bb6f-1f5745386677
struct ObjectRelationRef
	i::UInt
end

# ╔═╡ d4337a53-01a0-4570-9f73-5d2ba1dfde5e
struct ObjectPropertyRef
	i::UInt
end

# ╔═╡ 2dfcfc08-c099-4bc8-a06d-f081c150bce7
struct RoleRelation
	relation::RelationRef
	from::RoleRef
	#from_min::UInt
	#from_max::UInt
	to::RoleRef
	#to_min::UInt
	#to_max::UInt
end

# ╔═╡ 500a402f-5d7d-4276-b149-b25663fc04a5
struct RoleProperty
	role::RoleRef
	property::PropertyRef
	default::ValueRef
end

# ╔═╡ f5fbd105-c9c7-4a1c-a657-0ddc407804ed
struct RoleRelationProperty
	role_relation::RoleRelationRef
	property::PropertyRef
	default::ValueRef
end

# ╔═╡ 244964d2-db4c-4947-a9bb-c64db3f74d5c
struct ObjectRole
	object::ObjectRef
	role::RoleRef
	#start::DateTime
	#finish::DateTime
end

# ╔═╡ e09842cb-1c3d-42f7-856b-36303ba609a5
struct ObjectRelation
	relation::RelationRef
	from::ObjectRef
	to::ObjectRef
	#start::DateTime
	#finish::DateTime
end

# ╔═╡ ca26f1fb-4c90-4791-a001-2f55aaf799ea
struct ObjectProperty
	object::ObjectRef
	role::RoleRef
	property::PropertyRef
	value::ValueRef
	#start::DateTime
	#finish::DateTime
end

# ╔═╡ 0d542e1c-ff9e-44c9-9251-12b98bc2efa6
struct ObjectRelationProperty
	object_relation::ObjectRelationRef
	property::PropertyRef
	value::ValueRef
	#start::DateTime
	#finish::DateTime
end

# ╔═╡ 95af4cea-5aa1-11ed-3061-152e5851630b
Base.@kwdef struct Datum
	properties::Vector{AbstractProperty} = Vector{AbstractProperty}[]
	values::Vector{Value} = Vector{Value}[]
	roles::Vector{AbstractRole} = Vector{AbstractRole}[]
	role_properties::Vector{RoleProperty} = Vector{RoleProperty}[]
	relations::Vector{AbstractRelation} = Vector{AbstractRelation}[]
	role_relations::Vector{RoleRelation} = Vector{RoleRelation}[]
	role_relation_properties::Vector{RoleRelationProperty} = Vector{RoleRelationProperty}[]
	objects::Vector{AbstractObject} = Vector{AbstractObject}[]
	object_roles::Vector{ObjectRole} = Vector{ObjectRole}[]
	object_relations::Vector{ObjectRelation} = Vector{ObjectRelation}[]
	object_properties::Vector{ObjectProperty} = Vector{ObjectProperty}[]
	object_relation_properties::Vector{ObjectRelationProperty} = Vector{ObjectRelationProperty}[]
end

# ╔═╡ 768e9bf7-7190-4980-b85f-742e98542b5f
function create!(d::Datum, property::Property)::PropertyRef
	push!(d.properties, property)
	PropertyRef(length(d.properties))
end

# ╔═╡ 6db3f9f1-b48f-4a33-a311-cf38685d2711
function create!(d::Datum, relation::Relation)::RelationRef
	push!(d.relations, relation)
	RelationRef(length(d.relations))
end

# ╔═╡ b7050539-c3bc-4629-8e95-5f368d09572b
function find(d::Datum, value::Value)::Union{ValueRef, Nothing}
	i = findfirst(x -> x.value == value.value, d.values)
	i == nothing ? nothing : ValueRef(i)
end

# ╔═╡ cce315a9-34fd-4505-911b-4ba8e1d1133a
function create!(d::Datum, value::Value)::ValueRef
	ref = find(d, value)
	if ref == nothing
		push!(d.values, value)
		ref = ValueRef(length(d.values))
	else
		d.values[ref.i].count += 1
		ref
	end
end

# ╔═╡ a3563ada-b5bb-4047-8dc1-6174073d60e7
function get(d::Datum, val_ref::ValueRef)::Any
	d.values[val_ref.i].value
end

# ╔═╡ e5dfd0db-7e40-4e29-a72a-8d38e4cc176e
function create!(d::Datum, role::Role)::RoleRef
	push!(d.roles, role)
	RoleRef(length(d.roles))
end

# ╔═╡ 44e89a9c-5b55-403c-bfab-b4a60d775279
function create!(d::Datum, object::Object)::ObjectRef
	push!(d.objects, object)
	ObjectRef(length(d.objects))
end

# ╔═╡ 683420c2-74e9-4353-9e9a-43d3aa347ca4
function add!(d::Datum, role::RoleRef, property::PropertyRef, value::Any)::RolePropertyRef
	value_ref = create!(d, Value(;value=value))
	push!(d.role_properties, RoleProperty(role, property, value_ref))
	RolePropertyRef(length(d.role_properties))
end

# ╔═╡ 2f20d360-9806-4667-8ad2-a60c1a546562
function select_properties(d::Datum, role::RoleRef)::Vector{RoleProperty}
	filter(x -> x.role == role , d.role_properties)
end

# ╔═╡ 68e750ce-ae7d-4297-88b5-95f32bc0a60d
function add!(d::Datum, object::ObjectRef, role::RoleRef, property::PropertyRef, value::Any)::ObjectPropertyRef
	value_ref = create!(d, Value(;value=value))
	push!(d.object_properties, ObjectProperty(object, role, property, value_ref))
	ObjectPropertyRef(length(d.object_properties))
end

# ╔═╡ a1063862-32d4-4ca5-ac0b-b8c1dc5d1747
function add!(d::Datum, relation::RelationRef, from::RoleRef, to::RoleRef)::RoleRelationRef
	push!(d.role_relations, RoleRelation(relation, from, to))
	RoleRelationRef(length(d.role_relations))
end

# ╔═╡ 449eab36-1099-4d8c-91ba-987747f716e0
function add!(d::Datum, object::ObjectRef, role::RoleRef)::ObjectRoleRef
	push!(d.object_roles, ObjectRole(object, role))
	role_properties = select_properties(d, role)
	for role_prop in role_properties
		prop = role_prop.property
		val_ref = role_prop.default
		add!(d, object, role, prop, get(d, val_ref))
	end
	ObjectRoleRef(length(d.object_roles))
end

# ╔═╡ fcc14093-916f-4a34-8477-cb0accecfdc7
function add!(d::Datum, relation::RelationRef, from::ObjectRef, to::ObjectRef)::ObjectRelationRef
	push!(d.object_relations, ObjectRelation(relation, from, to))
	ObjectRelationRef(length(d.object_relations))
end

# ╔═╡ 92a41103-bd14-4752-ad10-79c0cfc6f9d2
function table(d::Datum, m::Symbol)
	
	if m == :role
		t = JuliaDB.table(
			[i for i in 1:length(d.roles)],
			[x.s for x in d.roles]
		
			; names=[:ref, :string], pkey=[:ref]
		)
		for role in eachindex(d.roles)
			props = select_properties(d, RoleRef(role))
			for prop in props
				
			end
		end
		t
	else
	end

end

# ╔═╡ ce302404-5730-4885-a55a-d62e5f596081
d = Datum()

# ╔═╡ 6ce5ed48-f08b-4ee4-b1d5-fe471fe18dd5
table(d, :role)

# ╔═╡ f558e6a2-548a-4a95-9149-a408a21bca80
begin
	prop_x = create!(d, Property("x"))
	prop_y = create!(d, Property("y"))
	prop_color = create!(d, Property("color"))
end

# ╔═╡ 3b4d3349-be9c-45bb-a8ae-42a82506588e
begin
	rel_has = create!(d, Relation("has"))
end

# ╔═╡ 0b3bf5d4-8755-4d21-a664-0da3ad80b6b6
begin
	role_room = create!(d, Role("Room"))
	
	role_cell = create!(d, Role("Cell"))
	role_cell_x = add!(d, role_cell, prop_x, 0)
	role_cell_y = add!(d, role_cell, prop_y, 0)
	role_cell_color = add!(d, role_cell, prop_color, "white")
	
	role_robot = create!(d, Role("Robot"))
	role_robot_color = add!(d, role_robot, prop_color, "green")
	
	role_charger = create!(d, Role("Charger"))
	role_charger_color = add!(d, role_charger, prop_color, "blue")
	
	role_static = create!(d, Role("StaticObject"))
	role_static_color = add!(d, role_static, prop_color, "black")
	
	role_dynamic = create!(d, Role("DynamicObject"))
	role_dynamic_color = add!(d, role_dynamic, prop_color, "red")
end

# ╔═╡ 5ff45a61-c5f9-401e-8f0e-20e3cdfe5706
begin
	role_rel_room_cell = add!(d, rel_has, role_room, role_cell)
end

# ╔═╡ f74ada52-15c2-4ced-9253-dd0199c9f890
begin
	
	room = create!(d, Object("room"))
	add!(d, room, role_room)
	
	cells = Array{ObjectRef}(undef, (9, 9))
	for x in 1:9
		for y in 1:9
			cell = create!(d, Object("cell($x, $y)"))
			add!(d, cell, role_cell)
			add!(d, rel_has, room, cell)
			add!(d, cell, role_cell, prop_x, x)
			add!(d, cell, role_cell, prop_y, y)
			#add!(d, cell, role_cell, prop_color, "white")
			cells[x, y] = cell
		end
	end
	
	robot = create!(d, Object("robot"))
	add!(d, robot, role_robot)

	charger = create!(d, Object("charger"))
	add!(d, charger, role_charger)
	
	vase = create!(d, Object("vase"))
	add!(d, vase, role_static)
	
	dog = create!(d, Object("dog"))
	add!(d, dog, role_dynamic)
	
end

# ╔═╡ 2ee42c85-dddc-4977-8734-4153d7470871


# ╔═╡ fb97bb00-1ad8-4d7e-a68d-5106ba91c35c
d

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
JuliaDB = "a93385a2-3734-596a-9a66-3cfbb77141e6"

[compat]
JuliaDB = "~0.13.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["BinaryProvider", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "05916673a2627dd91b4969ff8ba6941bc85a960e"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.6.0"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "b0b7e8a0d054fada22b64095b46469627a138943"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "2.2.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Dagger]]
deps = ["Distributed", "LinearAlgebra", "MemPool", "Profile", "Random", "Serialization", "SharedArrays", "SparseArrays", "Statistics", "StatsBase", "Test"]
git-tree-sha1 = "39dd9351c6637a71d1925e26e49adcd8a25ebf0b"
uuid = "d58978e5-989f-55fb-8d15-ea34adc7bf54"
version = "0.8.0"

[[deps.DataAPI]]
git-tree-sha1 = "46d2680e618f8abd007bce0c3026cb0c4a8f2032"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.12.0"

[[deps.DataStructures]]
deps = ["InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "88d48e133e6d3dd68183309877eac74393daa7eb"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.17.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "b65fd071ca17aa265eb8c5ab0e522faa03a50d34"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.12"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.DoubleFloats]]
deps = ["GenericLinearAlgebra", "LinearAlgebra", "Polynomials", "Printf", "Quadmath", "Random", "Requires", "SpecialFunctions"]
git-tree-sha1 = "964a1a3737ef63eeacdac7f32c27d5cdaa383cbd"
uuid = "497a8b3b-efae-58df-a0af-a86822472b78"
version = "1.2.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.GenericLinearAlgebra]]
deps = ["LinearAlgebra", "Printf", "Random", "libblastrampoline_jll"]
git-tree-sha1 = "3d58ea2e65e2b3b284e722a5131e4434ca10fa69"
uuid = "14197337-ba66-59df-a3e3-ca00e7dcff7a"
version = "0.3.4"

[[deps.Glob]]
deps = ["Compat", "Test"]
git-tree-sha1 = "c72f1fcb7d17426de1e8af2e948dfb3de1116eed"
uuid = "c27321d9-0574-5035-807b-f59d2c89b15c"
version = "1.2.0"

[[deps.IndexedTables]]
deps = ["DataAPI", "DataValues", "Distributed", "IteratorInterfaceExtensions", "OnlineStatsBase", "PooledArrays", "SparseArrays", "Statistics", "StructArrays", "TableTraits", "TableTraitsUtils", "Tables", "WeakRefStrings"]
git-tree-sha1 = "57635c168763748fedd8282587a85cbd58d7ec9a"
uuid = "6deec6e2-d858-57c5-ab9b-e6ca5bd20e43"
version = "0.12.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JuliaDB]]
deps = ["Dagger", "DataValues", "Distributed", "Glob", "IndexedTables", "MemPool", "Nullables", "OnlineStats", "OnlineStatsBase", "PooledArrays", "Printf", "Random", "RecipesBase", "Serialization", "Statistics", "StatsBase", "TextParse", "WeakRefStrings"]
git-tree-sha1 = "97f24d428f00f0e8c662d2aa52a389f3fcc08897"
uuid = "a93385a2-3734-596a-9a66-3cfbb77141e6"
version = "0.13.1"

[[deps.LearnBase]]
deps = ["LinearAlgebra", "SparseArrays", "StatsBase", "Test"]
git-tree-sha1 = "c4b5da6d68517f46f70ed5157b28336b56cd2ff3"
uuid = "7f8f8fb0-2700-5f03-b4bd-41f8cfc144b6"
version = "0.2.2"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LossFunctions]]
deps = ["InteractiveUtils", "LearnBase", "Markdown", "Random", "RecipesBase", "SparseArrays", "Statistics", "StatsBase", "Test"]
git-tree-sha1 = "08d87fec43e7d335811dfae5b55dbfc5690e915b"
uuid = "30fc2ffe-d236-52d8-8643-a9d8f7c094a7"
version = "0.5.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.MemPool]]
deps = ["DataStructures", "Distributed", "Mmap", "Random", "Serialization", "Sockets", "Test"]
git-tree-sha1 = "d52799152697059353a8eac1000d32ba8d92aa25"
uuid = "f9f48841-c794-520a-933b-121f7ba6ed94"
version = "0.2.0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f8c673ccc215eb50fcadb285f522420e29e69e1c"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "0.4.5"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Nullables]]
deps = ["Compat"]
git-tree-sha1 = "ae1a63457e14554df2159b0b028f48536125092d"
uuid = "4d1e1d77-625e-5b40-9113-a560ec7a8ecd"
version = "0.0.8"

[[deps.OnlineStats]]
deps = ["Dates", "LearnBase", "LinearAlgebra", "LossFunctions", "OnlineStatsBase", "OrderedCollections", "PenaltyFunctions", "Random", "RecipesBase", "Reexport", "Statistics", "StatsBase", "SweepOperator"]
git-tree-sha1 = "d7caf945b59e36917bbd4203dc98bdd23c78b92f"
uuid = "a15396b6-48d5-5d58-9928-6d29437db91e"
version = "1.0.2"

[[deps.OnlineStatsBase]]
deps = ["Dates", "LearnBase", "LinearAlgebra", "OrderedCollections", "Statistics", "StatsBase"]
git-tree-sha1 = "f375c3a187436278bae1e1e8eaae853449737097"
uuid = "925886fa-5bf2-5e8e-b522-a9147a512338"
version = "1.0.2"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PenaltyFunctions]]
deps = ["InteractiveUtils", "LearnBase", "LinearAlgebra", "RecipesBase", "Reexport", "Test"]
git-tree-sha1 = "b0baaa5218ca0ffd6a8ae37ef0b58e0df688ac8b"
uuid = "06bb1623-fdd5-5ca2-a01c-88eae3ea319e"
version = "0.1.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.Polynomials]]
deps = ["LinearAlgebra", "RecipesBase"]
git-tree-sha1 = "3010a6dd6ad4c7384d2f38c58fa8172797d879c1"
uuid = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
version = "3.2.0"

[[deps.PooledArrays]]
git-tree-sha1 = "6e8c38927cb6e9ae144f7277c753714861b27d14"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "0.5.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Quadmath]]
deps = ["Printf", "Random", "Requires"]
git-tree-sha1 = "c415bfc154c185a31e753d28e8778860995894c7"
uuid = "be4d8f0f-7fa4-5f49-b795-2f01399ab2dd"
version = "0.5.6"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
git-tree-sha1 = "7bdce29bc9b2f5660a6e5e64d64d91ec941f6aa2"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "0.7.0"

[[deps.Reexport]]
deps = ["Pkg"]
git-tree-sha1 = "7b1d07f411bc8ddb7977ec7f377b97b158514fe0"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "0.2.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures", "Random", "Test"]
git-tree-sha1 = "03f5898c9959f8115e30bc7226ada7d0df554ddd"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "0.3.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics"]
git-tree-sha1 = "c53e809e63fe5cf5de13632090bc3520649c9950"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.32.0"

[[deps.StructArrays]]
deps = ["PooledArrays", "Tables", "WeakRefStrings"]
git-tree-sha1 = "e860d3808176ace576a45d658ba80d7c815bf1ce"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.4.1"

[[deps.SweepOperator]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "3890d4d764af69e3f709f1122d8d59bfc2329283"
uuid = "7522ee7d-7047-56d0-94d9-4bc626e7058d"
version = "0.3.3"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "aaed7b3b00248ff6a794375ad6adf30f30ca5591"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "0.2.11"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TextParse]]
deps = ["CodecZlib", "DataStructures", "Dates", "DoubleFloats", "Mmap", "Nullables", "PooledArrays", "WeakRefStrings"]
git-tree-sha1 = "26b43d6746b52cca13c4cdef90f89652273b413e"
uuid = "e0df1984-e451-5cb5-8b61-797a481e67e3"
version = "0.9.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a0bb82eede528debe631b642eeb48a631a69bc2"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "0.6.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═17b3882a-518d-453f-b0b7-cf8c9ccd174e
# ╠═d7589ce2-1507-46e3-bade-2d49848a40ca
# ╠═3c6423c4-eab2-423b-89b0-dfbcd072017b
# ╠═234b62a8-7033-40e3-b778-e37f74fc9245
# ╠═320bf5b2-7d8a-4491-9244-199986a095e2
# ╠═0bbd8dd3-aec3-423f-939f-8426e7b7f788
# ╠═482a0bdb-d19e-4be4-a70f-5cbfd4af95d9
# ╠═05363791-e01c-44e1-8e6d-ac86affc7597
# ╠═a662f2e0-3329-4af8-b0c7-0534653c7d23
# ╠═4f3240fe-bd70-48a0-81d3-bd9812ad1747
# ╠═75eec1b5-651c-438c-94d1-16ad83011be9
# ╠═e522b92b-52aa-4749-8eb1-1b2f00d5930f
# ╠═266ba532-86c9-405d-b02f-7afc3ba3d423
# ╠═c0002e69-505b-495b-8868-606cce05b496
# ╠═6982cc75-6775-4efa-acd1-554ff7c7b939
# ╠═72c28819-1feb-42aa-a4ac-2065d5d93ac8
# ╠═4267565b-6178-4e8e-9129-4d6a4544ec35
# ╠═6114c20a-3653-4dce-a37a-08f620537a0c
# ╠═4cbc52e4-2447-4d3f-bb6f-1f5745386677
# ╠═d4337a53-01a0-4570-9f73-5d2ba1dfde5e
# ╠═2dfcfc08-c099-4bc8-a06d-f081c150bce7
# ╠═500a402f-5d7d-4276-b149-b25663fc04a5
# ╠═f5fbd105-c9c7-4a1c-a657-0ddc407804ed
# ╠═244964d2-db4c-4947-a9bb-c64db3f74d5c
# ╠═e09842cb-1c3d-42f7-856b-36303ba609a5
# ╠═ca26f1fb-4c90-4791-a001-2f55aaf799ea
# ╠═0d542e1c-ff9e-44c9-9251-12b98bc2efa6
# ╠═95af4cea-5aa1-11ed-3061-152e5851630b
# ╠═768e9bf7-7190-4980-b85f-742e98542b5f
# ╠═6db3f9f1-b48f-4a33-a311-cf38685d2711
# ╠═cce315a9-34fd-4505-911b-4ba8e1d1133a
# ╠═b7050539-c3bc-4629-8e95-5f368d09572b
# ╠═a3563ada-b5bb-4047-8dc1-6174073d60e7
# ╠═e5dfd0db-7e40-4e29-a72a-8d38e4cc176e
# ╠═44e89a9c-5b55-403c-bfab-b4a60d775279
# ╠═683420c2-74e9-4353-9e9a-43d3aa347ca4
# ╠═2f20d360-9806-4667-8ad2-a60c1a546562
# ╠═68e750ce-ae7d-4297-88b5-95f32bc0a60d
# ╠═a1063862-32d4-4ca5-ac0b-b8c1dc5d1747
# ╠═449eab36-1099-4d8c-91ba-987747f716e0
# ╠═fcc14093-916f-4a34-8477-cb0accecfdc7
# ╠═92a41103-bd14-4752-ad10-79c0cfc6f9d2
# ╠═6ce5ed48-f08b-4ee4-b1d5-fe471fe18dd5
# ╠═ce302404-5730-4885-a55a-d62e5f596081
# ╠═f558e6a2-548a-4a95-9149-a408a21bca80
# ╠═3b4d3349-be9c-45bb-a8ae-42a82506588e
# ╠═0b3bf5d4-8755-4d21-a664-0da3ad80b6b6
# ╠═5ff45a61-c5f9-401e-8f0e-20e3cdfe5706
# ╠═f74ada52-15c2-4ced-9253-dd0199c9f890
# ╠═2ee42c85-dddc-4977-8734-4153d7470871
# ╠═fb97bb00-1ad8-4d7e-a68d-5106ba91c35c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
