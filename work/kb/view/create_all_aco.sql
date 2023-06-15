CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_aco AS 
SELECT aco.id as acoid, aco.co as coid, aco.ac as acid, aco.v as vid,
    all_co.c_type as c_type, all_co.c_name as c_name, 
    all_co.o_type as o_type, all_co.o_name as o_name, 
    all_ac.a_type as a_type, all_ac.a_name as a_name,
    v.type_ as v_type, v.value as value
FROM aco 
    JOIN all_co ON aco.co = all_co.coid 
    JOIN all_ac ON aco.ac = all_ac.acid
    JOIN v ON aco.v = v.id
ORDER BY c_name, a_name, value;