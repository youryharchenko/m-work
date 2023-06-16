CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_arco AS 
SELECT arco.id as arcoid, arco.rco as rcoid, arco.arc as arcid, 
    all_rco.r_type as r_type, all_rco.r_name as r_name, 
    all_rco.cf_type as cf_type, all_rco.cf_name as cf_name, 
    all_rco.of_type as of_type, all_rco.of_name as of_name, 
    all_rco.ct_type as ct_type, all_rco.ct_name as ct_name,
    all_rco.ot_type as ot_type, all_rco.ot_name as ot_name,
    all_rco.ind as ind,
    all_arc.a_type as a_type, all_arc.a_name as a_name,
    v.type_ as v_type, v.value as value
FROM arco
    JOIN all_rco ON arco.rco = all_rco.rcoid
    JOIN all_arc on arco.arc = all_arc.arcid
    JOIN v ON arco.v = v.id
ORDER BY r_name, cf_name, of_name, ct_name, ot_name, ind, a_name, value;