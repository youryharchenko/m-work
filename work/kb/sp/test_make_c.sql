
CALL  make_v(0, 'Document', @v_id_doc);
CALL  make_v(0, 'Sentence', @v_id_sent);

CALL make_c(@v_id_doc, @c_id_doc);
CALL make_c(@v_id_sent, @c_id_sent);

SELECT @c_id_doc, @c_id_sent;

