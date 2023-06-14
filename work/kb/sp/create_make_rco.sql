DROP PROCEDURE IF EXISTS make_rco;

DELIMITER //

CREATE PROCEDURE make_rco(IN rcid BIGINT UNSIGNED, IN cofrom BIGINT UNSIGNED, IN coto BIGINT UNSIGNED, IN ind BIGINT UNSIGNED,
    OUT id BIGINT UNSIGNED) BEGIN

    DECLARE n BIGINT UNSIGNED;

    SELECT COUNT(rco.id) INTO n FROM rco WHERE rco.rc = rcid AND rco.cof = cofrom AND rco.cot = coto;
    IF ind = n THEN
        INSERT INTO rco(rc, cof, cot, i) VALUES(rcid, cofrom, coto, ind);
    END IF;
   
    SELECT rco.id INTO id FROM rco WHERE rco.rc = rcid AND rco.cof = cofrom AND rco.cot = coto AND rco.i = ind;
    SELECT id, rcid, cofrom, coto, ind;
END //
