CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_rc AS 
SELECT rc.id as rcid, rc.r as rid, rc.cf as cfid, rc.ct as ctid, 
    all_r.type as r_type, all_r.name as r_name, 
    all_cf.type as cf_type, all_cf.name as cf_name, 
    all_ct.type as ct_type, all_ct.name as ct_name
FROM rc 
    JOIN all_r ON rc.r = all_r.rid
    JOIN all_c as all_cf ON rc.cf = all_cf.cid 
    JOIN all_c as all_ct ON rc.ct = all_ct.cid 
    
ORDER BY r_name, cf_name, ct_name;