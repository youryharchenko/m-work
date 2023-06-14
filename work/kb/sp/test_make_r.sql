
CALL  make_v(0, 'CONSISTS', @v_id_consists);
CALL  make_v(0, 'IS A INSTANCE OF', @v_id_isinstance);

CALL make_r(@v_id_consists, @r_id_consists);
CALL make_r(@v_id_isinstance, @r_id_isinstance);

SELECT @r_id_consists, @r_id_isinstance;

