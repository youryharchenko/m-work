
CALL make_v(0, 'obj1', @v_id_obj1);
CALL make_o(@v_id_obj1, @o_id_obj1);

CALL make_v(0, 'obj2', @v_id_obj2);
CALL make_o(@v_id_obj2, @o_id_obj2);

SELECT @o_id_obj1;
SELECT @o_id_obj2;

