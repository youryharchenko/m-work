
CALL make_v(0, 'CONSISTS', @v_id_consists);
CALL make_r(@v_id_consists, @r_id_consists);


CALL make_v(0, 'Document', @v_id_doc);
CALL make_v(0, 'Sentence', @v_id_sent);

CALL make_c(@v_id_doc, @c_id_doc);
CALL make_c(@v_id_sent, @c_id_sent);

CALL make_rc(@r_id_consists, @c_id_doc, @c_id_sent, @rc_id_doc_sent);

SELECT @rc_id_doc_sent;

