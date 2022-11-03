### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 17b3882a-518d-453f-b0b7-cf8c9ccd174e
using Dates

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
struct Value
	value::Any
	#count::UInt
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

# ╔═╡ cce315a9-34fd-4505-911b-4ba8e1d1133a
function create!(d::Datum, value::Value)::ValueRef
	push!(d.values, value)
	ValueRef(length(d.values))
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
	value_ref = create!(d, Value(value))
	push!(d.role_properties, RoleProperty(role, property, value_ref))
	RolePropertyRef(length(d.role_properties))
end

# ╔═╡ 68e750ce-ae7d-4297-88b5-95f32bc0a60d
function add!(d::Datum, object::ObjectRef, role::RoleRef, property::PropertyRef, value::Any)::ObjectPropertyRef
	value_ref = create!(d, Value(value))
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
	ObjectRoleRef(length(d.object_roles))
end

# ╔═╡ fcc14093-916f-4a34-8477-cb0accecfdc7
function add!(d::Datum, relation::RelationRef, from::ObjectRef, to::ObjectRef)::ObjectRelationRef
	push!(d.object_relations, ObjectRelation(relation, from, to))
	ObjectRelationRef(length(d.object_relations))
end

# ╔═╡ ce302404-5730-4885-a55a-d62e5f596081
d = Datum()

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
	role_charger = create!(d, Role("Charger"))
	role_static = create!(d, Role("StaticObject"))
	role_dynamic = create!(d, Role("DynamicObject"))
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
			add!(d, cell, role_cell, prop_color, "white")
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
begin
	
end

# ╔═╡ fb97bb00-1ad8-4d7e-a68d-5106ba91c35c
d

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
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
# ╠═e5dfd0db-7e40-4e29-a72a-8d38e4cc176e
# ╠═44e89a9c-5b55-403c-bfab-b4a60d775279
# ╠═683420c2-74e9-4353-9e9a-43d3aa347ca4
# ╠═68e750ce-ae7d-4297-88b5-95f32bc0a60d
# ╠═a1063862-32d4-4ca5-ac0b-b8c1dc5d1747
# ╠═449eab36-1099-4d8c-91ba-987747f716e0
# ╠═fcc14093-916f-4a34-8477-cb0accecfdc7
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
