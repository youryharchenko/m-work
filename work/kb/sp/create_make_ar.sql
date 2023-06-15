DROP PROCEDURE IF EXISTS make_ar;

DELIMITER //

CREATE PROCEDURE make_ar(IN rel BIGINT UNSIGNED, IN attr BIGINT UNSIGNED, IN val BIGINT UNSIGNED, 
    OUT id BIGINT UNSIGNED) BEGIN

    IF NOT EXISTS(SELECT ar.id FROM ar WHERE ar.r = rel AND ar.a = attr) THEN
        INSERT INTO ar(r, a, v) VALUES(rel, attr, val);
    END IF;
   
    SELECT ar.id INTO id FROM ar WHERE ar.r = rel AND ar.a = attr;
    SELECT id, rel, attr, val;
END //
