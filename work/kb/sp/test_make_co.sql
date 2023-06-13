
CALL make_v(0, 'cat1', @v_id_cat1);
CALL make_c(@v_id_cat1, @c_id_cat1);


CALL make_v(0, 'cat2', @v_id_cat2);
CALL make_c(@v_id_cat2, @c_id_cat2);

CALL make_v(0, 'obj1', @v_id_obj1);
CALL make_o(@v_id_obj1, @o_id_obj1);

CALL make_v(0, 'obj2', @v_id_obj2);
CALL make_o(@v_id_obj2, @o_id_obj2);

CALL make_co(@c_id_cat1, @o_id_obj1, @co_id_cat1_obj1);
CALL make_co(@c_id_cat2, @o_id_obj2, @co_id_cat2_obj2);


SELECT @co_id_cat1_obj1, @co_id_cat2_obj2;

