CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_a AS 
SELECT a.id as aid, v.id as vid, v.type_ as type, v.value as name
FROM a JOIN v ON a.v = v.id
ORDER BY name;