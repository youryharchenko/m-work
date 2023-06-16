CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_rco AS 
SELECT rco.id as rcoid, rco.rc as rcid, 
    rco.cof as cofid, rco.cot as cotid, 
    all_rc.r_type as r_type, all_rc.r_name as r_name, 
    all_cof.c_type as cf_type, all_cof.c_name as cf_name,
    all_cof.o_type as of_type, all_cof.o_name as of_name, 
    all_cot.c_type as ct_type, all_cot.c_name as ct_name,
    all_cot.o_type as ot_type, all_cot.o_name as ot_name,
    rco.i as ind
FROM rco 
    JOIN all_rc ON rco.rc = all_rc.rcid
    JOIN all_co as all_cof ON rco.cof = all_cof.coid 
    JOIN all_co as all_cot ON rco.cot = all_cot.coid 
    
ORDER BY r_name, cf_name, of_name, ct_name, ot_name;