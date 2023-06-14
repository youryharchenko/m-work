CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_co AS 
SELECT co.id as coid, co.c as cid, co.o as oid, 
    all_c.type as c_type, all_c.name as c_name, 
    all_o.type as o_type, all_o.name as o_name
FROM co 
    JOIN all_c ON co.c = all_c.cid 
    JOIN all_o ON co.o = all_o.oid
ORDER BY c_name, o_name;