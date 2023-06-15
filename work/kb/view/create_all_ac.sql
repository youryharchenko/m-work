CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_ac AS 
SELECT ac.id as acid, ac.c as cid, ac.a as aid, ac.v as vid,
    all_c.type as c_type, all_c.name as c_name, 
    all_a.type as a_type, all_a.name as a_name,
    v.type_ as v_type, v.value as value
FROM ac 
    JOIN all_c ON ac.c = all_c.cid 
    JOIN all_a ON ac.a = all_a.aid
    JOIN v ON ac.v = v.id
ORDER BY c_name, a_name, value;