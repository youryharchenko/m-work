DROP PROCEDURE IF EXISTS make_aco;

DELIMITER //

CREATE PROCEDURE make_aco(IN cobj BIGINT UNSIGNED, IN cattr BIGINT UNSIGNED, IN val BIGINT UNSIGNED, 
    OUT id BIGINT UNSIGNED) BEGIN

    IF NOT EXISTS(SELECT aco.id FROM aco WHERE aco.co = cobj AND aco.ac = cattr) THEN
        INSERT INTO aco(co, ac, v) VALUES(cobj, cattr, val);
    END IF;
   
    SELECT aco.id INTO id FROM aco WHERE aco.co = cobj AND aco.ac = cattr;
    SELECT id, cobj, cattr, val;
END //
