
CALL  make_v(0, 'Document', @v_id_doc);
CALL  make_v(0, 'Sentence', @v_id_sent);

CALL make_c(@v_id_doc, @c_id_doc);
CALL make_c(@v_id_sent, @c_id_sent);

CALL  make_v(0, 'Document01', @v_id_doc1);
CALL  make_v(0, 'Sentence01', @v_id_sent1);
CALL  make_v(0, 'Sentence02', @v_id_sent2);

CALL make_o(@v_id_doc1, @o_id_doc1);
CALL make_o(@v_id_sent1, @o_id_sent1);
CALL make_o(@v_id_sent2, @o_id_sent2);

CALL make_co(@c_id_doc, @o_id_doc1, @co_id_doc_doc1);
CALL make_co(@c_id_sent, @o_id_sent1, @co_id_doc_sent1);
CALL make_co(@c_id_sent, @o_id_sent2, @co_id_doc_sent2);

SELECT @co_id_doc_doc1, @co_id_doc_sent1, @co_id_doc_sent2;

