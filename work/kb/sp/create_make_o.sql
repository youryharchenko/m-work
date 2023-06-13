DROP PROCEDURE IF EXISTS make_o;

DELIMITER //

CREATE PROCEDURE make_o(IN val INT, OUT id INT) BEGIN
    IF NOT EXISTS(SELECT o.id FROM o WHERE o.v = val) THEN
        INSERT INTO o(v) VALUES(val);
    END IF;
   
    SELECT o.id INTO id FROM o WHERE o.v = val;
    SELECT id, val;
END //
