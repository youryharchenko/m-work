DROP PROCEDURE IF EXISTS make_ac;

DELIMITER //

CREATE PROCEDURE make_ac(IN cat BIGINT UNSIGNED, IN attr BIGINT UNSIGNED, IN val BIGINT UNSIGNED, 
    OUT id BIGINT UNSIGNED) BEGIN

    IF NOT EXISTS(SELECT ac.id FROM ac WHERE ac.c = cat AND ac.a = attr) THEN
        INSERT INTO ac(c, a, v) VALUES(cat, attr, val);
    END IF;
   
    SELECT ac.id INTO id FROM ac WHERE ac.c = cat AND ac.a = attr;
    SELECT id, cat as c, attr as a, val as v;
END //
