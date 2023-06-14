CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_r AS 
SELECT r.id as rid, v.id as vid, v.type_ as type, v.value as name
FROM r JOIN v ON r.v = v.id
ORDER BY name;