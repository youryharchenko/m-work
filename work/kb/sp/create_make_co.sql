DROP PROCEDURE IF EXISTS make_co;

DELIMITER //

CREATE PROCEDURE make_co(IN cat BIGINT UNSIGNED, IN obj BIGINT UNSIGNED, OUT id BIGINT UNSIGNED) BEGIN
    IF NOT EXISTS(SELECT co.id FROM co WHERE co.c = cat AND co.o = obj) THEN
        INSERT INTO co(c, o) VALUES(cat, obj);
    END IF;
   
    SELECT co.id INTO id FROM co WHERE co.c = cat AND co.o = obj;
    SELECT id, cat, obj;
END //
