DROP PROCEDURE IF EXISTS make_arc;

DELIMITER //

CREATE PROCEDURE make_arc(IN relc BIGINT UNSIGNED, IN rattr BIGINT UNSIGNED, IN val BIGINT UNSIGNED, 
    OUT id BIGINT UNSIGNED) BEGIN

    IF NOT EXISTS(SELECT arc.id FROM arc WHERE arc.rc = relc AND arc.ar = rattr) THEN
        INSERT INTO arc(rc, ar, v) VALUES(relc, rattr, val);
    END IF;
   
    SELECT arc.id INTO id FROM arc WHERE arc.rc = relc AND arc.ar = rattr;
    SELECT id, relc as rc, rattr as ar, val as v;
END //
