DROP PROCEDURE IF EXISTS make_rc;

DELIMITER //

CREATE PROCEDURE make_rc(IN rel BIGINT UNSIGNED, IN cfrom BIGINT UNSIGNED, IN cto BIGINT UNSIGNED, OUT id BIGINT UNSIGNED) BEGIN
    IF NOT EXISTS(SELECT rc.id FROM rc WHERE rc.r = rel AND rc.cf = cfrom AND rc.ct = cto) THEN
        INSERT INTO rc(r, cf, ct) VALUES(rel, cfrom, cto);
    END IF;
   
    SELECT rc.id INTO id FROM rc WHERE rc.r = rel AND rc.cf = cfrom AND rc.ct = cto;
    SELECT id, rel, cfrom, cto;
END //
