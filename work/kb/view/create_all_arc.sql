CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_arc AS 
SELECT arc.id as arcid, arc.rc as rcid, arc.ar as arid, 
    all_rc.r_type as r_type, all_rc.r_name as r_name, 
    all_rc.cf_type as cf_type, all_rc.cf_name as cf_name, 
    all_rc.ct_type as ct_type, all_rc.ct_name as ct_name,
    all_ar.a_type as a_type, all_ar.a_name as a_name,
    v.type_ as v_type, v.value as value
FROM arc 
    JOIN all_rc ON arc.rc = all_rc.rcid
    JOIN all_ar on arc.ar = all_ar.arid
    JOIN v ON arc.v = v.id
ORDER BY r_name, cf_name, ct_name, a_name, value;