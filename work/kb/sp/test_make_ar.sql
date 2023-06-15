
CALL make_v(0, 'CONSISTS', @v_id_consists);
CALL make_r(@v_id_consists, @r_id_consists);

CALL make_v(0, 'number', @v_id_number);
CALL make_a(@v_id_number, @a_id_number);

CALL  make_v(1, '0', @v_id_zero_int);

CALL make_ar(@r_id_consists, @a_id_number, @v_id_zero_int, @ar_id_consists_number);

