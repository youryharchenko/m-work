
CALL make_v(0, 'CONSISTS', @v_id_consists);
CALL make_r(@v_id_consists, @r_id_consists);


CALL make_v(0, 'Document', @v_id_doc);
CALL make_v(0, 'Sentence', @v_id_sent);

CALL make_c(@v_id_doc, @c_id_doc);
CALL make_c(@v_id_sent, @c_id_sent);

CALL make_rc(@r_id_consists, @c_id_doc, @c_id_sent, @rc_id_doc_sent);

CALL  make_v(0, 'Document01', @v_id_doc1);
CALL  make_v(0, 'Sentence01', @v_id_sent1);
CALL  make_v(0, 'Sentence02', @v_id_sent2);

CALL make_o(@v_id_doc1, @o_id_doc1);
CALL make_o(@v_id_sent1, @o_id_sent1);
CALL make_o(@v_id_sent2, @o_id_sent2);

CALL make_co(@c_id_doc, @o_id_doc1, @co_id_doc_doc1);
CALL make_co(@c_id_sent, @o_id_sent1, @co_id_doc_sent1);
CALL make_co(@c_id_sent, @o_id_sent2, @co_id_doc_sent2);

CALL make_rco(@rc_id_doc_sent, @co_id_doc_doc1, @co_id_doc_sent1, 0, @rco_id_doc1_sent1);
CALL make_rco(@rc_id_doc_sent, @co_id_doc_doc1, @co_id_doc_sent1, 1, @rco_id_doc1_sent1);

CALL make_rco(@rc_id_doc_sent, @co_id_doc_doc1, @co_id_doc_sent1, 0, @rco_id_doc1_sent1);
CALL make_rco(@rc_id_doc_sent, @co_id_doc_doc1, @co_id_doc_sent1, 9, @rco_id_doc1_sent1);

CALL make_rco(@rc_id_doc_sent, @co_id_doc_doc1, @co_id_doc_sent2, 0, @rco_id_doc1_sent2);


