
CALL make_v(0, 'cat1', @v_id_cat1);
CALL make_c(@v_id_cat1, @c_id_cat1);
SELECT @c_id_cat1;

CALL make_v(0, 'cat2', @v_id_cat2);
CALL make_c(@v_id_cat2, @c_id_cat2);
SELECT @c_id_cat2;

