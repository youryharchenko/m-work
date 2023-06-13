DROP PROCEDURE IF EXISTS make_v;

DELIMITER //

CREATE PROCEDURE make_v(IN t INT, IN val VARCHAR(1024), OUT id INT) BEGIN
    IF NOT EXISTS(SELECT v.id FROM v WHERE v.type_ = t AND v.value = val) THEN
        INSERT INTO v(type_, value) VALUES(t, val);
    END IF;
   
    SELECT v.id INTO id FROM v WHERE v.type_ = t AND v.value = val;
    SELECT id, t, val;
END //
