CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_c AS 
SELECT c.id as cid, v.id as vid, v.type_ as type, v.value as name
FROM c JOIN v ON c.v = v.id
ORDER BY name;