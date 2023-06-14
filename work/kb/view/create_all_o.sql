CREATE OR REPLACE SQL SECURITY INVOKER VIEW all_o AS 
SELECT o.id as oid, v.id as vid, v.type_ as type, v.value as name
FROM o JOIN v ON o.v = v.id
ORDER BY name;