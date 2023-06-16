DROP PROCEDURE IF EXISTS make_arco;

DELIMITER //

CREATE PROCEDURE make_arco(IN relco BIGINT UNSIGNED, IN rcattr BIGINT UNSIGNED, IN val BIGINT UNSIGNED, 
    OUT id BIGINT UNSIGNED) BEGIN

    IF NOT EXISTS(SELECT arco.id FROM arco WHERE arco.rco = relco AND arco.arc = rcattr) THEN
        INSERT INTO arco(rco, arc, v) VALUES(relco, rcattr, val);
    END IF;
   
    SELECT arco.id INTO id FROM arco WHERE arco.rco = relco AND arco.arc = rcattr;
    SELECT id, relco, rcattr, val;
END //
