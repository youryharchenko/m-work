DROP PROCEDURE IF EXISTS make_c;

DELIMITER //

CREATE PROCEDURE make_c(IN val INT, OUT id INT) BEGIN
    IF NOT EXISTS(SELECT c.id FROM c WHERE c.v = val) THEN
        INSERT INTO c(v) VALUES(val);
    END IF;
   
    SELECT c.id INTO id FROM c WHERE c.v = val;
    SELECT id, val;
END //
