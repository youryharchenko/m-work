CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_ar AS 
SELECT ar.id as arid, ar.r as rid, ar.a as aid, ar.v as vid,
    all_r.type as r_type, all_r.name as r_name, 
    all_a.type as a_type, all_a.name as a_name,
    v.type_ as v_type, v.value as value
FROM ar
    JOIN all_r ON ar.r = all_r.rid 
    JOIN all_a ON ar.a = all_a.aid
    JOIN v ON ar.v = v.id
ORDER BY r_name, a_name, value;