
CALL  make_v(0, 'number', @v_id_number);
CALL  make_v(0, 'title', @v_id_title);

CALL make_a(@v_id_number, @a_id_number);
CALL make_a(@v_id_title, @a_id_title);

SELECT @a_id_number, @a_id_title;

